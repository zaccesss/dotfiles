-- scope: an oscilloscope in roll mode on my bench, painted in pixels. Two channels scroll across
-- a graticule with a faint phosphor glow, a sine with a little harmonic on channel 1 and a PWM
-- square wave on channel 2, with readouts and a caption ticker under the screen.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It paints
-- with the pixel canvas; an older Zacess Scenes without one draws the same shapes in half blocks.

-- pixels a second the traces roll across at standard motion
local ROLL_RATE = 10
-- pixels for one cycle of each channel
local CH1_CYCLE = 34
local CH2_CYCLE = 24
-- seconds for the PWM duty cycle to drift from low to high and back, slow enough to watch
local DUTY_PERIOD = 16
-- cells a second the caption ticker moves
local TICKER_RATE = 7
-- seconds between readout refreshes, so the digits never churn
local READOUT_PERIOD = 0.75

local TICKER = "on the bench  ·  Electronic Engineering and Computer Science  ·  probe, measure, then change one thing  ·  ADC at 12 bits  ·  PWM into a motor driver  ·  I2C at 400 kHz  ·  PHAEMOS vibration node  ·  "

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

local roll = 0
local ticker_scroll = 0
local readout_clock = 0
local readout = {}

-- a string as a list of characters, so text with a middle dot slices by character, not byte
local function chars(s)
  local list = {}
  for _, code in utf8.codes(s) do
    list[#list + 1] = utf8.char(code)
  end
  return list
end

local ticker = chars(TICKER)

-- channel 1 from -1 to 1 before scaling
local function ch1(u)
  local a = u / CH1_CYCLE * 2 * math.pi
  return 0.88 * math.sin(a) + 0.1 * math.sin(3 * a)
end

-- channel 2 as high or low for a duty cycle between 0 and 1
local function ch2(u, duty)
  return (u / CH2_CYCLE) % 1 < duty
end

-- a trace through one y per column, joined column to column so steep parts never break, with
-- a faint glow above and below like phosphor
local function trace(px, x0, ys, role, glow)
  for i = 1, #ys - 1 do
    local x = x0 + i - 1
    px.line(x, ys[i] - 1, x + 1, ys[i + 1] - 1, glow, 0.3)
    px.line(x, ys[i] + 1, x + 1, ys[i + 1] + 1, glow, 0.3)
  end
  for i = 1, #ys - 1 do
    local x = x0 + i - 1
    px.line(x, ys[i], x + 1, ys[i + 1], role, 1)
  end
end

return {
  name = "scope",
  kind = "general",
  summary = "A pixel oscilloscope in roll mode with a sine and a PWM trace and a bench ticker",
  captions = {
    "Clean signal, clean build.",
    "Everything in spec.",
    "No noise on the line.",
  },

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local px = painter(ctx)
    roll = roll + ctx.dt * ROLL_RATE * ctx.speed

    -- the screen in cells: a frame with ten divisions across and eight down
    local sx, sy = 2, 2
    local sw = math.max(20, w - 4)
    local sh = math.max(8, h - 7)
    local iw = sw - 2
    -- the same screen in pixels, inside the frame
    local left, top = sx + 1, sy * 2
    local pwid, phei = iw, sh * 2
    local cx = left + math.floor(pwid / 2)
    local cy = top + math.floor(phei / 2)

    -- a faint glass tint, then the graticule as dotted lines and the centre axes with ticks
    px.rect(left, top, pwid, phei, "info", 0.06)
    for d = 1, 9 do
      local gx = left + math.floor(pwid * d / 10)
      for y = top, top + phei - 1, 2 do
        px.pixel(gx, y, "muted", 0.4)
      end
    end
    for d = 1, 7 do
      local gy = top + math.floor(phei * d / 8)
      for x = left, left + pwid - 1, 3 do
        px.pixel(x, gy, "muted", 0.4)
      end
    end
    px.line(left, cy, left + pwid - 1, cy, "grey", 0.6)
    px.line(cx, top, cx, top + phei - 1, "grey", 0.6)
    for x = left, left + pwid - 1, 5 do
      px.line(x, cy - 1, x, cy + 1, "grey", 0.8)
    end
    for y = top, top + phei - 1, 4 do
      px.line(cx - 1, y, cx + 1, y, "grey", 0.8)
    end

    -- channel 1 in the upper half and channel 2 in the lower half, the newest sample arriving
    -- at the right edge
    local upper = top + math.floor(phei / 4)
    local lower = top + math.floor(phei * 3 / 4)
    local amp = math.max(3, math.floor(phei / 4) - 3)
    local duty = 0.5 + 0.3 * math.sin(t * 2 * math.pi / DUTY_PERIOD * ctx.pace)
    local y1, y2 = {}, {}
    for i = 1, pwid do
      local u = i + roll
      y1[i] = math.floor(upper - ch1(u) * amp + 0.5)
      y2[i] = ch2(u, duty) and lower - amp or lower + amp
    end
    trace(px, left, y1, "bright_yellow", "yellow")
    trace(px, left, y2, "bright_cyan", "cyan")
    px.flush()

    -- the frame around the screen, with each channel's number on the left edge at its centre
    put(sx, sy - 1, "┌" .. string.rep("─", sw - 2) .. "┐", "grey")
    put(sx, sy + sh, "└" .. string.rep("─", sw - 2) .. "┘", "grey")
    for y = sy, sy + sh - 1 do
      put(sx, y, "│", "grey")
      put(sx + sw - 1, y, "│", "grey")
    end
    put(sx, math.floor(upper / 2), "1", "yellow")
    put(sx, math.floor(lower / 2), "2", "cyan")

    -- the readouts under the screen, refreshed on their own slow clock
    readout_clock = readout_clock - ctx.dt
    if readout_clock <= 0 then
      readout_clock = READOUT_PERIOD
      local wobble = 0.004 * math.sin(t * 0.7)
      readout = {
        { "CH1", string.format("1.00 V/div  f %.3f kHz  Vpp 3.30 V", 1.000 + wobble), "yellow" },
        { "CH2", string.format("5.00 V/div  PWM duty %2d%%", math.floor(duty * 100 + 0.5)), "cyan" },
        { "ROLL", "2 ms/div", "accent" },
      }
    end
    local rx = sx
    for _, r in ipairs(readout) do
      put(rx, sy + sh + 1, r[1], r[3])
      put(rx + #r[1] + 1, sy + sh + 1, r[2], "text")
      rx = rx + #r[1] + #r[2] + 5
      if rx >= w - 10 then
        break
      end
    end

    -- the caption ticker on the bottom row
    ticker_scroll = ticker_scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(ticker_scroll)
    local out = {}
    for x = 1, w - 4 do
      out[x] = ticker[(x - 1 + offset) % #ticker + 1]
    end
    put(2, h - 2, table.concat(out), "syntax.function")
  end,

  on_fail = function(ctx)
    return "Something is out of spec. Probe it."
  end,

  on_recovered = function(ctx)
    return "Back in spec. Clean signal."
  end,
}
