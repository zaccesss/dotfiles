#!/usr/bin/env python3
"""Terminal games: 2048, Snake, Word and a typing test. Standard library only.

Run `python3 games.py` to play or `python3 games.py --check` for self-tests.
"""

import atexit
import json
import os
import random
import shutil
import signal
import sys
import time
from pathlib import Path

WINDOWS = os.name == "nt"
if WINDOWS:
    import msvcrt
else:
    import select
    import termios
    import tty

SCORES_FILE = Path.home() / ".local" / "state" / "games" / "scores.json"
QUIT_KEYS = ("q", "Q", "esc")
PAUSE_KEYS = ("p", "P", " ")
DIRECTIONS = ("up", "down", "left", "right")

# ---------------------------------------------------------------- terminal


def write(text):
    sys.stdout.write(text)
    sys.stdout.flush()


def sgr(text, *codes):
    # only normal colours 30-37 plus bold (1), underline (4) and reverse (7)
    if not codes:
        return text
    return "\x1b[%sm%s\x1b[0m" % (";".join(map(str, codes)), text)


def clear():
    write("\x1b[2J\x1b[H")


def screen(lines):
    # redraw from home and erase leftovers, which avoids flicker from full clears
    body = "\r\n".join("  " + line + "\x1b[K" for line in lines)
    write("\x1b[H" + body + "\x1b[J")


class Terminal:
    """Raw keyboard mode plus hidden cursor, always undone on exit."""

    def __init__(self):
        self.saved = None
        self.active = False

    def __enter__(self):
        if not WINDOWS:
            self.fd = sys.stdin.fileno()
            self.saved = termios.tcgetattr(self.fd)
            tty.setraw(self.fd)
        self.active = True
        atexit.register(self.restore)
        write("\x1b[?1049h\x1b[?25l")
        return self

    def restore(self):
        if not self.active:
            return
        self.active = False
        write("\x1b[0m\x1b[2J\x1b[H\x1b[?25h\x1b[?1049l")
        if self.saved is not None:
            termios.tcsetattr(self.fd, termios.TCSADRAIN, self.saved)
            self.saved = None

    def __exit__(self, *exc):
        self.restore()
        return False


def _name(ch):
    if ch in ("\r", "\n"):
        return "enter"
    if ch in ("\x7f", "\x08"):
        return "backspace"
    if ch == "\x1b":
        return "esc"
    if ch == "\x03":
        # raw mode swallows the signal, so raise it by hand
        raise KeyboardInterrupt
    if " " <= ch <= "~":
        return ch
    return None


def _ready(fd, timeout):
    return bool(select.select([fd], [], [], timeout)[0])


def _read_key_unix(timeout):
    fd = sys.stdin.fileno()
    if timeout is not None and not _ready(fd, timeout):
        return None
    b = os.read(fd, 1)
    if b == b"\x1b":
        # a lone esc has nothing following it within about 50 ms
        if not _ready(fd, 0.05):
            return "esc"
        b2 = os.read(fd, 1)
        if b2 in (b"[", b"O") and _ready(fd, 0.05):
            b3 = os.read(fd, 1)
            arrow = {b"A": "up", b"B": "down", b"C": "right", b"D": "left"}.get(b3)
            if arrow:
                return arrow
        while _ready(fd, 0.01):  # drop the rest of any other sequence
            os.read(fd, 1)
        return None
    if b >= b"\x80":  # non-ascii input is not used by any game
        while _ready(fd, 0.01):
            os.read(fd, 1)
        return None
    return _name(b.decode("ascii"))


def _read_key_windows(timeout):
    if timeout is not None:
        end = time.monotonic() + timeout
        while not msvcrt.kbhit():
            if time.monotonic() >= end:
                return None
            time.sleep(0.01)
    ch = msvcrt.getwch()
    if ch in ("\x00", "\xe0"):
        return {"H": "up", "P": "down", "K": "left", "M": "right"}.get(msvcrt.getwch())
    return _name(ch)


def read_key(timeout=None):
    """Return a key name ('up', 'enter', 'esc', 'backspace', ...) or a single
    printable character. With a timeout, return None if nothing arrives."""
    return _read_key_windows(timeout) if WINDOWS else _read_key_unix(timeout)


