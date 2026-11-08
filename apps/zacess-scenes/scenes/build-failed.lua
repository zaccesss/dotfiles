-- build-failed: my own fail scene for the build watcher, calm rather than alarming. BUILD FAILED
-- scrolls slowly across the top while signals run along the copper of a pixel circuit board. One
-- trace is broken, so its signal stops at the gap: something to find and fix. A ticker near the
-- bottom says when it failed, how long it has been failing and gives one small next step.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It reads the
-- time from ctx.clock and paints with the pixel canvas; on an older Zacess Scenes without them it
-- leaves the time out and draws the same shapes in half-block characters.

-- cells a second the big banner moves; slower than the pass banner, a failure is no rush
local BANNER_RATE = 6
-- cells a second the ticker moves
local TICKER_RATE = 6
-- pixels a second a signal travels along a trace
local SIGNAL_RATE = 9
-- seconds a stopped signal waits at the break before the next one sets off
local WAIT = 2.5

local TIPS = {
  "read the first error, not the last",
  "fix one thing, then save",
  "check what changed since it was green",
  "run the failing test on its own",
  "a short walk counts as debugging",
}
-- the colour bands on each resistor, as resistors carry them
local BANDS = { "red", "magenta", "yellow", "green" }

-- a 5 by 7 pixel font: each glyph is its seven rows split by spaces, # for a lit pixel
local FONT = {
  A = ".###. #...# #...# ##### #...# #...# #...#",
  B = "####. #...# #...# ####. #...# #...# ####.",
  C = ".###. #...# #.... #.... #.... #...# .###.",
  D = "####. #...# #...# #...# #...# #...# ####.",
  E = "##### #.... #.... ####. #.... #.... #####",
  F = "##### #.... #.... ####. #.... #.... #....",
  G = ".###. #...# #.... #.### #...# #...# .####",
  H = "#...# #...# #...# ##### #...# #...# #...#",
  I = "### .#. .#. .#. .#. .#. ###",
  J = "..### ...#. ...#. ...#. ...#. #..#. .##..",
  K = "#...# #..#. #.#.. ##... #.#.. #..#. #...#",
  L = "#.... #.... #.... #.... #.... #.... #####",
  M = "#...# ##.## #.#.# #.#.# #...# #...# #...#",
  N = "#...# #...# ##..# #.#.# #..## #...# #...#",
  O = ".###. #...# #...# #...# #...# #...# .###.",
  P = "####. #...# #...# ####. #.... #.... #....",
  Q = ".###. #...# #...# #...# #.#.# #..#. .##.#",
  R = "####. #...# #...# ####. #.#.. #..#. #...#",
  S = ".#### #.... #.... .###. ....# ....# ####.",
  T = "##### ..#.. ..#.. ..#.. ..#.. ..#.. ..#..",
  U = "#...# #...# #...# #...# #...# #...# .###.",
  V = "#...# #...# #...# #...# #...# .#.#. ..#..",
  W = "#...# #...# #...# #.#.# #.#.# #.#.# .#.#.",
  X = "#...# #...# .#.#. ..#.. .#.#. #...# #...#",
  Y = "#...# #...# .#.#. ..#.. ..#.. ..#.. ..#..",
  Z = "##### ....# ...#. ..#.. .#... #.... #####",
  ["0"] = ".###. #...# #..## #.#.# ##..# #...# .###.",
  ["1"] = "..#.. .##.. ..#.. ..#.. ..#.. ..#.. .###.",
  ["2"] = ".###. #...# ....# ...#. ..#.. .#... #####",
  ["3"] = "####. ....# ....# .###. ....# ....# ####.",
  ["4"] = "...#. ..##. .#.#. #..#. ##### ...#. ...#.",
  ["5"] = "##### #.... ####. ....# ....# #...# .###.",
  ["6"] = ".###. #.... #.... ####. #...# #...# .###.",
  ["7"] = "##### ....# ...#. ..#.. .#... .#... .#...",
  ["8"] = ".###. #...# #...# .###. #...# #...# .###.",
  ["9"] = ".###. #...# #...# .#### ....# ....# .###.",
  [" "] = "... ... ... ... ... ... ...",
  ["."] = ".. .. .. .. .. ## ##",
  [","] = ".. .. .. .. .# .# #.",
  ["!"] = "# # # # # . #",
  [":"] = ". # # . # # .",
  ["'"] = "# # . . . . .",
  ["-"] = "... ... ... ### ... ... ...",
  ["·"] = ".. .. .. ## ## .. ..",
  ["✓"] = "..... ....# ...## #.##. ###.. .#... .....",
  ["?"] = ".###. #...# ....# ...#. ..#.. ..... ..#..",
}

