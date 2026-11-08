-- hello-isaac: a big scrolling greeting for the time of day with the date, over a pixel sky with
-- soft clouds, the sun or the moon in its place and rolling hills with trees. A line under the
-- greeting turns over to a different project of mine every few seconds.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It reads the
-- local time from ctx.clock and paints with the pixel canvas; on an older Zacess Scenes without
-- them it says a plain hello and draws the same shapes in half-block characters.

-- cells a second the big banner moves at standard motion; ctx.speed slows it on calm and under
-- reduced motion, so it stays readable
local BANNER_RATE = 9
-- seconds each project line stays before the next one is typed over it
local LINE_PERIOD = 9
-- characters a second the next project line is typed over the last one
local TYPE_RATE = 24
-- pixels a second the far hills, the near hills and the clouds drift
local FAR_RATE = 0.5
local NEAR_RATE = 1.4
local CLOUD_RATE = 0.8

local WHO = "Isaac Adjei  ·  Electronic Engineering and Computer Science  ·  Aston, Birmingham"
local PROJECTS = {
  "Zacess: accessibility tools that follow your theme",
  "Zacess Scenes: calm scenes for the terminal, written in Rust",
  "Zacess Profile: one accessibility profile for every app",
  "PHAEMOS: predictive maintenance for real machines",
  "LidarSAT: drone navigation where GPS cannot reach",
  "Footprints: a local ledger of every change, with undo",
  "Vitafolio: one CV, tailored for every application",
  "isaacadjei.me: the portfolio, the blog and the newsletter",
}

-- each part of the day: its greeting, the sign-off after the date and the role that tints the sky
local PARTS = {
  morning = { "Good morning", "keep building kind things", "yellow" },
  afternoon = { "Good afternoon", "keep building kind things", "cyan" },
  evening = { "Good evening", "nice work today", "magenta" },
  night = { "Late night", "time to rest soon", "blue" },
}

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

-- the part of the day for an hour on the local clock
local function part_of_day(hour)
  if hour >= 5 and hour < 12 then
    return "morning"
  elseif hour >= 12 and hour < 17 then
    return "afternoon"
  elseif hour >= 17 and hour < 22 then
    return "evening"
  end
  return "night"
end

-- the banner text for now: the greeting and the date when the clock is known, a plain hello
-- when it is not, so an older version never shows a guess
local function greeting(ctx)
  local c = ctx.clock
  if not c then
    return "Hello, Isaac  ·  zaccesss  ·  keep building kind things  ·  ", nil
  end
  local now = part_of_day(c.hour)
  local words = PARTS[now]
  local date = c.weekday_name .. " " .. c.day .. " " .. c.month_name
  return words[1] .. ", Isaac  ·  " .. date .. "  ·  " .. words[2] .. "  ·  ", now
end

local banner, banner_width, banner_text
local part
local scroll = 0
local clouds = {}
local line, line_from, line_typed = 1, 1, 0
local line_clock = 0

