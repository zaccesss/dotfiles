#!/usr/bin/env python3
"""Terminal games: 2048, Snake, Blocks, Meteors, Word and a typing test. Standard library only.

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


def stat(label, value, codes=(1,)):
    # labels stay plain and numbers are bold, so they read at full contrast
    return label + " " + sgr(str(value), *codes)


def end_prompt(lines, result, score, game, unit=""):
    """Record the score and show the result under the final board.
    True means play again."""
    previous = best_score(game)
    best = record(game, score)
    if score > previous:
        best_text = stat("Best", "%d%s" % (best, unit), (33, 1)) + "   " + sgr("New best", 33, 1)
    else:
        best_text = stat("Best", "%d%s" % (best, unit))
    screen(lines + ["", sgr(result, 1), stat("Score", "%d%s" % (score, unit)) + "   " + best_text,
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
    """Slide a row to the left, merging equal pairs once. Returns (row, points)."""
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
    lines = [sgr("2048", 36, 1) + "    " + stat("Score", score) + "    " + stat("Best", best), "", edge]
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
            return end_prompt(lines, "Game over, no moves left", score, "2048")
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
            screen(draw_2048(board, score, max(best, score), sgr("You made 2048!", 32, 1))
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
        grid[food[1]][food[0]] = sgr("*", 33, 1)
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
    head = sgr("Snake", 36, 1) + "    " + stat("Score", score) + "    " + stat("Best", best)
    if paused:
        head += "    " + sgr("Paused", 33, 1)
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
            return end_prompt(lines, "Game over", score, "snake")
        snake = moved
        if ate:
            score += 1
            interval = max(0.08, interval - 0.006)
            food = place_food(snake, w, h)
            if food is None:
                lines = draw_snake(snake, food, w, h, score, max(best, score), False)
                return end_prompt(lines, "You filled the field!", score, "snake")
        due = time.monotonic() + interval


# ------------------------------------------------------------------ blocks

WELL_W, WELL_H = 10, 20
# box size and cells (x, y) inside it; rotation turns the box clockwise
SHAPES = {
    "I": (4, [(0, 1), (1, 1), (2, 1), (3, 1)]),
    "O": (2, [(0, 0), (1, 0), (0, 1), (1, 1)]),
    "T": (3, [(1, 0), (0, 1), (1, 1), (2, 1)]),
    "S": (3, [(1, 0), (2, 0), (0, 1), (1, 1)]),
    "Z": (3, [(0, 0), (1, 0), (1, 1), (2, 1)]),
    "J": (3, [(0, 0), (0, 1), (1, 1), (2, 1)]),
    "L": (3, [(2, 0), (0, 1), (1, 1), (2, 1)]),
}
PIECE_STYLE = {"I": (36,), "O": (33,), "T": (35,), "S": (32,), "Z": (31,), "J": (34,), "L": (37, 1)}
LINE_POINTS = (0, 100, 300, 500, 800)


def rotate(cells, n):
    return sorted((n - 1 - y, x) for x, y in cells)


def fits(well, cells, px, py):
    for x, y in cells:
        cx, cy = x + px, y + py
        if not (0 <= cx < WELL_W and cy < WELL_H) or (cy >= 0 and well[cy][cx]):
            return False
    return True


def try_rotate(well, cells, n, px, py):
    """Rotate clockwise with a basic wall kick. Returns (cells, px) or None."""
    turned = rotate(cells, n)
    for dx in (0, -1, 1, -2, 2):
        if fits(well, turned, px + dx, py):
            return turned, px + dx
    return None


def clear_lines(well):
    """Remove full rows and shift the rest down. Returns (well, rows cleared)."""
    kept = [row for row in well if not all(row)]
    n = len(well) - len(kept)
    return [[None] * WELL_W for _ in range(n)] + kept, n


def line_score(n, level):
    return LINE_POINTS[n] * level


def bag(rng=random):
    # every run of seven pieces holds each piece once
    while True:
        pieces = list(SHAPES)
        rng.shuffle(pieces)
        yield from pieces


def drop_distance(well, cells, px, py):
    d = 0
    while fits(well, cells, px, py + d + 1):
        d += 1
    return d


def draw_blocks(well, piece, nxt, score, best, lines_done, level, paused):
    grid = [[sgr("[]", *PIECE_STYLE[c]) if c else " ." for c in row] for row in well]
    if piece:
        kind, cells, px, py = piece
        g = drop_distance(well, cells, px, py)
        for x, y in cells:  # ghost first, so the piece itself draws over it
            if 0 <= y + py + g and not well[y + py + g][x + px]:
                grid[y + py + g][x + px] = "::"
        for x, y in cells:
            if y + py >= 0:
                grid[y + py][x + px] = sgr("[]", *PIECE_STYLE[kind])
    rows = ["".join(r) for r in grid]
    if paused:
        rows[WELL_H // 2] = sgr("Paused".center(WELL_W * 2), 7, 1)
    n, cells = SHAPES[nxt]
    ys = sorted({y for _, y in cells})
    preview = ["".join(sgr("[]", *PIECE_STYLE[nxt]) if (x, y) in cells else "  " for x in range(n))
               for y in ys]
    panel = [stat("Score", score), stat("Best", best), stat("Lines", lines_done), stat("Level", level),
             "", sgr("Next", 33, 1)] + preview + ["", sgr("Paused", 33, 1) if paused else ""]
    edge = "+" + "-" * (WELL_W * 2) + "+"
    out = [sgr("Blocks", 36, 1), edge]
    for i, row in enumerate(rows):
        out.append("|" + row + "|" + ("   " + panel[i] if i < len(panel) else ""))
    return out + [edge]


def play_blocks():
    hint = "Arrows move, Up rotates, Space drops, P pauses, Q or Esc for the menu"
    well = [[None] * WELL_W for _ in range(WELL_H)]
    pieces = bag()
    nxt = next(pieces)
    score, lines_done, paused = 0, 0, False
    best = best_score("blocks")
    piece = None

    def spawn(kind):
        n, cells = SHAPES[kind]
        return [kind, list(cells), (WELL_W - n) // 2, -1 if kind == "I" else 0]

    def gravity():
        return max(0.1, 0.8 * 0.85 ** (lines_done // 10))

    def view(p, pause=False):
        return draw_blocks(well, p, nxt, score, max(best, score), lines_done,
                           lines_done // 10 + 1, pause)

    piece, nxt = spawn(nxt), next(pieces)
    clear()
    due = time.monotonic() + gravity()
    while True:
        screen(view(piece, paused) + [hint])
        lock = False
        if paused:
            key = read_key()
            if key in QUIT_KEYS:
                record("blocks", score)
                return False
            if key in ("p", "P"):
                paused = False
                due = time.monotonic() + gravity()
            continue
        kind, cells, px, py = piece
        key = read_key(max(0.0, due - time.monotonic()))
        if key is not None:
            d = keydir(key)
            if key in QUIT_KEYS:
                record("blocks", score)
                return False
            if key in ("p", "P"):
                paused = True
            elif key == " ":
                g = drop_distance(well, cells, px, py)
                piece[3] += g
                score += 2 * g
                lock = True
            elif d in ("left", "right"):
                dx = -1 if d == "left" else 1
                if fits(well, cells, px + dx, py):
                    piece[2] += dx
            elif d == "up":
                turned = try_rotate(well, cells, SHAPES[kind][0], px, py)
                if turned:
                    piece[1], piece[2] = turned
            elif d == "down":
                if fits(well, cells, px, py + 1):
                    piece[3] += 1
                    score += 1
                    due = time.monotonic() + gravity()
                else:
                    lock = True
            if not lock:
                continue
        elif fits(well, cells, px, py + 1):
            piece[3] += 1
            due = time.monotonic() + gravity()
            continue
        # the piece has landed: fix it in the well, clear rows and bring in the next one
        kind, cells, px, py = piece
        if any(y + py < 0 for _, y in cells):
            return end_prompt(view(piece), "Game over", score, "blocks")
        for x, y in cells:
            well[y + py][x + px] = kind
        well, n = clear_lines(well)
        score += line_score(n, lines_done // 10 + 1)
        lines_done += n
        piece, nxt = spawn(nxt), next(pieces)
        if not fits(well, piece[1], piece[2], piece[3]):
            return end_prompt(view(None), "Game over", score, "blocks")
        due = time.monotonic() + gravity()


# ----------------------------------------------------------------- meteors

FIELD_W, FIELD_H = 40, 20
MAX_SHOTS = 3


def collide(meteors, shots):
    """Remove every meteor that shares a cell with a shot. Returns points."""
    cells = {tuple(s) for s in shots}
    hit = {(m[0], m[1]) for m in meteors} & cells
    meteors[:] = [m for m in meteors if (m[0], m[1]) not in hit]
    shots[:] = [s for s in shots if tuple(s) not in hit]
    return 10 * len(hit)


def meteor_tick(meteors, shots, ship_x, tick, h=FIELD_H):
    """Advance one tick in place. Returns (points, ship hits).
    Collisions are checked before and after each move, so a shot and a
    meteor that pass each other between ticks still meet."""
    points = collide(meteors, shots)
    for s in shots:
        s[1] -= 1
    shots[:] = [s for s in shots if s[1] >= 0]
    points += collide(meteors, shots)
    for m in meteors:
        if tick % m[2] == 0:  # m[2] is how many ticks each fall step takes
            m[1] += 1
    points += collide(meteors, shots)
    hits = sum(1 for m in meteors if m[1] == h - 1 and m[0] == ship_x)
    meteors[:] = [m for m in meteors if m[1] < h and not (m[1] == h - 1 and m[0] == ship_x)]
    return points, hits


def draw_meteors(meteors, shots, ship_x, score, best, lives, flash, paused):
    grid = [[" "] * FIELD_W for _ in range(FIELD_H)]
    for x, y in shots:
        grid[y][x] = sgr("|", 33, 1)
    for x, y, _ in meteors:
        if 0 <= y < FIELD_H:
            grid[y][x] = sgr("O", 31, 1)
    grid[FIELD_H - 1][ship_x] = sgr("A", 36, 1, 7) if flash else sgr("A", 36, 1)
    if paused:
        label = " Paused "
        x0 = (FIELD_W - len(label)) // 2
        for i, ch in enumerate(label):
            grid[FIELD_H // 2][x0 + i] = sgr(ch, 7)
    head = "    ".join([sgr("Meteors", 36, 1), stat("Score", score), stat("Best", best),
                        stat("Lives", lives, (31, 1) if lives == 1 else (1,))])
    if paused:
        head += "    " + sgr("Paused", 33, 1)
    edge = "+" + "-" * FIELD_W + "+"
    return [head, edge] + ["|" + "".join(row) + "|" for row in grid] + [edge]


def play_meteors():
    hint = "Left and Right move, Space shoots, P pauses, Q or Esc for the menu"
    meteors, shots = [], []
    ship_x, score, lives, tick = FIELD_W // 2, 0, 3, 0
    safe_until, paused = 0.0, False
    best = best_score("meteors")
    clear()

    def interval():
        return max(0.07, 0.12 - score / 20000)

    due = time.monotonic() + interval()
    while True:
        now = time.monotonic()
        screen(draw_meteors(meteors, shots, ship_x, score, max(best, score), lives,
                            now < safe_until, paused) + [hint])
        if paused:
            key = read_key()
            if key in QUIT_KEYS:
                record("meteors", score)
                return False
            if key in ("p", "P"):
                paused = False
                due = time.monotonic() + interval()
            continue
        key = read_key(max(0.0, due - now))
        if key is not None:
            d = keydir(key)
            if key in QUIT_KEYS:
                record("meteors", score)
                return False
            if key in ("p", "P"):
                paused = True
            elif key == " " and len(shots) < MAX_SHOTS:
                shots.append([ship_x, FIELD_H - 2])
            elif d == "left":
                ship_x = max(0, ship_x - 1)
            elif d == "right":
                ship_x = min(FIELD_W - 1, ship_x + 1)
            continue
        tick += 1
        # spawn rate and fall speed rise gently with the score
        if random.random() < min(0.3, 0.05 + score / 3000):
            slowest_fast = 2 if score < 150 else 1
            meteors.append([random.randrange(FIELD_W), 0, random.randint(slowest_fast, 3)])
        points, hits = meteor_tick(meteors, shots, ship_x, tick)
        score += points
        if hits and time.monotonic() >= safe_until:
            lives -= 1
            safe_until = time.monotonic() + 1.0
            if lives <= 0:
                lines = draw_meteors(meteors, shots, ship_x, score, max(best, score), 0, False, False)
                return end_prompt(lines, "Game over", score, "meteors")
        due = time.monotonic() + interval()


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
    lines = [sgr("Word", 36, 1) + "    Guess the five letter word in six tries", ""]
    for i in range(6):
        if i < len(guesses):
            g, marks = guesses[i], feedback(answer, guesses[i])
            lines.append(" ".join(sgr(" %s " % c.upper(), *MARK_STYLE[m]) for c, m in zip(g, marks)))
            lines.append(" ".join(" %s " % m for m in marks))
        else:
            text = current if i == len(guesses) else ""
            lines.append(" ".join(sgr(" %s " % text[j].upper(), 1) if j < len(text) else " _ " for j in range(5)))
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
              "", "Key: " + sgr("^", 32, 1) + " right place (green)   " + sgr("~", 33, 1) + " wrong place (yellow)   . not in the word",
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
            return end_prompt(lines, result, score, "word")
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
            out.append(sgr(ch, 32))
        else:  # a wrong space would be invisible, so show it as _
            out.append(sgr(ch if ch != " " else "_", 31, 4))
    if len(typed) < len(target):
        out.append(sgr(" ", 7))
    # the next letter to type, in the line above, is yellow and underlined so it is easy to find
    n = len(typed)
    shown = target[:n] + (sgr(target[n], 33, 1, 4) + target[n + 1:] if n < len(target) else "")
    return [sgr("Typing test", 36, 1), "", "Type this line:", "", shown, "".join(out), "",
            "   ".join([stat("Typed", "%d of %d" % (len(typed), len(target))),
                        stat("Mistakes", errors, (31, 1) if errors else (1,)),
                        stat("Accuracy", "%.0f%%" % accuracy(keys, errors)),
                        stat("Time", "%.1f s" % seconds)]),
            "", "Correct letters turn green. Mistakes are red and underlined.",
            "The next letter to type is yellow and underlined. The timer starts on your first key."]


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
            return end_prompt(lines, result, round(speed), "typing", " wpm")
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

GAMES = [("2048", play_2048), ("Snake", play_snake), ("Blocks", play_blocks),
         ("Meteors", play_meteors), ("Word", play_word), ("Typing test", play_typing),
         ("Quit", None)]


def menu():
    sel = 0
    clear()
    while True:
        lines = ["", sgr("Games", 36, 1), ""]
        for i, (name, _) in enumerate(GAMES):
            lines.append(sgr("> ", 36, 1) + sgr(name, 36, 7, 1) if i == sel else "  " + name)
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
    check(all(line.isascii() and "q" not in line.lower() for line in LINES) and len(LINES) >= 25, "typing lines")

    for kind, (n, cells) in SHAPES.items():
        turned = sorted(cells)
        for _ in range(4):
            turned = rotate(turned, n)
        check(turned == sorted(cells), "four turns of %s return the original" % kind)
    empty = [[None] * WELL_W for _ in range(WELL_H)]
    full = ["Z"] * WELL_W
    gap = ["T"] * (WELL_W - 1) + [None]
    well = [[None] * WELL_W for _ in range(WELL_H - 3)] + [list(full), list(gap), list(full)]
    cleared, n = clear_lines(well)
    check(n == 2 and cleared[-1] == gap and len(cleared) == WELL_H, "full rows removed, rest shifted down")
    check(all(c is None for row in cleared[:-1] for c in row), "new rows are empty")
    o = SHAPES["O"][1]
    check(fits(empty, o, 0, 0) and not fits(empty, o, -1, 0), "left wall")
    check(fits(empty, o, WELL_W - 2, 0) and not fits(empty, o, WELL_W - 1, 0), "right wall")
    check(fits(empty, o, 0, WELL_H - 2) and not fits(empty, o, 0, WELL_H - 1), "floor")
    check(not fits(well, o, 0, WELL_H - 4), "landed blocks")
    check(drop_distance(empty, o, 4, 0) == WELL_H - 2, "hard drop distance")
    i_up = rotate(SHAPES["I"][1], 4)
    kicked = try_rotate(empty, i_up, 4, -2, 5)  # upright I against the left wall
    check(kicked is not None and kicked[1] == 0, "wall kick off the left wall")
    check([line_score(k, 1) for k in range(5)] == [0, 100, 300, 500, 800], "line scores")
    check(line_score(4, 3) == 2400, "line score times level")
    rng, gen = random.Random(7), None
    gen = bag(rng)
    check(all(sorted(next(gen) for _ in range(7)) == sorted(SHAPES) for _ in range(5)), "seven bag")

    m, s = [[5, 10, 1]], [[5, 10]]
    check(meteor_tick(m, s, 0, 1) == (10, 0) and not m and not s, "shot and meteor in one cell")
    m, s = [[5, 9, 1]], [[5, 10]]
    check(meteor_tick(m, s, 0, 1) == (10, 0) and not m and not s, "shot moves into meteor")
    m, s = [[5, 8, 1]], [[5, 10]]
    check(meteor_tick(m, s, 0, 1) == (10, 0) and not m and not s, "shot and meteor meet after both move")
    m, s = [[5, 3, 3]], []
    meteor_tick(m, s, 0, 1)
    check(m == [[5, 3, 3]], "slow meteor waits for its tick")
    m, s = [[3, FIELD_H - 2, 1]], []
    check(meteor_tick(m, s, 3, 1) == (0, 1) and not m, "meteor reaching the ship costs a life")
    m, s = [[7, FIELD_H - 1, 1]], [[2, 0]]
    check(meteor_tick(m, s, 3, 1) == (0, 0) and not m and not s, "meteor past the bottom and shot past the top removed")

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
