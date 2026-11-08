-- phaemos: a pixel motor and pump on a test bed with four PHAEMOS sensor nodes on them. Readings
-- travel along the bus to the gateway and a panel beside it draws each node's vibration as a
-- scrolling chart. One bearing slowly wears, turns to WATCH and gets a service estimate, then is
-- serviced and starts again: predictive maintenance in one loop.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It paints
-- with the pixel canvas; an older Zacess Scenes without one draws the same shapes in half blocks.

-- seconds between readings on every node
local SAMPLE_PERIOD = 0.5
-- seconds between one node sending a packet and sending the next
local SEND_PERIOD = 2.4
-- cells a second a packet travels along the bus
local PACKET_RATE = 14
-- steps a second the stripe on the coupling moves, so the shaft reads as turning without blinking
local SPIN_RATE = 4
-- seconds for the worn bearing to go from serviced to due and be serviced again
local WEAR_CYCLE = 150
-- vibration in mm/s where a node turns to WATCH and where it is due for service
local WATCH_LEVEL = 4.5
local SERVICE_LEVEL = 7.1
-- cells a second the ticker moves
local TICKER_RATE = 7

local TICKER = "PHAEMOS  ·  predictive maintenance for IoT machines  ·  four sensor nodes on one bus  ·  vibration, temperature and current  ·  catch the fault before the breakdown  ·  "

-- each node: label, where it sits, its usual vibration and the role its packets take
local NODES = {
  { name = "N1", where = "motor, drive end", base = 1.8, role = "cyan" },
  { name = "N2", where = "motor, free end", base = 1.4, role = "green" },
  { name = "N3", where = "pump bearing", base = 2.0, role = "magenta" },
  { name = "N4", where = "pump casing", base = 1.6, role = "blue" },
}

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
local function layout_text(message)
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
local history = {}
local sample_clock = 0
local packets = {}
local send_clock = {}
local ticker_scroll = 0