-- every glyph as its list of pixel rows, split once when the file loads
local glyphs = {}
for ch, rows in pairs(FONT) do
  local grid = {}
  for row in rows:gmatch("%S+") do
    grid[#grid + 1] = row
  end
  glyphs[ch] = grid
end

-- lays a message out as four rows of half-block cells, two pixel rows to a cell so each pixel is
-- about square. Returns the rows as lists of characters (false where nothing is lit) and the width
local function layout(message)
  local cells = { {}, {}, {}, {} }
  local width = 0
  for _, code in utf8.codes(message:upper()) do
    local grid = glyphs[utf8.char(code)] or glyphs[" "]
    local gw = #grid[1]
    for col = 1, gw do
      for r = 1, 4 do
        local top = grid[r * 2 - 1]:sub(col, col) == "#"
        local bottom = r * 2 <= #grid and grid[r * 2]:sub(col, col) == "#"
        cells[r][width + col] = (top and bottom and "█") or (top and "▀") or (bottom and "▄") or false
      end
    end
    -- one empty column between letters
    width = width + gw + 1
    for r = 1, 4 do
      cells[r][width] = false
    end
  end
  return cells, width
end

-- draws a laid out banner scrolled left by offset cells so it loops without a seam. With once set
-- it is drawn a single time at that offset instead. Only lit cells are drawn, which leaves the backdrop showing
-- through the gaps in the letters
local function draw_banner(cells, width, offset, y, w, role, once)
  for r = 1, 4 do
    local row = cells[r]
    local run, start = {}, nil
    for x = 0, w do
      local col = x + offset
      local ch = false
      if x < w and (not once or (col >= 0 and col < width)) then
        ch = row[col % width + 1]
      end
      if ch then
        start = start or x
        run[#run + 1] = ch
      elseif start then
        put(start, y + r - 1, table.concat(run), role)
        run, start = {}, nil
      end
    end
  end
end

-- a string as a list of characters, so text with a middle dot slices by character, not byte
local function chars(s)
  local list = {}
  for _, code in utf8.codes(s) do
    list[#list + 1] = utf8.char(code)
  end
  return list
end

-- pixel drawing that runs on every version of Zacess Scenes: the program's own pixel canvas
-- where it has one. On an older version without it the same calls are drawn as half-block
-- characters, so the scene still shows its shapes. Call flush after the pixels and before any
-- text, since text is drawn over them
local function painter(ctx)
  if ctx.rect then
    return {
      width = ctx.pixel_width,
      height = ctx.pixel_height,
      pixel = ctx.pixel,
      rect = ctx.rect,
      disc = ctx.disc,
      line = ctx.line,
      flush = function() end,
    }
  end
  local w, h = ctx.width, ctx.height * 2
  local grid = {}
  local function set(x, y, role, strength)
    -- faint imagery drops away here, as it does on screen with colour turned off
    if (strength or 1) < 0.3 then
      return
    end
    x, y = math.floor(x), math.floor(y)
    if x >= 0 and x < w and y >= 0 and y < h then
      grid[y * w + x] = role or "text"
    end
  end
  local p = { width = w, height = h }
  p.pixel = set
  p.rect = function(x, y, rw, rh, role, strength)
    for yy = math.max(0, math.floor(y)), math.min(h, math.floor(y + rh)) - 1 do
      for xx = math.max(0, math.floor(x)), math.min(w, math.floor(x + rw)) - 1 do
        set(xx, yy, role, strength)
      end
    end
  end
  p.disc = function(cx, cy, r, role, strength)
    for yy = math.floor(cy - r), math.ceil(cy + r) do
      for xx = math.floor(cx - r), math.ceil(cx + r) do
        if (xx - cx) ^ 2 + (yy - cy) ^ 2 <= r * r then
          set(xx, yy, role, strength)
        end
      end
    end
  end
  p.line = function(x1, y1, x2, y2, role, strength)
    local n = math.max(math.abs(x2 - x1), math.abs(y2 - y1), 1)
    for i = 0, n do
      set(x1 + (x2 - x1) * i / n + 0.5, y1 + (y2 - y1) * i / n + 0.5, role, strength)
    end
  end
  p.flush = function()
    for cy = 0, ctx.height - 1 do
      for x = 0, w - 1 do
        local top, bottom = grid[cy * 2 * w + x], grid[(cy * 2 + 1) * w + x]
        if top and bottom then
          put(x, cy, top == bottom and "█" or "▀", top)
        elseif top then
          put(x, cy, "▀", top)
        elseif bottom then
          put(x, cy, "▄", bottom)
        end
      end
    end
  end
  return p
end

local banner, banner_width, banner_text
local scroll = 0
local ticker_scroll = 0
local signals = {}
-- when the build went red, the clock time it did and how many failing runs in a row, all known
-- only once the watch mode has called a hook on this scene, so a scene run on its own never
-- guesses a time
local failed_at = nil
local failed_time = nil
local fails = 0

-- the words in the big banner, with the time of the result once it is known
local function banner_words()
  if failed_time then
    return "build failed at " .. failed_time .. "  ·  one thing at a time  ·  "
  end
  return "build failed  ·  one thing at a time  ·  "
end

-- the board in cells: the rows its traces run along, which one is broken and where the gap is
local function board(ctx)
  local w, h = ctx.width, ctx.height
  local top = math.max(8, math.floor(h / 6) + 7)
  local bottom = h - 6
  local count = math.max(2, math.min(5, math.floor((bottom - top) / 3) + 1))
  local traces = {}
  for i = 1, count do
    local y = top + math.floor((i - 1) * (bottom - top) / math.max(1, count - 1))
    traces[i] = { y = y, broken = i == math.floor(count / 2) + 1 }
  end
  return traces, math.floor(w * 0.62)
end

local function reset_signals(ctx)
  signals = {}
  local traces = board(ctx)
  for i = 1, #traces do
    signals[i] = { x = -ctx.random(0, 30), wait = 0 }
  end
end

-- minutes and seconds, padded so the ticker keeps its length as the clock counts up
local function stopwatch(seconds)
  local s = math.floor(seconds)
  return string.format("%2d:%02d", math.floor(s / 60), s % 60)
end

return {
  name = "build-failed",
  kind = "fail",
  summary = "BUILD FAILED scrolling slowly over a pixel circuit board with one broken trace",
  captions = {
    "Build failed. One thing at a time.",
    "Something to fix. Read the first error.",
    "Not green yet. Breathe, then look.",
  },

  init = function(ctx)
    reset_signals(ctx)
  end,

  resize = function(ctx)
    reset_signals(ctx)
  end,

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local px = painter(ctx)
    local traces, gap = board(ctx)
    local chip = w - 16

    local words = banner_words()
    if words ~= banner_text then
      banner_text = words
      banner, banner_width = layout(words)
    end

    -- the board itself, a faint green with a slightly stronger edge
    local top = (traces[1].y - 3) * 2
    local bottom = (traces[#traces].y + 2) * 2
    px.rect(1, top, w - 2, bottom - top, "green", 0.1)
    px.line(1, top, w - 2, top, "green", 0.3)
    px.line(1, bottom, w - 2, bottom, "green", 0.3)

    -- each trace in copper with a pad at the start, a resistor with its bands and a capacitor
    for i, trace in ipairs(traces) do
      local y = trace.y * 2
      if trace.broken then
        px.line(4, y, gap - 2, y, "yellow", 0.7)
        px.line(gap + 3, y, chip, y, "yellow", 0.7)
        -- the two ends of the break, marked
        px.rect(gap - 3, y - 1, 3, 3, "error", 1)
        px.rect(gap + 2, y - 1, 3, 3, "error", 1)
      else
        px.line(4, y, chip, y, "yellow", 0.7)
      end
      -- square pads, as on a real board; small discs come out as plus shapes in pixels
      px.rect(3, y - 2, 5, 5, "yellow", 1)
      px.rect(4, y - 1, 3, 3, "green", 0.1)
      local r = math.floor(w * (0.18 + 0.07 * (i % 3)))
      px.rect(r, y - 1, 9, 3, "syntax.function", 0.8)
      for b = 0, 2 do
        px.rect(r + 2 + b * 2, y - 1, 1, 3, BANDS[(i + b) % #BANDS + 1], 1)
      end
      local c = math.floor(w * (0.42 + 0.05 * (i % 2)))
      px.rect(c, y - 2, 4, 5, "green", 0.1)
      px.line(c, y - 2, c, y + 2, "text", 0.9)
      px.line(c + 3, y - 2, c + 3, y + 2, "text", 0.9)
    end

    -- the chip every trace runs into, with a pin for each
    local chip_top = (traces[1].y - 1) * 2
    local chip_bottom = (traces[#traces].y + 1) * 2
    px.rect(chip, chip_top, 9, chip_bottom - chip_top, "grey", 0.6)
    px.pixel(chip + 1, chip_top + 1, "text", 1)
    for _, trace in ipairs(traces) do
      px.line(chip + 9, trace.y * 2, w - 3, trace.y * 2, "yellow", 0.7)
      px.rect(w - 4, trace.y * 2 - 1, 3, 3, "yellow", 1)
    end

    -- signals run left to right with a fading tail; on the broken trace one stops at the gap,
    -- waits, then the next one sets off from the left
    for i, trace in ipairs(traces) do
      local s = signals[i]
      if s then
        if s.wait > 0 then
          s.wait = s.wait - ctx.dt
          if s.wait <= 0 then
            s.x = 4
          end
        else
          s.x = s.x + ctx.dt * SIGNAL_RATE * ctx.speed
          if trace.broken and s.x >= gap - 4 then
            s.x = gap - 4
            s.wait = WAIT
          elseif s.x > chip - 2 then
            s.x = 4 - ctx.random(0, 20)
          end
        end
        local sx = math.floor(s.x)
        if sx >= 6 then
          local head = trace.broken and "warning" or "bright_cyan"
          local tail = trace.broken and "warning" or "info"
          for k = 1, 4 do
            px.pixel(sx - k, trace.y * 2, tail, 1 - k * 0.2)
          end
          px.rect(sx, trace.y * 2 - 1, 2, 3, head, 1)
        end
      end
    end
    px.flush()

    -- labels above the parts and clear of their bodies, then the question mark under the gap
    for i, trace in ipairs(traces) do
      local r = math.floor(w * (0.18 + 0.07 * (i % 3)))
      local c = math.floor(w * (0.42 + 0.05 * (i % 2)))
      put(r + 3, trace.y - 2, "R" .. i, "text")
      put(c, trace.y - 2, "C" .. i, "text")
      if trace.broken then
        put(gap, trace.y + 1, "?", "warning")
      end
    end
    put(chip + 3, traces[1].y - 2, "U1", "text")

    -- the banner across the top
    local by = math.max(1, math.floor(h / 6) - 1)
    scroll = scroll + ctx.dt * BANNER_RATE * ctx.speed
    draw_banner(banner, banner_width, math.floor(scroll), by, w, "error")

    -- the ticker two rows up from the bottom, so the watch mode's status bar never hides it.
    -- The tip changes once per failing run, not on a timer
    local tip = TIPS[math.max(0, fails - 1) % #TIPS + 1]
    local parts = "build failed"
    if failed_time then
      parts = parts .. " at " .. failed_time
    end
    parts = parts .. "  ·  "
    if failed_at then
      parts = parts .. "failing for " .. stopwatch(t - failed_at) .. "  ·  "
    end
    if fails > 1 then
      parts = parts .. string.format("%d failing runs in a row", fails) .. "  ·  "
    end
    local text = chars(parts .. tip .. "  ·  ")
    ticker_scroll = ticker_scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(ticker_scroll)
    local out = {}
    for x = 1, w do
      out[x] = text[(x - 1 + offset) % #text + 1]
    end
    put(0, h - 4, string.rep("─", w), "grey")
    put(0, h - 3, table.concat(out), "warning")
  end,

  on_fail = function(ctx)
    -- the clock keeps running from the first failure, while the time shown is the latest one
    failed_at = failed_at or ctx.time
    failed_time = ctx.clock and ctx.clock.time or failed_time
    fails = fails + 1
    if fails > 1 then
      local tip = TIPS[(fails - 1) % #TIPS + 1]
      return "Still failing. " .. tip:sub(1, 1):upper() .. tip:sub(2) .. "."
    end
  end,
}
