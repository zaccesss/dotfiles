-- lidarsat: a pixel quadcopter flying over shaded hills and rooftops without GPS, sweeping a fan
-- of lidar rays at the ground. Every return stays on the land as a point, so a point cloud grows
-- behind the drone: the land it has mapped, with the land ahead still unmapped.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It paints
-- with the pixel canvas; an older Zacess Scenes without one draws the same shapes in half blocks.

-- pixels a second the ground moves under the drone at standard motion
local GROUND_RATE = 7
-- seconds for the fan to sweep from one side to the other and back
local SWEEP_PERIOD = 4
-- the widest the fan's centre leans from straight down and half the fan's width, in radians
local SWEEP_REACH = 0.75
local FAN_HALF = 0.32
-- rays cast across the fan each frame; each one that lands adds a point to the map
local RAYS = 7
-- seconds for one slow bob of the drone
local BOB_PERIOD = 5
-- how often the bright mark on each rotor moves on, a few pixels at a time, so it reads as spin
local SPIN_RATE = 6
-- seconds a return stays fresh, then seconds before it settles to the faintest shade
local FRESH = 1.5
local SETTLED = 8
-- the most points kept in the map
local MAX_POINTS = 4000
-- cells a second the caption ticker moves
local TICKER_RATE = 7

local TICKER = "LidarSAT  ·  GPS-denied drone navigation  ·  terrain-relative positioning from lidar returns  ·  ENGNERDS team project  ·  no satellites, just the ground  ·  "

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

local scroll = 0
local ticker_scroll = 0
local points = {}
local total_points = 0
local hud_clock = 0
local hud = {}