def keydir(key):
    if key in DIRECTIONS:
        return key
    if key and len(key) == 1:
        return {"w": "up", "s": "down", "a": "left", "d": "right"}.get(key.lower())
    return None


# ------------------------------------------------------------------ scores


def load_scores():
    try:
        data = json.loads(SCORES_FILE.read_text(encoding="utf-8"))
        return {k: v for k, v in data.items() if isinstance(v, int)}
    except Exception:
        return {}


def best_score(game):
    return load_scores().get(game, 0)


def record(game, score):
    """Save score if it beats the best, return the best."""
    scores = load_scores()
    if score > scores.get(game, 0):
        scores[game] = score
        try:
            SCORES_FILE.parent.mkdir(parents=True, exist_ok=True)
            SCORES_FILE.write_text(json.dumps(scores, indent=2), encoding="utf-8")
        except Exception:
            pass
    return max(score, scores.get(game, 0))


def end_prompt(lines, result, score, best, unit=""):
    """Show the result under the final board. True means play again."""
    screen(lines + ["", sgr(result, 1), "Score %d%s   Best %d%s" % (score, unit, best, unit),
                    "", "Enter to play again, Q for the menu"])
    while True:
        key = read_key()
        if key in QUIT_KEYS:
            return False
        if key == "enter":
            return True


# -------------------------------------------------------------------- 2048

TILE_STYLE = {2: (37,), 4: (36,), 8: (33,), 16: (32,), 32: (35,), 64: (31,),
              128: (34, 1), 256: (36, 1), 512: (33, 1), 1024: (32, 1), 2048: (35, 1, 7)}


def merge_row(row):
    """Slide a row to the left, merging ember pairs once. Returns (row, points)."""
    nums = [v for v in row if v]
    out, points, i = [], 0, 0
    while i < len(nums):
        if i + 1 < len(nums) and nums[i] == nums[i + 1]:
            out.append(nums[i] * 2)
            points += nums[i] * 2
            i += 2
        else:
            out.append(nums[i])
            i += 1
    return out + [0] * (len(row) - len(out)), points


def move(board, direction):
    """Return (new board, points, moved)."""
    vertical = direction in ("up", "down")
    reverse = direction in ("right", "down")
    rows = [list(r) for r in zip(*board)] if vertical else board
    new, points = [], 0
    for row in rows:
        merged, p = merge_row(row[::-1] if reverse else row)
        new.append(merged[::-1] if reverse else merged)
        points += p
    if vertical:
        new = [list(r) for r in zip(*new)]
    return new, points, new != [list(r) for r in board]


def can_move(board):
    return any(move(board, d)[2] for d in DIRECTIONS)


def add_tile(board):
    empty = [(r, c) for r in range(4) for c in range(4) if not board[r][c]]
    if empty:
        r, c = random.choice(empty)
        board[r][c] = 4 if random.random() < 0.1 else 2


def draw_2048(board, score, best, msg=""):
    edge = "+" + "+".join(["------"] * 4) + "+"
    lines = [sgr("2048", 1) + "    Score %d    Best %d" % (score, best), "", edge]
    for row in board:
        cells = [sgr("%5d " % v, *TILE_STYLE.get(v, (35, 1))) if v else "   .  " for v in row]
        lines += ["|" + "|".join(cells) + "|", edge]
    return lines + ["", msg]


def play_2048():
    hint = "Arrows or WASD to move, Q or Esc for the menu"
    best = best_score("2048")
    board = [[0] * 4 for _ in range(4)]
    add_tile(board)
    add_tile(board)
    score, won = 0, False
    clear()
    while True:
        lines = draw_2048(board, score, max(best, score))
        if not can_move(board):
            return end_prompt(lines, "No moves left", score, record("2048", score))
        screen(lines + [hint])
        key = read_key()
        if key in QUIT_KEYS:
            record("2048", score)
            return False
        d = keydir(key)
        if not d:
            continue
        board, points, moved = move(board, d)
        if moved:
            score += points
            add_tile(board)
        if not won and any(2048 in row for row in board):
            won = True
            screen(draw_2048(board, score, max(best, score), sgr("You made 2048!", 1))
                   + ["Enter to keep going, Q for the menu"])
            while True:
                key = read_key()
                if key in QUIT_KEYS:
                    record("2048", score)
                    return False
                if key == "enter":
                    break


# ------------------------------------------------------------------- snake