-- a string as a list of characters, so text with a middle dot slices by character, not byte
local function chars(s)
  local list = {}
  for _, code in utf8.codes(s) do
    list[#list + 1] = utf8.char(code)
  end
  return list
end

local ticker = chars(TICKER)

-- how worn the bearing is, from 0 just after a service to 1 when it is due
local function wear(t)
  return (t % WEAR_CYCLE) / WEAR_CYCLE
end

-- a node's vibration now: its usual level, a little noise and, on the bearing, the wear
local function reading(ctx, i, t)
  local node = NODES[i]
  local v = node.base + 0.5 * math.sin(t * 0.9 + i) + 0.3 * math.sin(t * 2.3 + i * 2) + (ctx.random() - 0.5) * 0.7
  -- the history filled in before the scene starts is from just after the last service
  if i == 3 and t >= 0 then
    v = v + 5.5 * wear(t) ^ 2
  end
  return math.max(0.2, v)
end

local function fill_history(ctx)
  for i = 1, #NODES do
    history[i] = history[i] or {}
    send_clock[i] = send_clock[i] or (i - 1) * SEND_PERIOD / #NODES
    while #history[i] < 200 do
      table.insert(history[i], 1, reading(ctx, i, -#history[i] * SAMPLE_PERIOD))
    end
  end
end

-- the diagram's layout for the current size: where the machine, the nodes, the bus and the
-- gateway sit
local function layout(ctx)
  local top = 4
  local mx = 3
  local motor_w = 22
  local pump_x = mx + motor_w + 7
  local pump_w = 14
  local gx = pump_x + pump_w + 3
  return {
    bus = top,
    node_y = top + 2,
    box = top + 4,
    mx = mx,
    motor_w = motor_w,
    pump_x = pump_x,
    pump_w = pump_w,
    gx = gx,
    node_x = { mx + 4, mx + motor_w - 7, pump_x + 1, pump_x + pump_w - 5 },
    panel = gx + 14,
  }
end

return {
  name = "phaemos",
  kind = "general",
  summary = "PHAEMOS nodes on a motor and pump, sending vibration readings to a live panel",
  captions = {
    "All nodes healthy. Build healthy.",
    "No faults predicted.",
    "Every reading in range.",
  },

  init = function(ctx)
    title, title_width = layout_text("PHAEMOS")
    fill_history(ctx)
  end,

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local L = layout(ctx)

    -- a new reading on every node, on a steady clock
    sample_clock = sample_clock + ctx.dt * ctx.speed
    while sample_clock >= SAMPLE_PERIOD do
      sample_clock = sample_clock - SAMPLE_PERIOD
      for i = 1, #NODES do
        table.insert(history[i], reading(ctx, i, t))
        if #history[i] > 200 then
          table.remove(history[i], 1)
        end
      end
    end

    -- the motor, the coupling and the pump on a base plate, in pixels
    local paint = painter(ctx)
    local by = L.box
    local mx, mw = L.mx, L.motor_w
    local top, body = by * 2, 9
    paint.rect(mx, top, mw, body, "syntax.type", 0.5)
    paint.rect(mx, top, 3, body, "syntax.type", 0.8)
    -- cooling fins along the body, every other pixel
    for x = mx + 4, mx + mw - 2, 2 do
      paint.line(x, top + 1, x, top + body - 2, "syntax.type", 0.85)
    end
    paint.line(mx, top, mx + mw - 1, top, "syntax.type", 1)
    local shaft_y = top + 4
    local pump_x, pump_w = L.pump_x, L.pump_w
    paint.line(mx + mw, shaft_y, pump_x, shaft_y, "grey", 1)
    -- the coupling with a stripe that steps round it, so the shaft reads as turning
    local cx = mx + mw + 2
    paint.rect(cx, shaft_y - 2, 3, 5, "text", 0.7)
    if not ctx.reduced then
      local turn = math.floor(t * SPIN_RATE * ctx.pace) % 5
      paint.line(cx, shaft_y - 2 + turn, cx + 2, shaft_y - 2 + turn, "bright", 1)
    end
    -- the pump: a round volute with its outlet on the far side
    local vx, vy = pump_x + math.floor(pump_w / 2), shaft_y
    paint.disc(vx, vy, 5, "syntax.type", 0.5)
    paint.disc(vx, vy, 2, "syntax.type", 0.9)
    paint.rect(pump_x + pump_w - 2, vy - 1, 3, 3, "syntax.type", 0.7)
    -- the base plate and its feet
    local base_y = top + body + 1
    paint.rect(mx - 1, base_y, pump_x + pump_w - mx + 2, 2, "grey", 0.75)
    paint.rect(mx + 1, top + body, 2, 1, "grey", 0.75)
    paint.rect(mx + mw - 3, top + body, 2, 1, "grey", 0.75)
    paint.rect(vx - 1, vy + 5, 3, base_y - vy - 5, "grey", 0.75)

    -- the nodes on the machine, each wired up to the bus
    for i, node in ipairs(NODES) do
      local nx = L.node_x[i]
      put(nx, L.node_y, "[" .. node.name .. "]", node.role)
      put(nx + 1, L.node_y + 1, "│", "grey")
      put(nx + 1, L.node_y - 1, "│", "grey")
    end
    put(L.node_x[1] + 1, L.bus, string.rep("─", L.gx - L.node_x[1] - 1), "grey")
    for i = 1, #NODES do
      put(L.node_x[i] + 1, L.bus, i == 1 and "┌" or "┬", "grey")
    end

    -- the gateway the bus runs into
    local gx = L.gx
    put(gx, L.bus - 1, "┌─────────┐", "syntax.function")
    put(gx, L.bus, "┤ GATEWAY │", "syntax.function")
    put(gx, L.bus + 1, "└────┬────┘", "syntax.function")
    put(gx + 5, L.bus + 2, "│", "grey")
    put(gx + 2, L.bus + 3, "to cloud", "muted")

    -- packets: up from each node to the bus, then along it into the gateway
    for i = 1, #NODES do
      send_clock[i] = send_clock[i] - ctx.dt * ctx.speed
      if send_clock[i] <= 0 then
        send_clock[i] = send_clock[i] + SEND_PERIOD
        packets[#packets + 1] = { node = i, s = 0 }
      end
    end
    local kept = {}
    for _, p in ipairs(packets) do
      p.s = p.s + ctx.dt * PACKET_RATE * ctx.speed
      local nx = L.node_x[p.node] + 1
      local x, y
      if p.s < 1 then
        x, y = nx, L.node_y - 1
      else
        x, y = nx + math.floor(p.s - 1), L.bus
      end
      if x < gx then
        put(x, y, "o", NODES[p.node].role)
        kept[#kept + 1] = p
      end
    end
    packets = kept

    -- the panel: a heading, then each node's level, status and sparkline
    local panel = L.panel
    local pwid = w - panel - 2
    -- each chart is three rows of eighth blocks, so a reading has 24 steps of height
    local chart, gap, row = 3, 3, 4
    local stacked = pwid < 30
    if stacked then
      -- too narrow to sit beside the machine: the panel goes under it with one-row charts
      panel, pwid = L.mx, w - L.mx - 2
      chart, gap, row = 1, 1, L.box + 7
    end
    if pwid >= 20 then
      if not stacked then
        put(panel, 2, "vibration  mm/s RMS", "muted")
      end
      for i, node in ipairs(NODES) do
        if row + chart >= h - 3 then
          break
        end
        local hist = history[i]
        local now = hist[#hist]
        local status, role = "OK", "green"
        if now >= SERVICE_LEVEL then
          status, role = "SERVICE", "error"
        elseif now >= WATCH_LEVEL then
          status, role = "WATCH", "warning"
        end
        put(panel, row, node.name, node.role)
        put(panel + 4, row, node.where, "text")
        local value = string.format("%4.1f  %s", now, status)
        put(panel + pwid - #value, row, string.format("%4.1f", now), "bright")
        put(panel + pwid - #status, row, status, role)
        -- the chart in pixels: a filled area with a firmer top edge, two pixels to a row
        local start = #hist - pwid + 1
        local ch = chart * 2
        local base = (row + 1 + chart) * 2
        local fill = status == "OK" and "syntax.string" or role
        for k = 1, pwid do
          local v = hist[start + k - 1] or 0
          -- a square root scale keeps the small everyday wobble visible beside a worn bearing
          local tall = math.max(1, math.min(ch, math.floor(math.sqrt(v / 8) * ch + 0.5)))
          paint.rect(panel + k - 1, base - tall, 1, tall, fill, 0.45)
          paint.pixel(panel + k - 1, base - tall, fill, 1)
        end
        row = row + chart + gap
      end
      -- the prediction for the worn bearing, from how fast it is climbing
      local left = (1 - wear(t)) * WEAR_CYCLE
      local note
      if wear(t) < 0.35 then
        note = "all nodes healthy, no service due"
      else
        note = string.format("N3 service due in about %d days", math.max(1, math.floor(left / 6)))
      end
      if row < h - 3 then
        put(panel, row, note, wear(t) < 0.35 and "muted" or "warning")
      end
    end

    paint.flush()

    -- the name in the big font in the space under the machine
    local ty = L.box + 8
    if not stacked and ty + 6 < h - 3 then
      draw_banner(title, title_width, -L.mx, ty, L.panel - 2, "accent", true)
      put(L.mx, ty + 5, "predictive maintenance, one node at a time", "syntax.comment")
    end

    -- the ticker on the bottom row but one
    ticker_scroll = ticker_scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(ticker_scroll)
    local out = {}
    for x = 1, w - 4 do
      out[x] = ticker[(x - 1 + offset) % #ticker + 1]
    end
    put(2, h - 2, table.concat(out), "syntax.function")
  end,

  on_fail = function(ctx)
    return "A fault on the line. Time for maintenance."
  end,

  on_recovered = function(ctx)
    return "Serviced and running sweetly again."
  end,
}