-- a string as a list of characters, so text with a middle dot slices by character, not byte
local function chars(s)
  local list = {}
  for _, code in utf8.codes(s) do
    list[#list + 1] = utf8.char(code)
  end
  return list
end

local ticker = chars(TICKER)

-- the ground's height in pixels above the bottom at a column of the world
local function ground(wx, base)
  return math.floor(base + 5 * math.sin(wx / 34) + 3 * math.sin(wx / 15) + 1.5 * math.sin(wx / 6.5))
end

-- a building at a column of the world: its height in pixels and where the column falls in the
-- block or nothing. A street of them passes every so often, like the urban canyon where GPS
-- drops out
local function building(wx)
  if math.floor(wx / 150) % 3 ~= 1 then
    return nil
  end
  local block = math.floor(wx / 13)
  local part = wx % 13
  if part >= 10 then
    return nil
  end
  local k = (block * 37 + 11) % 23
  if k >= 17 then
    return nil
  end
  return 10 + (k * 7) % 15, part
end

-- the top pixel the lidar can hit at a column of the world, roof or ground
local function surface(ph, wx, base)
  local top = ph - ground(wx, base)
  local tall = building(wx)
  if tall then
    top = top - tall
  end
  return top
end

-- the quadcopter, centred on a point in pixels. The far pair of rotors sits higher and fainter,
-- as seen from a little above, so all four arms read
local function draw_drone(px, x, y, t, ctx)
  local spin = ctx.reduced and 0 or math.floor(t * SPIN_RATE * ctx.pace)
  local rotors = {
    { -9, -6, 0.55 },
    { 9, -6, 0.55 },
    { -12, -3, 1 },
    { 12, -3, 1 },
  }
  -- arms from the body out to each rotor's motor
  for _, r in ipairs(rotors) do
    px.line(x + (r[1] < 0 and -3 or 3), y - 1, x + r[1], y + r[2] + 1, "grey", r[3])
    px.pixel(x + r[1], y + r[2] + 1, "grey", 1)
  end
  -- the rotors as flat blurred discs with one brighter blade mark moving round
  for i, r in ipairs(rotors) do
    local rx, ry = x + r[1], y + r[2]
    px.line(rx - 4, ry, rx + 4, ry, "info", r[3] * 0.75)
    local mark = (spin + i * 2) % 9 - 4
    px.pixel(rx + mark, ry, "bright", r[3])
    px.pixel(rx, ry, "text", r[3])
  end
  -- the body with its canopy, a light at the front and the lidar head underneath
  px.rect(x - 4, y - 2, 9, 3, "text", 0.9)
  px.rect(x - 2, y - 3, 5, 1, "text", 0.65)
  px.pixel(x + 4, y - 1, "accent", 1)
  px.rect(x - 1, y + 1, 3, 2, "grey", 1)
  px.pixel(x, y + 2, "bright_cyan", 1)
  -- landing skids
  px.pixel(x - 4, y + 1, "grey", 1)
  px.pixel(x + 4, y + 1, "grey", 1)
  px.line(x - 6, y + 2, x - 2, y + 2, "grey", 0.8)
  px.line(x + 2, y + 2, x + 6, y + 2, "grey", 0.8)
end

return {
  name = "lidarsat",
  kind = "general",
  summary = "A pixel quadcopter mapping hills and rooftops with a lidar fan, no GPS needed",
  captions = {
    "Position held. Build clean.",
    "Mapped and green. No satellites needed.",
    "Steady flight, steady build.",
  },

  resize = function(ctx)
    points = {}
  end,

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local px = painter(ctx)
    local pw, ph = px.width, px.height
    local base = math.max(8, math.floor(ph * 0.2))
    scroll = scroll + ctx.dt * GROUND_RATE * ctx.speed
    local left = math.floor(scroll)

    -- far ridges, faint and slow, for depth
    local far = math.floor(scroll * 0.3)
    for x = 0, pw - 1 do
      local wx = x + far
      local hf = math.floor(base * 1.35 + 5 * math.sin(wx / 23) + 3 * math.sin(wx / 9.7))
      px.rect(x, ph - hf, 1, hf, "grey", 0.12)
    end

    -- the ground and the rooftops, column by column, shaded darker with depth
    for x = 0, pw - 1 do
      local wx = x + left
      local g = ground(wx, base)
      local top = ph - g
      px.rect(x, top, 1, 2, "green", 0.9)
      px.rect(x, top + 2, 1, 4, "green", 0.5)
      px.rect(x, top + 6, 1, g, "grey", 0.3)
      local tall, part = building(wx)
      if tall then
        local roof = top - tall
        local wall = part == 0 or part == 9
        px.rect(x, roof, 1, tall, "syntax.type", wall and 0.5 or 0.28)
        px.pixel(x, roof, "syntax.type", 1)
        -- a grid of windows, some lit, fixed to the building
        if part % 3 == 2 then
          for wy = roof + 3, top - 3, 3 do
            if ((wx * 7 + wy * 13) % 5) < 3 then
              px.pixel(x, wy, "yellow", 0.9)
            end
          end
        end
      end
    end

    -- the drone, bobbing gently a little left of centre, clear of the readout
    local bob = math.sin(t * 2 * math.pi / BOB_PERIOD * ctx.pace)
    local dx = math.max(math.floor(pw * 0.42), 50)
    local dy = math.max(20, math.floor(ph * 0.34) + math.floor(bob * 1.5 + 0.5))
    local sx, sy = dx, dy + 3

    -- the fan: faint rays across it, its two edges a little stronger and every landing ray
    -- added to the map as a return
    local centre = math.sin(t * 2 * math.pi / SWEEP_PERIOD * ctx.pace) * SWEEP_REACH
    for i = 0, RAYS - 1 do
      local a = centre - FAN_HALF + 2 * FAN_HALF * i / (RAYS - 1)
      local stepx, stepy = math.sin(a), math.cos(a)
      local rx, ry = sx + 0.5, sy
      local hit
      for _ = 1, ph * 2 do
        rx, ry = rx + stepx, ry + stepy
        local cx = math.floor(rx)
        if cx < 0 or cx >= pw or ry >= ph then
          break
        end
        if ry >= surface(ph, cx + left, base) then
          hit = { cx, math.floor(ry) }
          break
        end
      end
      local edge = i == 0 or i == RAYS - 1
      if hit then
        px.line(sx, sy, hit[1], hit[2], "cyan", edge and 0.6 or 0.2)
        points[#points + 1] = { wx = hit[1] + left, y = hit[2], born = t }
        total_points = total_points + 1
      end
    end
    while #points > MAX_POINTS do
      table.remove(points, 1)
    end

    -- the map so far: fresh returns bright, older ones settling to a quieter shade
    local kept = {}
    for _, p in ipairs(points) do
      local x = p.wx - left
      if x >= 0 then
        local age = t - p.born
        if age < FRESH then
          px.pixel(x, p.y, "bright_cyan", 1)
        else
          px.pixel(x, p.y, "cyan", math.max(0.5, 0.85 - (age - FRESH) / SETTLED * 0.35))
        end
        kept[#kept + 1] = p
      end
    end
    points = kept

    draw_drone(px, dx, dy, t, ctx)
    px.flush()

    -- a readout, refreshed twice a second so the digits never churn
    hud_clock = hud_clock - ctx.dt
    if hud_clock <= 0 then
      hud_clock = 0.5
      local below = surface(ph, sx + left, base) - sy
      hud = {
        string.format("ALT  %5.1f m above ground", below * 0.4),
        string.format("SPD  %5.1f m/s", GROUND_RATE * ctx.speed * 0.45),
        string.format("PTS  %5d returns mapped", total_points),
        "GPS  denied, lidar only",
      }
    end
    local bx, by = 2, 3
    put(bx, by - 1, "┌─ nav ──────────────────────────┐", "grey")
    for i, line in ipairs(hud) do
      put(bx, by + i - 1, "│", "grey")
      put(bx + 2, by + i - 1, line:sub(1, 4), "syntax.keyword")
      put(bx + 6, by + i - 1, line:sub(5), "text")
      put(bx + 33, by + i - 1, "│", "grey")
    end
    put(bx, by + #hud, "└────────────────────────────────┘", "grey")

    -- the caption ticker along the top row
    ticker_scroll = ticker_scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(ticker_scroll)
    local out = {}
    for x = 1, w do
      out[x] = ticker[(x - 1 + offset) % #ticker + 1]
    end
    put(0, 0, table.concat(out), "syntax.function")
  end,

  on_fail = function(ctx)
    return "Lost the ground for a moment. Re-scanning."
  end,

  on_recovered = function(ctx)
    return "Position fixed again. Back on track."
  end,
}
