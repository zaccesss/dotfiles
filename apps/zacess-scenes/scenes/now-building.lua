-- now-building: a station departure board for my projects. The rows turn over like split flaps
-- every few seconds and a ticker along the bottom scrolls each project with its tagline.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set.

-- seconds between board updates
local BOARD_PERIOD = 10
-- seconds between one column settling and the next, so an update sweeps left to right
local SWEEP = 0.012
-- flap changes a second while a cell turns over; ctx.pace keeps it slow on calm motion
local FLAP_RATE = 12
-- cells a second the ticker moves at standard motion
local TICKER_RATE = 8

-- each project: platform, name, where it is heading and how it stands, with the role for the
-- status. The status word carries the meaning, so the colour is never the only signal
local PROJECTS = {
  { "1", "ZACESS", "accessibility tools that follow your theme", "ON TIME", "green" },
  { "2", "PHAEMOS", "predictive maintenance for IoT machines", "IN BUILD", "info" },
  { "3", "LIDARSAT", "drone navigation where GPS cannot reach", "TESTING", "warning" },
  { "4", "FOOTPRINTS", "every change on your machine, with undo", "SHIPPED", "accent" },
  { "5", "VITAFOLIO", "one CV, tailored for every application", "IN BUILD", "info" },
  { "6", "ZACESS SCENES", "calm scenes for the terminal", "ON TIME", "green" },
  { "7", "ZACESS PROFILE", "one accessibility profile for every app", "IN REVIEW", "warning" },
  { "8", "ISAACADJEI.ME", "the portfolio, the blog and the newsletter", "LIVE", "green" },
}

-- what a cell shows while it turns over, in the case of the letter it is turning to, so a row
-- keeps its shape while it changes
local FLAPS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local FLAPS_LOWER = FLAPS:lower()

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

local title, title_width
local rows = {}
local first = 1
local board_clock = 0
local scroll = 0
local ticker, ticker_roles

-- the board's columns for the current width: where each field starts and how wide it is
local function columns(w)
  local inner = w - 4
  local plat, name, status = 4, 16, 11
  local dest = inner - plat - name - status - 4
  if dest < 12 then
    -- too narrow for the taglines: platform, name and status only
    return { plat = plat, name = math.max(8, inner - plat - status - 3), dest = 0, status = status }
  end
  return { plat = plat, name = name, dest = dest, status = status }
end

-- pads or cuts a list of characters to an exact width
local function fit(list, width)
  local out = {}
  for i = 1, width do
    out[i] = list[i] or " "
  end
  return out
end