-- each cloud is a few overlapping discs on a flat base, in pixels
local function place_clouds(ctx)
  clouds = {}
  local count = math.max(2, math.floor(ctx.width / 26 * ctx.busy))
  local gap = (ctx.width + 30) / count
  for i = 1, count do
    -- small discs come out as plus shapes in pixels, so every puff is at least three across
    local size = 3 + (i % 3)
    local puffs = {}
    for k = 1, 3 + (i % 2) do
      local middle = k == 2 or k == 3
      puffs[k] = {
        dx = (k - 1) * size * 1.5,
        dy = middle and -size * 0.6 or 0,
        r = size + (k == 2 and 1.5 or 0),
      }
    end
    clouds[i] = {
      x = (i - 1) * gap + ctx.random() * gap * 0.3,
      y = 5 + (i % 3) * 4,
      puffs = puffs,
      width = (#puffs - 1) * size * 1.5,
      rate = CLOUD_RATE * (0.8 + (i % 3) * 0.15),
    }
  end
end

-- the height of a hill layer in pixels at a point of the world, from a few slow waves
local function hill(x, base, swing, seed)
  local wave = 0.55 * math.sin(x / 38 + seed) + 0.3 * math.sin(x / 17 + seed * 2)
    + 0.15 * math.sin(x / 8 + seed * 3)
  return base + swing * wave
end

return {
  name = "hello-isaac",
  kind = "general",
  summary = "A scrolling greeting for the time of day over a pixel sky, hills and my projects",
  captions = {
    "Hello, Isaac. All good here.",
    "Clean build. Keep building kind things.",
    "All green. On to the next idea.",
  },

  init = function(ctx)
    place_clouds(ctx)
  end,

  resize = function(ctx)
    place_clouds(ctx)
  end,

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local px = painter(ctx)
    local pw, ph = px.width, px.height

    -- the greeting is laid out again only when its words change, which is rare
    local text, now_part = greeting(ctx)
    if text ~= banner_text then
      banner_text = text
      banner, banner_width = layout(text)
      part = now_part
    end
    local tint = part and PARTS[part][3] or "cyan"

    -- the sky: a faint wash of the part of the day, strongest down by the hills
    local hills = math.max(6, math.floor(ph / 5))
    local horizon = ph - hills * 2
    for y = 0, ph, 2 do
      px.rect(0, y, pw, 2, tint, 0.13 * math.min(1, y / horizon) ^ 1.6)
    end

    -- the sun across the sky by the hour or the moon at night, both well clear of the banner
    local c = ctx.clock
    if c then
      local hour = c.hour + c.minute / 60
      local sky_top, sky_low = 6, math.max(10, math.floor(ph / 2) - 16)
      if part == "night" then
        local nx = pw * 0.8
        px.disc(nx, sky_top + 5, 8, "text", 0.1)
        px.disc(nx, sky_top + 5, 5.5, "text", 0.85)
        -- a second disc in the sky's own colour cuts the full moon to a fat crescent
        px.disc(nx + 3, sky_top + 4, 4.5, tint, 0)
      else
        local day = math.min(1, math.max(0, (hour - 6) / 14))
        local sx = pw * (0.08 + 0.84 * day)
        local sy = sky_low - (sky_low - sky_top) * math.sin(day * math.pi)
        px.disc(sx, sy, 8, "yellow", 0.14)
        px.disc(sx, sy, 6, "yellow", 0.3)
        px.disc(sx, sy, 4, "bright_yellow", 1)
      end
    end

    -- clouds drift right to left and come back round on the right, keeping their spacing
    for _, cloud in ipairs(clouds) do
      cloud.x = cloud.x - cloud.rate * ctx.speed * ctx.dt
      if cloud.x < -cloud.width - 12 then
        cloud.x = cloud.x + pw + cloud.width + 24
      end
      for _, puff in ipairs(cloud.puffs) do
        px.disc(cloud.x + puff.dx, cloud.y + puff.dy, puff.r, "muted", 0.3)
      end
      -- the flat underside every cloud sits on
      px.rect(cloud.x, cloud.y, cloud.width, 3, "muted", 0.3)
    end

    -- two hill layers along the bottom, the far one fainter and slower, the near one with trees
    local far_shift = t * FAR_RATE * ctx.speed
    local near_shift = t * NEAR_RATE * ctx.speed + 80
    for x = 0, pw - 1 do
      local hf = math.floor(hill(x + far_shift, hills * 1.5, hills * 0.7, 1.3))
      px.rect(x, ph - hf, 1, hf, "grey", 0.28)
      px.pixel(x, ph - hf, "grey", 0.45)
    end
    for x = 0, pw - 1 do
      local wx = math.floor(x + near_shift)
      local hn = math.floor(hill(wx, hills * 0.85, hills * 0.5, 4.1))
      local top = ph - hn
      px.rect(x, top, 1, hn, "green", 0.5)
      px.rect(x, top, 1, 2, "green", 0.85)
      -- a tree every so often, fixed to its place in the world
      if wx % 29 == 0 and (wx // 29) % 3 ~= 1 then
        px.rect(x, top - 2, 1, 2, "yellow", 0.55)
        px.rect(x - 2, top - 4, 5, 2, "green", 1)
        px.rect(x - 1, top - 6, 3, 2, "green", 1)
        px.pixel(x, top - 7, "green", 1)
      end
    end
    px.flush()

    -- who and where, centred above the banner, with the time at the top right when it is known
    local banner_y = math.max(3, math.floor(h / 2) - 5)
    local who = chars(WHO)
    if #who > w - 10 then
      who = chars("Isaac Adjei  ·  zaccesss")
    end
    put(math.floor((w - #who) / 2), banner_y - 2, table.concat(who), "syntax.comment")
    if c then
      put(w - 7, 1, c.time, "muted")
    end

    -- the big greeting, scrolling right to left in whole cells
    scroll = scroll + ctx.dt * BANNER_RATE * ctx.speed
    draw_banner(banner, banner_width, math.floor(scroll), banner_y, w, "accent")

    -- a rule, then the project line typed over the last one a few characters at a time
    local line_y = banner_y + 6
    local rule = math.min(w - 4, 64)
    local rx = math.floor((w - rule) / 2)
    put(rx, line_y - 1, string.rep("─", rule), "grey")
    put(rx, line_y + 1, string.rep("─", rule), "grey")

    line_clock = line_clock + ctx.dt * ctx.pace
    if line_clock >= LINE_PERIOD then
      line_clock = line_clock - LINE_PERIOD
      line_from = line
      line = line % #PROJECTS + 1
      line_typed = 0
    end
    line_typed = line_typed + ctx.dt * TYPE_RATE * ctx.speed
    local new, old = chars(PROJECTS[line]), chars(PROJECTS[line_from])
    local width = math.max(#new, #old)
    local shown = {}
    local k = math.floor(line_typed)
    for i = 1, width do
      shown[i] = (i <= k and (new[i] or " ")) or old[i] or " "
    end
    local label = "now  "
    local line_text = table.concat(shown)
    local total = #label + width
    local lx = math.max(0, math.floor((w - total) / 2))
    put(lx, line_y, label, "syntax.keyword")
    -- the project name, before the colon, stands out from its tagline
    local colon = line_text:find(":")
    if colon then
      put(lx + #label, line_y, line_text:sub(1, colon), "bright")
      put(lx + #label + colon, line_y, line_text:sub(colon + 1), "text")
    else
      put(lx + #label, line_y, line_text, "text")
    end
  end,

  on_recovered = function(ctx)
    return "Fixed. Hello again, Isaac."
  end,
}