VECTORS = {"up": (0, -1), "down": (0, 1), "left": (-1, 0), "right": (1, 0)}


def step(snake, d, food, w, h):
    """Move the snake one cell. Returns (snake, ate, dead)."""
    head = (snake[0][0] + d[0], snake[0][1] + d[1])
    ate = head == food
    body = snake if ate else snake[:-1]  # the tail moves away unless growing
    dead = not (0 <= head[0] < w and 0 <= head[1] < h) or head in body
    return [head] + body, ate, dead


def place_food(snake, w, h):
    free = [(x, y) for y in range(h) for x in range(w) if (x, y) not in snake]
    return random.choice(free) if free else None


def draw_snake(snake, food, w, h, score, best, paused):
    grid = [[" "] * w for _ in range(h)]
    if food:
        grid[food[1]][food[0]] = sgr("*", 31, 1)
    for x, y in snake[1:]:
        grid[y][x] = sgr("O", 32)
    hx, hy = snake[0]
    if 0 <= hx < w and 0 <= hy < h:
        grid[hy][hx] = sgr("@", 32, 1)
    if paused:
        label = " Paused "
        x0 = max(0, (w - len(label)) // 2)
        for i, ch in enumerate(label[:w]):
            grid[h // 2][x0 + i] = sgr(ch, 7)
    head = sgr("Snake", 1) + "    Score %d    Best %d" % (score, best)
    if paused:
        head += "    " + sgr("Paused", 1)
    edge = "+" + "-" * w + "+"
    return [head, edge] + ["|" + "".join(row) + "|" for row in grid] + [edge]


def play_snake():
    hint = "Arrows or WASD to steer, P or Space to pause, Q or Esc for the menu"
    cols, rows = shutil.get_terminal_size((80, 24))
    # whole field including its border stays within 60x20
    w, h = max(10, min(58, cols - 4)), max(5, min(18, rows - 6))
    snake = [(w // 2 - i, h // 2) for i in range(3)]
    d, queue = VECTORS["right"], []
    food = place_food(snake, w, h)
    score, interval, paused = 0, 0.22, False
    best = best_score("snake")
    clear()
    due = time.monotonic() + interval
    while True:
        screen(draw_snake(snake, food, w, h, score, max(best, score), paused) + ["", hint])
        if paused:
            key = read_key()
            if key in QUIT_KEYS:
                record("snake", score)
                return False
            if key in PAUSE_KEYS:
                paused = False
                due = time.monotonic() + interval
            continue
        key = read_key(max(0.0, due - time.monotonic()))
        if key is not None:
            if key in QUIT_KEYS:
                record("snake", score)
                return False
            if key in PAUSE_KEYS:
                paused = True
            elif keydir(key) and len(queue) < 3:
                queue.append(VECTORS[keydir(key)])
            continue
        # one queued turn per tick, ignoring reversals into the body
        while queue:
            nd = queue.pop(0)
            if nd != d and nd != (-d[0], -d[1]):
                d = nd
                break
        moved, ate, dead = step(snake, d, food, w, h)
        if dead:
            lines = draw_snake(snake, food, w, h, score, max(best, score), False)
            return end_prompt(lines, "Game over", score, record("snake", score))
        snake = moved
        if ate:
            score += 1
            interval = max(0.08, interval - 0.006)
            food = place_food(snake, w, h)
            if food is None:
                lines = draw_snake(snake, food, w, h, score, max(best, score), False)
                return end_prompt(lines, "You filled the field!", score, record("snake", score))
        due = time.monotonic() + interval


# -------------------------------------------------------------------- word

# no word contains q, because q always returns to the menu
WORDS = sorted(set("""
about above actor adapt admit adopt after again agree ahead alarm album alert alive allow alone
along amber angle apple apply arena argue arise array arrow aside audio avoid award aware bacon
badge baker basic beach beard begin being bench berry birth black blade blank blend bless block
bloom board bonus boost booth bound brain brake brand brave bread break brick bride brief bring
broad brown brush build bunch burst cabin cable camel candy canoe cargo carry catch cause chain
chair chalk charm chart chase cheap check cheek cheer chess chest chief child chill choir civic
claim class clean clear clerk click cliff climb clock close cloud coach coast cocoa coral couch
could count court cover craft crane crash cream crisp crowd crown crust curve cycle daily dairy
dance delta dense depth diary dizzy dough draft drain drama dream dress drift drink drive eager
eagle early earth easel eight elbow empty enjoy enter ember error essay event every exact extra
fable faith fancy feast fence ferry field fifty final first flame flash fleet float flock floor
flour fluid flute focus forge forty found frame fresh front frost fruit funny giant given glass
globe glove grace grade grain grand grape graph grass great green greet grill group guard guess
guest guide habit happy heart heavy hedge hello hobby honey horse hotel house human ideal image
index inner input issue ivory jelly jewel joint jolly judge juice kayak knife knock label laser
later laugh layer learn lemon level light lilac limit linen lodge logic loyal lucky lunch magic
major maple march match mayor medal melon mercy metal model money month motor mount mouse mouth
movie music nerve never night noble noise north novel nurse oasis ocean offer often olive onion
opera orbit order organ other otter outer owner paint panel paper party pasta patch peach pearl
pedal penny phone photo piano pilot pitch pizza place plain plane plant plate plaza point polar
porch pound power press price pride prime print prize proud pupil puppy radio raise rally ranch
range rapid raven reach ready relax reply rider ridge right river roast robin robot rocky round
route royal ruler salad sauce scale scarf scene scone score scout shade shape share sharp sheep
shelf shell shine shirt shore short sight skill slice slope smile snack snail solar solid sound
south space spark speak spice spoon sport stack stage stair stamp stand start steam steel stick
still stone store storm story stove straw study sugar sunny super swing table taste teach thank
theme thick thing think third tiger toast today topic torch total touch tower track trade trail
train treat trend trial tribe truck trunk trust truth tulip uncle under unity until upper usual
valid value video visit vital vivid vocal voice wagon waltz watch water whale wheat wheel while
whole world worth write yacht young youth zebra
""".split()))

MARK_STYLE = {"^": (32, 1), "~": (33, 1), ".": ()}
MARK_RANK = {"^": 3, "~": 2, ".": 1}


def feedback(answer, guess):
    """Per letter: '^' right place, '~' wrong place, '.' not in word.
    Repeated letters are only marked as often as they occur in the answer."""
    marks = ["."] * 5
    left = {}
    for i, (a, g) in enumerate(zip(answer, guess)):
        if a == g:
            marks[i] = "^"
        else:
            left[a] = left.get(a, 0) + 1
    for i, g in enumerate(guess):
        if marks[i] != "^" and left.get(g, 0):
            marks[i] = "~"
            left[g] -= 1
    return "".join(marks)


def draw_word(guesses, current, answer, msg):
    lines = [sgr("Word", 1) + "    Guess the five letter word in six tries", ""]
    for i in range(6):
        if i < len(guesses):
            g, marks = guesses[i], feedback(answer, guesses[i])
            lines.append(" ".join(sgr(" %s " % c.upper(), *MARK_STYLE[m]) for c, m in zip(g, marks)))
            lines.append(" ".join(" %s " % m for m in marks))
        else:
            text = current if i == len(guesses) else ""
            lines.append(" ".join(" %s " % (text[j].upper() if j < len(text) else "_") for j in range(5)))
            lines.append("")
    status = {}
    for g in guesses:
        for c, m in zip(g, feedback(answer, g)):
            if MARK_RANK[m] > MARK_RANK.get(status.get(c), 0):
                status[c] = m
    letters = "abcdefghijklmnopqrstuvwxyz"
    lines += ["Letters used:",
              " ".join(sgr(c.upper(), *MARK_STYLE[status[c]]) if c in status else c.upper() for c in letters),
              " ".join(status.get(c, " ") for c in letters),
              "", "Key: ^ right place (green)   ~ wrong place (yellow)   . not in the word",
              msg]
    return lines


def play_word():
    hint = "Type letters, Backspace to delete, Enter to guess, Esc or Q for the menu"
    answer = random.choice(WORDS)
    guesses, current, msg = [], "", ""
    clear()
    while True:
        lines = draw_word(guesses, current, answer, msg)
        if guesses and (guesses[-1] == answer or len(guesses) == 6):
            if guesses[-1] == answer:
                n = len(guesses)
                score, result = 7 - n, "Solved in %d %s" % (n, "guess" if n == 1 else "guesses")
            else:
                score, result = 0, "The word was %s" % answer.upper()
            return end_prompt(lines, result, score, record("word", score))
        screen(lines + [hint])
        key, msg = read_key(), ""
        if key in QUIT_KEYS:
            return False
        if key == "backspace":
            current = current[:-1]
        elif key == "enter":
            if len(current) < 5:
                msg = "Not enough letters"
            else:
                guesses.append(current)
                current = ""
        elif key and len(key) == 1 and key.isascii() and key.isalpha() and len(current) < 5:
            current += key.lower()


# ------------------------------------------------------------- typing test

# no line contains q, because q always returns to the menu
LINES = [
    'print("hello, world")',
    "for i in range(10): total += i",
    "names = [n.strip() for n in lines]",
    "def area(w, h): return w * h",
    "if score > best: best = score",
    "data = json.loads(text)",
    'with open("notes.txt") as f: print(f.read())',
    "import os; print(os.getcwd())",
    "counts = {word: len(word) for word in words}",
    "ls -la ~/projects",
    "git status --short",
    "mkdir -p build && cd build",
    'grep -rn "TODO" src/',
    "echo $HOME > path.txt",
    "cat log.txt | sort | head -n 5",
    'find . -name "*.py" | wc -l',
    "cp -r docs backup/docs",
    "chmod +x run.sh && ./run.sh",
    "The cat sat by the warm window all afternoon.",
    "Practise a little every day and it adds up.",
    "Rain fell softly on the old stone bridge.",
    "She packed a flask of tea and a map for the walk.",
    "Good code is easy to read and easy to change.",
    "The train left the station just after seven.",
    "A small garden can grow a surprising amount of food.",
    "Keep your hands relaxed and your eyes on the text.",
]


def wpm(correct_chars, seconds):
    # the usual convention: five characters count as one word
    return (correct_chars / 5) / (max(seconds, 0.001) / 60)


def accuracy(keys, errors):
    return 100.0 * (keys - errors) / keys if keys else 100.0


def draw_typing(target, typed, keys, errors, seconds):
    out = []
    for i, ch in enumerate(typed):
        if ch == target[i]:
            out.append(ch)
        else:  # a wrong space would be invisible, so show it as _
            out.append(sgr(ch if ch != " " else "_", 31, 4))
    if len(typed) < len(target):
        out.append(sgr(" ", 7))
    return [sgr("Typing test", 1), "", "Type this line:", "", target, "".join(out), "",
            "Typed %d of %d   Mistakes %d   Accuracy %.0f%%   Time %.1f s"
            % (len(typed), len(target), errors, accuracy(keys, errors), seconds),
            "", "Mistakes are underlined. The timer starts on your first key."]


def play_typing():
    hint = "Type the line, Backspace to fix, Esc or Q for the menu"
    target = random.choice(LINES)
    typed, keys, errors, start, end = "", 0, 0, None, None
    clear()
    while True:
        now = end or time.monotonic()
        lines = draw_typing(target, typed, keys, errors, now - start if start else 0.0)
        if len(typed) == len(target):
            correct = sum(a == b for a, b in zip(typed, target))
            speed = wpm(correct, end - start)
            result = "%.0f words per minute, %.0f%% accuracy" % (speed, accuracy(keys, errors))
            return end_prompt(lines, result, round(speed), record("typing", round(speed)), " wpm")
        screen(lines + ["", hint])
        key = read_key()
        if key in QUIT_KEYS:
            return False
        if key == "backspace":
            typed = typed[:-1]
        elif key and len(key) == 1:
            if start is None:
                start = time.monotonic()
            keys += 1
            if key != target[len(typed)]:
                errors += 1
            typed += key
            if len(typed) == len(target):
                end = time.monotonic()


# -------------------------------------------------------------------- menu

GAMES = [("2048", play_2048), ("Snake", play_snake), ("Word", play_word),
         ("Typing test", play_typing), ("Quit", None)]


def menu():
    sel = 0
    clear()
    while True:
        lines = ["", sgr("Games", 1), ""]
        for i, (name, _) in enumerate(GAMES):
            lines.append("> " + sgr(name, 7, 1) if i == sel else "  " + name)
        lines += ["", "Up and Down to choose, Enter to play, Q to quit"]
        screen(lines)
        key = read_key()
        if key in QUIT_KEYS:
            return
        if key in ("up", "w", "W", "k", "K"):
            sel = (sel - 1) % len(GAMES)
        elif key in ("down", "s", "S", "j", "J"):
            sel = (sel + 1) % len(GAMES)
        elif key == "enter":
            game = GAMES[sel][1]
            if game is None:
                return
            while game():
                pass
            clear()


# ------------------------------------------------------------------ checks


def check(cond, what):
    if not cond:
        raise AssertionError("check failed: " + what)


def run_checks():
    rows = {
        (2, 2, 2, 2): ([4, 4, 0, 0], 8),
        (2, 2, 4, 0): ([4, 4, 0, 0], 4),
        (4, 0, 4, 8): ([8, 8, 0, 0], 8),
        (2, 0, 0, 2): ([4, 0, 0, 0], 4),
        (0, 0, 0, 2): ([2, 0, 0, 0], 0),
        (2, 4, 8, 16): ([2, 4, 8, 16], 0),
        (8, 8, 16, 16): ([16, 32, 0, 0], 48),
    }
    for row, want in rows.items():
        check(merge_row(list(row)) == want, "merge %s gave %s" % (row, merge_row(list(row))))
    board = [[2, 2, 2, 0], [0, 0, 0, 0], [0, 0, 0, 0], [2, 0, 0, 0]]
    check(move(board, "right")[0][0] == [0, 0, 2, 4], "move right")
    check([r[0] for r in move(board, "up")[0]] == [4, 0, 0, 0], "move up")
    check(not move([[2, 4, 2, 4], [4, 2, 4, 2]] * 2, "left")[2], "blocked row does not move")
    check(not can_move([[2, 4, 2, 4], [4, 2, 4, 2]] * 2), "no moves left")

    cases = {("apple", "paper"): "~~^~.", ("otter", "lotto"): ".~^~.",
             ("crane", "crane"): "^^^^^", ("abbey", "kebab"): ".~^~~",
             ("lever", "eerie"): "~^~.."}
    for (answer, guess), want in cases.items():
        got = feedback(answer, guess)
        check(got == want, "feedback %s/%s gave %s, want %s" % (answer, guess, got, want))
    check(len(WORDS) >= 290, "word list size %d" % len(WORDS))
    check(all(len(w) == 5 and w.isalpha() and w.isascii() and "q" not in w for w in WORDS),
          "word list entries")

    snake = [(2, 2), (1, 2), (0, 2)]
    check(step(snake, (1, 0), None, 5, 5)[2] is False, "free move")
    check(step([(4, 0), (3, 0)], (1, 0), None, 5, 5)[2], "wall on the right")
    check(step([(0, 0), (1, 0)], (0, -1), None, 5, 5)[2], "wall at the top")
    loop = [(1, 1), (2, 1), (2, 2), (1, 2), (0, 2)]
    check(step(loop, (0, 1), None, 5, 5)[2], "runs into own body")
    square = [(1, 1), (2, 1), (2, 2), (1, 2)]
    check(not step(square, (0, 1), None, 5, 5)[2], "tail cell is free as it moves")
    check(step(square, (0, 1), (1, 2), 5, 5)[2], "tail stays when growing")
    grown, ate, _ = step(snake, (1, 0), (3, 2), 5, 5)
    check(ate and len(grown) == 4, "eating grows the snake")

    check(accuracy(50, 5) == 90.0, "accuracy 45 of 50")
    check(accuracy(0, 0) == 100.0, "accuracy with no keys")
    check(abs(wpm(250, 60) - 50.0) < 1e-9, "wpm 250 chars in 60 s")
    check(all(l.isascii() and "q" not in l.lower() for l in LINES) and len(LINES) >= 25, "typing lines")

    check(_name("\r") == "enter" and _name("\x7f") == "backspace" and _name("\x1b") == "esc", "key names")
    print("all checks pass")


# -------------------------------------------------------------------- main


def main():
    if "--check" in sys.argv[1:]:
        run_checks()
        return
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        sys.exit("games.py needs an interactive terminal")
    if WINDOWS:
        os.system("")  # turns on ANSI escape handling in the Windows console
    else:
        # turn kill and hangup into a normal exit so the terminal is restored
        for sig in (signal.SIGTERM, signal.SIGHUP):
            signal.signal(sig, lambda *_: sys.exit(1))
    try:
        with Terminal():
            menu()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