-- one board row as characters with a role for each, ready to be turned over into place
local function row_cells(project, cols)
  local cells, roles = {}, {}
  local function add(text, width, role)
    for _, ch in ipairs(fit(chars(text), width)) do
      cells[#cells + 1] = ch
      roles[#roles + 1] = role
    end
    cells[#cells + 1] = " "
    roles[#roles + 1] = role
  end
  add(" " .. project[1], cols.plat, "muted")
  add(project[2], cols.name, "bright")
  if cols.dest > 0 then
    -- a tagline too long for its column is cut at a word and marked, never mid-word
    local dest = project[3]
    if #dest > cols.dest then
      dest = dest:sub(1, cols.dest - 3):match("^(.*%S)%s") or dest:sub(1, cols.dest - 3)
      dest = dest .. "..."
    end
    add(dest, cols.dest, "text")
  end
  add(project[4], cols.status, project[5])
  return cells, roles
end

-- sets every row's target to the projects from first onwards; cells that differ start to turn
local function retarget(ctx, now, instant)
  local cols = columns(ctx.width)
  local count = math.max(1, math.min(#PROJECTS, math.floor((ctx.height - 13) / 2)))
  for i = 1, count do
    local project = PROJECTS[(first + i - 2) % #PROJECTS + 1]
    local cells, roles = row_cells(project, cols)
    local row = rows[i]
    if not row or instant or #row.shown ~= #cells then
      row = { shown = {}, settle = {} }
      for c = 1, #cells do
        row.shown[c] = instant and cells[c] or " "
        row.settle[c] = now + c * SWEEP
      end
      rows[i] = row
    else
      for c = 1, #cells do
        if row.shown[c] ~= cells[c] then
          -- a little delay per row too, so the board ripples downwards
          row.settle[c] = now + c * SWEEP + i * 0.08 + ctx.random() * 0.15
        end
      end
    end
    row.target, row.roles = cells, roles
  end
  for i = count + 1, #rows do
    rows[i] = nil
  end
end

local function build_ticker()
  ticker, ticker_roles = {}, {}
  local function add(text, role)
    for _, ch in ipairs(chars(text)) do
      ticker[#ticker + 1] = ch
      ticker_roles[#ticker_roles + 1] = role
    end
  end
  for _, project in ipairs(PROJECTS) do
    add(project[2], "bright")
    add("  " .. project[3], "text")
    add("  ·  ", "grey")
  end
end

-- draws a list of characters with a role each as runs of one role, so a frame stays small
local function draw_runs(x0, y, list, roles)
  local start, role = 1, roles[1]
  for i = 2, #list + 1 do
    if i > #list or roles[i] ~= role then
      put(x0 + start - 1, y, table.concat(list, "", start, i - 1), role)
      start, role = i, roles[i]
    end
  end
end

return {
  name = "now-building",
  kind = "general",
  summary = "A split-flap departure board of my projects with a scrolling ticker of taglines",
  captions = {
    "All services running on time.",
    "Clean build. Next stop, the next feature.",
    "Every platform green.",
  },

  init = function(ctx)
    title, title_width = layout("NOW BUILDING")
    build_ticker()
    retarget(ctx, 0, true)
  end,

  resize = function(ctx)
    retarget(ctx, ctx.time, true)
  end,

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local now = ctx.time

    -- the board moves on one project at a time
    board_clock = board_clock + ctx.dt
    if board_clock >= BOARD_PERIOD then
      board_clock = board_clock - BOARD_PERIOD
      first = first % #PROJECTS + 1
      retarget(ctx, now, false)
    end

    -- the title in the big font, centred when it fits and scrolling slowly when it does not
    local tx = math.floor((w - title_width) / 2)
    if tx >= 0 then
      draw_banner(title, title_width, -tx, 1, w, "warning", true)
    else
      draw_banner(title, title_width, math.floor(now * 4 * ctx.speed), 1, w, "warning")
    end

    -- the board's frame
    local top = 6
    local bottom = h - 4
    local cols = columns(w)
    put(1, top, "┌" .. string.rep("─", w - 4) .. "┐", "grey")
    put(1, bottom, "└" .. string.rep("─", w - 4) .. "┘", "grey")
    for y = top + 1, bottom - 1 do
      put(1, y, "│", "grey")
      put(w - 2, y, "│", "grey")
    end

    -- the column headings and a rule under them
    local head = { " PL", "PROJECT", "DESTINATION", "STATUS" }
    local hx = 2
    put(hx, top + 1, head[1], "muted")
    hx = hx + cols.plat + 1
    put(hx, top + 1, head[2], "muted")
    hx = hx + cols.name + 1
    if cols.dest > 0 then
      put(hx, top + 1, head[3], "muted")
      hx = hx + cols.dest + 1
    end
    put(hx, top + 1, head[4], "muted")
    put(2, top + 2, string.rep("─", w - 4), "grey")

    -- the rows: a cell past its settle time shows its letter, one before it turns over through
    -- the flap letters. Under reduced motion it simply waits and then appears in its place
    for i, row in ipairs(rows) do
      local y = top + 2 + i * 2 - 1
      if y >= bottom then
        break
      end
      for c = 1, #row.target do
        if now >= row.settle[c] then
          row.shown[c] = row.target[c]
        end
      end
      local list = {}
      for c = 1, #row.target do
        if row.shown[c] ~= row.target[c] and not ctx.reduced and row.target[c] ~= " " then
          local set = row.target[c]:match("%l") and FLAPS_LOWER or FLAPS
          local k = math.floor(now * FLAP_RATE * ctx.pace + c * 7) % #set + 1
          list[c] = set:sub(k, k)
        else
          list[c] = row.shown[c]
        end
      end
      draw_runs(2, y, list, row.roles)
    end

    -- the time to the next update, counted down honestly from the board's own clock
    local left = math.ceil(BOARD_PERIOD - board_clock)
    local note = string.format("next update in %2d s", left)
    put(w - 3 - #note, bottom - 1, note, "muted")
    put(3, bottom - 1, "zaccesss  ·  all platforms", "muted")

    -- the ticker under the board, a calling-at list of every project
    scroll = scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(scroll)
    local list, roles = {}, {}
    local n = #ticker
    for x = 1, w - 4 do
      local k = (x - 1 + offset) % n + 1
      list[x], roles[x] = ticker[k], ticker_roles[k]
    end
    put(2, h - 2, "calling at", "syntax.keyword")
    draw_runs(14, h - 2, { table.unpack(list, 1, math.max(1, w - 16)) }, roles)
  end,

  on_fail = function(ctx)
    return "A delay on one line. Check the board."
  end,

  on_recovered = function(ctx)
    return "Services restored. Back on time."
  end,
}
