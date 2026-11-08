-- build-passed: my own pass scene for the build watcher. BUILD PASSED scrolls across the top in
-- the big font with the time of the result, under pixel bunting with confetti tumbling slowly
-- down. A ticker near the bottom says when it passed, how long it has been green and how many
-- passing runs came in a row.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It reads the
-- time from ctx.clock and paints with the pixel canvas; on an older Zacess Scenes without them it
-- leaves the time out and draws the same shapes in half-block characters.

-- cells a second the big banner moves at standard motion
local BANNER_RATE = 9
-- cells a second the ticker moves
local TICKER_RATE = 7
-- confetti falls this many pixels a second at most; slow, so it drifts rather than rains
local FALL_RATE = 4.5
-- seconds for a piece of confetti to sway from side to side
local SWAY_PERIOD = 4
-- seconds between a piece turning from flat to edge on, slowed by ctx.pace
local TUMBLE_PERIOD = 0.9

-- the roles the confetti and the pennants take in turn
local COLOURS = { "bright_green", "bright_yellow", "bright_cyan", "bright_magenta", "accent", "green" }

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
local confetti = {}
-- when the build went green, the clock time it did and how many passing runs in a row, all known
-- only once the watch mode has called a hook on this scene. A scene run on its own or one the
-- rotation has just swapped in never guesses a time it was not there for
local passed_at = nil
local passed_time = nil
local streak = 0

-- the words in the big banner, with the time of the result once it is known
local function banner_words()
  if passed_time then
    return "✓ build passed at " .. passed_time .. "  ·  all green  ·  "
  end
  return "✓ build passed  ·  all green  ·  "
end

-- a garland of pennants on a sagging string from one side of the screen to the other, in pixels
local function bunting(px, top, sag)
  local pw = px.width
  local mid = (pw - 1) / 2
  local function rope(x)
    local d = (x - mid) / mid
    return top + math.floor(sag * (1 - d * d) + 0.5)
  end
  for x = 0, pw - 2 do
    px.line(x, rope(x), x + 1, rope(x + 1), "grey", 0.7)
  end
  for x = 5, pw - 5, 11 do
    local y = rope(x) + 1
    local role = COLOURS[(x // 11) % #COLOURS + 1]
    px.rect(x - 3, y, 7, 1, role, 1)
    px.rect(x - 2, y + 1, 5, 1, role, 1)
    px.rect(x - 1, y + 2, 3, 1, role, 1)
    px.pixel(x, y + 3, role, 1)
  end
end

local function scatter(ctx)
  confetti = {}
  local count = math.max(10, math.floor(ctx.width * ctx.height / 40 * ctx.busy))
  if ctx.reduced then
    count = math.floor(count / 2)
  end
  for i = 1, count do
    confetti[i] = {
      x = ctx.random() * ctx.width,
      y = ctx.random() * ctx.height * 2,
      fall = (0.4 + ctx.random() * 0.6) * FALL_RATE,
      phase = ctx.random() * 6.28,
      role = COLOURS[ctx.random(#COLOURS)],
    }
  end
end

-- minutes and seconds, padded so the ticker keeps its length as the clock counts up
local function stopwatch(seconds)
  local s = math.floor(seconds)
  return string.format("%2d:%02d", math.floor(s / 60), s % 60)
end

return {
  name = "build-passed",
  kind = "pass",
  summary = "BUILD PASSED in big letters with the time, bunting and tumbling pixel confetti",
  captions = {
    "Build passed. Nice work, Isaac.",
    "All green. Ship it when ready.",
    "Clean run. On to the next thing.",
  },

  init = function(ctx)
    scatter(ctx)
  end,

  resize = function(ctx)
    scatter(ctx)
  end,

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local px = painter(ctx)
    local ph = px.height

    local words = banner_words()
    if words ~= banner_text then
      banner_text = words
      banner, banner_width = layout(words)
    end
    local by = math.max(4, math.floor(h / 6) + 1)

    -- confetti behind everything, kept out of the banner's band and the ticker's, falling
    -- slowly, swaying and turning between flat and edge on
    for _, c in ipairs(confetti) do
      c.y = c.y + c.fall * ctx.speed * ctx.dt
      if c.y >= ph then
        c.y = c.y - ph
        c.x = ctx.random() * w
      end
      local sway = math.sin(t * 2 * math.pi / SWAY_PERIOD * ctx.pace + c.phase) * 1.5
      local x, y = math.floor(c.x + sway), math.floor(c.y)
      local band = (y >= (by - 1) * 2 and y < (by + 5) * 2) or y >= (h - 4) * 2
      if not band then
        local flat = ctx.reduced or math.floor(t / TUMBLE_PERIOD * ctx.pace + c.phase) % 2 == 0
        if flat then
          px.rect(x, y, 2, 1, c.role, 1)
        else
          px.rect(x, y, 1, 2, c.role, 1)
        end
      end
    end

    -- two garlands, one above the banner and one sagging lower across the middle
    bunting(px, 1, 4)
    bunting(px, math.floor(ph * 0.5), 6)
    px.flush()

    scroll = scroll + ctx.dt * BANNER_RATE * ctx.speed
    draw_banner(banner, banner_width, math.floor(scroll), by, w, "bright_green")

    -- the ticker two rows up from the bottom, so the watch mode's status bar never hides it
    local parts = "build passed"
    if passed_time then
      parts = parts .. " at " .. passed_time
    end
    parts = parts .. "  ·  "
    if passed_at then
      parts = parts .. "green for " .. stopwatch(t - passed_at) .. "  ·  "
    end
    if streak > 1 then
      parts = parts .. string.format("%d green runs in a row", streak) .. "  ·  "
    end
    local text = chars(parts .. "all green  ·  nice work, Isaac  ·  ")
    ticker_scroll = ticker_scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(ticker_scroll)
    local out = {}
    for x = 1, w do
      out[x] = text[(x - 1 + offset) % #text + 1]
    end
    put(0, h - 4, string.rep("─", w), "grey")
    put(0, h - 3, table.concat(out), "green")
  end,

  on_pass = function(ctx)
    -- a pass after a pass keeps the build green, so the clock keeps running from the first
    -- one, while the time shown is the latest result
    passed_at = passed_at or ctx.time
    passed_time = ctx.clock and ctx.clock.time or passed_time
    streak = streak + 1
    if streak > 1 then
      return string.format("Passed again. %d in a row.", streak)
    end
  end,

  on_recovered = function(ctx)
    passed_at = ctx.time
    passed_time = ctx.clock and ctx.clock.time or nil
    streak = 1
    return "Fixed and green. Well done."
  end,
}
