-- football: BUILD FC against BUGS on a striped pixel pitch, with a goal and net, two teams of
-- small pixel players, a keeper and a crowd in the stand under the scoreboard. While nothing
-- happens the teams pass the ball about calmly. A passing build ends a short attacking move in a
-- goal: the net ripples, the scorer celebrates, the crowd does a slow wave and BUILD FC goes one
-- up. A failing build ends it off the post or in the keeper's hands: the players hold their
-- heads and the scoreboard gives one small next step. A ticker along the bottom keeps the match
-- report for the session.
--
-- installed into the Zacess Scenes folder by apps/zacess-scenes/setup.sh or setup.ps1. Every
-- colour is a palette role, so the scene follows whichever Zacess theme zt last set. It reads the
-- time of each result from ctx.clock and paints with the pixel canvas; on an older Zacess Scenes
-- without them it leaves the times out and draws the same shapes in half-block characters.
--
-- the score only carries over between a pass and a fail when the watch mode keeps this scene for
-- both, as with zw --scene football --fail-scene football

-- seconds a pass takes at standard motion, then how long a player keeps the ball before the next
local PASS_TIME = 1.4
local HOLD_TIME = 0.9
-- seconds the move takes to reach the striker, then for the shot to arrive
local BUILD_UP = 1.2
local SHOT_TIME = 0.8
-- seconds the celebration or the disappointment lasts, then the length of the crowd's wave
local REACTION = 6
local WAVE_LENGTH = 10
-- pixels a second the crowd's wave travels along the stand
local WAVE_RATE = 18
-- seconds for one ripple of the net to settle
local RIPPLE_TIME = 2.2
-- steps a second a running player's legs change; slow, so they read as a jog
local STRIDE_RATE = 4
-- cells a second the match report moves
local TICKER_RATE = 7

local TIPS = {
  "read the first error",
  "fix one thing, then save",
  "check what changed",
  "run that test alone",
}
-- the roles the crowd's shirts take, so the stand reads as many people
local CROWD = { "info", "magenta", "yellow", "cyan", "green", "accent", "text" }

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

-- a string as a list of characters, so text with a middle dot slices by character, not byte
local function chars(s)
  local list = {}
  for _, code in utf8.codes(s) do
    list[#list + 1] = utf8.char(code)
  end
  return list
end

-- the session's match report, kept in the scene's own state
local passes, fails = 0, 0
local streak, streak_kind = 0, nil
local last_time = nil
-- the moment playing out, if any: "goal", "post" or "save", when it started and its clock time
local event = nil
local note = nil
-- the small next step after a fail, shown under the result until the next pass
local tip = nil
-- the calm passing about between moments
local holder, target = 1, 2
-- where the ball was when the last calm pass was drawn, so a move starts from there
local event_from = nil
local pass_clock = 0
local passing = false
local ticker_scroll = 0

-- the pitch for the current size: the goal line, where the goal stands and the players' homes
local function pitch(ctx)
  local pw, ph = ctx.width, ctx.height * 2
  local top = 19
  local bottom = (ctx.height - 4) * 2
  local depth = bottom - top
  local gx = pw - 14
  return {
    pw = pw,
    top = top,
    bottom = bottom,
    gx = gx,
    goal_foot = top + math.floor(depth * 0.7),
    -- BUILD FC attacking to the right, BUGS defending in front of their goal
    home = {
      { x = pw * 0.14, y = top + depth * 0.55 },
      { x = pw * 0.3, y = top + depth * 0.25 },
      { x = pw * 0.36, y = top + depth * 0.8 },
      { x = pw * 0.52, y = top + depth * 0.5 },
    },
    away = {
      { x = pw * 0.6, y = top + depth * 0.3 },
      { x = pw * 0.66, y = top + depth * 0.75 },
      { x = pw * 0.74, y = top + depth * 0.5 },
    },
    keeper = { x = gx - 3, y = top + depth * 0.6 },
    net = { x = gx + 6, y = top + depth * 0.62 - 4 },
    ph = ph,
  }
end

-- where a player stands now: their home with a slow wander, so the pitch never sits still
local function spot(home, i, t, ctx)
  local drift = ctx.reduced and 0.5 or 1
  return home.x + 3 * drift * math.sin(t * 0.35 + i * 1.7), home.y + 2 * drift * math.sin(t * 0.27 + i)
end

-- one small player, standing on (x, y): legs, shorts, a shirt in the kit (the away kit has a
-- stripe down it, so the teams differ in shape as well as colour), arms for the pose and a head
local function player(px, x, y, kit, striped, pose, stride)
  x, y = math.floor(x), math.floor(y)
  if stride % 2 == 0 then
    px.pixel(x - 1, y, "text", 0.75)
    px.pixel(x + 1, y, "text", 0.75)
  else
    px.pixel(x, y, "text", 0.75)
    px.pixel(x, y - 1, "text", 0.75)
  end
  px.rect(x - 1, y - 2, 3, 1, "text", 0.5)
  px.rect(x - 1, y - 5, 3, 3, kit, 1)
  if striped then
    px.line(x, y - 5, x, y - 3, "bright", 1)
  end
  if pose == "up" then
    px.pixel(x - 2, y - 7, kit, 1)
    px.pixel(x + 2, y - 7, kit, 1)
    px.pixel(x - 2, y - 6, kit, 1)
    px.pixel(x + 2, y - 6, kit, 1)
  elseif pose == "head" then
    px.pixel(x - 2, y - 6, kit, 1)
    px.pixel(x + 2, y - 6, kit, 1)
    px.pixel(x - 2, y - 7, "text", 0.85)
    px.pixel(x + 2, y - 7, "text", 0.85)
  else
    px.pixel(x - 2, y - 4, kit, 0.8)
    px.pixel(x + 2, y - 4, kit, 0.8)
  end
  -- a head with its top corners left off, so it reads round rather than square
  px.pixel(x, y - 7, "text", 0.85)
  px.rect(x - 1, y - 6, 3, 1, "text", 0.85)
end

-- a straight line between two points, part of the way along
local function along(a, b, f)
  f = math.max(0, math.min(1, f))
  return a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f
end

local function record(kind, ctx)
  local now = ctx.clock and ctx.clock.time or nil
  if streak_kind == kind then
    streak = streak + 1
  else
    streak, streak_kind = 1, kind
  end
  last_time = now
  return now
end

return {
  name = "football",
  kind = "general",
  summary = "BUILD FC on a pixel pitch: a goal for a pass, off the post for a fail, a match report",
  captions = {
    "BUILD FC in control. All good.",
    "Clean build, tidy passing.",
    "Keeping the ball. No errors.",
  },

  frame = function(ctx)
    local w, h = ctx.width, ctx.height
    local t = ctx.time
    local px = painter(ctx)
    local P = pitch(ctx)
    local pw = P.pw

    -- the stand: a back wall, then four tiers of supporters, leaving room for the scoreboard
    local board_w = 40
    local board_x = math.floor((w - board_w) / 2)
    px.rect(0, 2, pw, 15, "grey", 0.18)
    local waving = event and event.kind == "goal" and t - event.at < WAVE_LENGTH
    local wave_x = waving and (t - event.at) * WAVE_RATE * ctx.speed - 10 or -100
    for tier = 0, 3 do
      local hy = 5 + tier * 3
      for x = 1 + (tier % 2), pw - 2, 2 do
        local under_board = x >= board_x - 1 and x <= board_x + board_w and hy <= 12
        if not under_board then
          local up = math.abs(x - (wave_x - tier * 3)) < 5
          local role = CROWD[(x * 7 + tier * 3) % #CROWD + 1]
          local y = up and hy - 1 or hy
          px.pixel(x, y + 1, role, up and 0.8 or 0.45)
          px.pixel(x, y, "text", up and 0.9 or 0.5)
          if up then
            px.pixel(x, y - 1, role, 0.8)
          end
        end
      end
    end

    -- the pitch: mown stripes, a touchline along the far side and the goal area markings
    for x = 0, pw - 1, 10 do
      px.rect(x, P.top, 5, P.bottom - P.top, "green", 0.42)
      px.rect(x + 5, P.top, 5, P.bottom - P.top, "green", 0.3)
    end
    px.line(0, P.top, pw - 1, P.top, "text", 0.55)
    px.line(P.gx - 16, P.top + 6, P.gx - 16, P.bottom - 2, "text", 0.4)
    px.line(P.gx - 16, P.top + 6, P.gx, P.top + 6, "text", 0.4)
    px.line(P.gx - 16, P.bottom - 2, P.gx, P.bottom - 2, "text", 0.4)

    -- the net behind the goal mouth, rippling outwards for a moment after a goal
    local gx, foot = P.gx, P.goal_foot
    local post_top = foot - 16
    local ripple = 0
    if event and event.kind == "goal" then
      local since = t - event.at - BUILD_UP - SHOT_TIME
      if since >= 0 and since < RIPPLE_TIME then
        ripple = (1 - since / RIPPLE_TIME) * (ctx.reduced and 1 or 2)
      end
    end
    for ny = post_top - 3, foot, 2 do
      local bulge = math.floor(ripple * math.sin((ny - post_top) * 0.6 - t * 6 * ctx.pace) + 0.5)
      for nx = gx + 2, gx + 9, 2 do
        px.pixel(nx + bulge + (ny - post_top) % 4 // 2, ny, "muted", 0.5)
      end
    end
    -- the near post, the crossbar running back to the far post, both in full strength
    px.line(gx, post_top, gx, foot, "bright", 1)
    px.line(gx, post_top, gx + 9, post_top - 4, "bright", 1)
    px.line(gx + 9, post_top - 4, gx + 9, foot - 4, "bright", 0.6)
    px.line(gx, foot, gx + 9, foot - 4, "text", 0.4)

    -- where everyone is
    local home, away = {}, {}
    for i, base in ipairs(P.home) do
      home[i] = { spot(base, i, t, ctx) }
    end
    for i, base in ipairs(P.away) do
      away[i] = { spot(base, i + 4, t, ctx) }
    end
    local striker = #home
    local keeper = { P.keeper.x, P.keeper.y }
    local ball

    if event and t - event.at > BUILD_UP + SHOT_TIME + REACTION then
      event = nil
      holder, target, pass_clock, passing = 1, 2, 0, false
    end

    local scorer_pose, team_pose = nil, nil
    if event then
      local e = t - event.at
      local strike = { home[striker][1] + 2, home[striker][2] }
      if e < BUILD_UP then
        -- the move: the ball goes from where it was to the striker, who closes in on goal
        -- the striker runs into the box, clear of the watch mode's banner in the middle
        home[striker][1] = home[striker][1] + (P.gx - 14 - home[striker][1]) * (e / BUILD_UP)
        ball = { along(event.from, { home[striker][1] + 2, home[striker][2] }, e / BUILD_UP) }
      else
        home[striker][1] = P.gx - 14
        strike = { home[striker][1] + 2, home[striker][2] }
        local shot = (e - BUILD_UP) / SHOT_TIME
        local aim
        if event.kind == "goal" then
          aim = { P.net.x, P.net.y }
          -- the keeper goes the wrong way
          keeper[2] = keeper[2] + math.min(1, shot) * 6
        elseif event.kind == "post" then
          aim = { gx, post_top + 6 }
        else
          aim = { gx - 3, keeper[2] - 4 }
          keeper[2] = keeper[2] + (aim[2] + 4 - keeper[2]) * math.min(1, shot)
        end
        if shot <= 1 then
          ball = { along(strike, aim, shot) }
        elseif event.kind == "goal" then
          ball = { aim[1] + 1, aim[2] + 2 }
        elseif event.kind == "post" then
          -- off the post and rolling back out of play, slowly
          ball = { along(aim, { gx - 18, P.bottom - 4 }, (shot - 1) / 1.5) }
        else
          ball = { gx - 2, keeper[2] - 4 }
        end
        if shot > 1 then
          if event.kind == "goal" then
            scorer_pose = "up"
          else
            team_pose = "head"
          end
        end
      end
    else
      -- calm passing about: hold the ball, then roll it to the next player
      pass_clock = pass_clock + ctx.dt * ctx.speed
      if passing then
        if pass_clock >= PASS_TIME then
          holder, passing, pass_clock = target, false, 0
        end
      elseif pass_clock >= HOLD_TIME then
        target = holder % (#home - 1) + 1
        if target == holder then
          target = target % (#home - 1) + 1
        end
        passing, pass_clock = true, 0
      end
      local a = { home[holder][1] + 2, home[holder][2] }
      if passing then
        local b = { home[target][1] - 2, home[target][2] }
        ball = { along(a, b, pass_clock / PASS_TIME) }
      else
        ball = a
      end
      event_from = ball
    end

    -- the defenders and the keeper drift towards the ball, never quickly
    for i, a in ipairs(away) do
      a[1] = a[1] + (ball[1] - a[1]) * 0.12
      a[2] = a[2] + (ball[2] - a[2]) * 0.12
    end
    if not event then
      keeper[2] = keeper[2] + (ball[2] - keeper[2]) * 0.3
    end

    -- players nearer the far touchline are drawn first, so nearer ones stand in front
    local stride = ctx.reduced and 0 or math.floor(t * STRIDE_RATE * ctx.pace)
    local everyone = {}
    for i, p in ipairs(home) do
      local pose = (i == striker and scorer_pose) or team_pose
      local hop = (pose == "up" and not ctx.reduced) and math.floor((math.sin(t * 4 * ctx.pace) + 1) / 1.5) or 0
      everyone[#everyone + 1] = { p[1], p[2] - hop, "info", false, pose, stride + i }
    end
    for i, p in ipairs(away) do
      everyone[#everyone + 1] = { p[1], p[2], "magenta", true, nil, stride + i + 1 }
    end
    everyone[#everyone + 1] = { keeper[1], keeper[2], "yellow", false, nil, 0 }
    table.sort(everyone, function(a, b) return a[2] < b[2] end)
    for _, f in ipairs(everyone) do
      player(px, f[1], f[2], f[3], f[4], f[5], f[6])
    end
    -- the ball's shadow on the grass, then the ball
    px.rect(math.floor(ball[1]), math.floor(ball[2]) + 1, 2, 1, "text", 0.25)
    px.rect(math.floor(ball[1]), math.floor(ball[2]) - 1, 2, 2, "bright", 1)
    px.flush()

    -- the scoreboard: the score, then what just happened and when
    local status = "in play"
    if event then
      local done = t - event.at > BUILD_UP + SHOT_TIME
      if not done then
        status = "attack on goal"
      else
        status = note
      end
    elseif note then
      status = note
    end
    local line1 = string.format("BUILD FC %d   ·   BUGS %d", passes, fails)
    put(board_x, 1, "┌" .. string.rep("─", board_w - 2) .. "┐", "grey")
    put(board_x, 5, "└" .. string.rep("─", board_w - 2) .. "┘", "grey")
    for y = 2, 4 do
      put(board_x, y, "│" .. string.rep(" ", board_w - 2) .. "│", "grey")
    end
    local l1 = chars(line1)
    put(board_x + math.floor((board_w - #l1) / 2), 2, line1, "bright")
    local l2 = chars(status)
    if #l2 > board_w - 4 then
      status = table.concat(l2, "", 1, board_w - 4)
      l2 = chars(status)
    end
    local status_role = "muted"
    if event and t - event.at > BUILD_UP + SHOT_TIME then
      status_role = event.kind == "goal" and "green" or "warning"
    end
    put(board_x + math.floor((board_w - #l2) / 2), 3, status, status_role)
    if tip and not (event and t - event.at <= BUILD_UP + SHOT_TIME) then
      local l3 = chars("next: " .. tip)
      put(board_x + math.floor((board_w - #l3) / 2), 4, table.concat(l3), "text")
    end

    -- the match report two rows up from the bottom, clear of the watch mode's status bar
    local parts = { "match report", string.format("BUILD FC %d, BUGS %d", passes, fails) }
    local function count(n, one, many)
      return n .. " " .. (n == 1 and one or many)
    end
    parts[#parts + 1] = count(passes, "passing build", "passing builds") .. ", " .. count(fails, "failing", "failing")
    if streak > 0 then
      local word = streak_kind == "pass" and count(streak, "pass", "passes") or count(streak, "fail", "fails")
      parts[#parts + 1] = "streak: " .. word .. (streak > 1 and " in a row" or "")
    end
    if last_time then
      parts[#parts + 1] = "last result at " .. last_time
    end
    parts[#parts + 1] = "BUILD FC v BUGS, every save a match"
    local text = chars(table.concat(parts, "  ·  ") .. "  ·  ")
    ticker_scroll = ticker_scroll + ctx.dt * TICKER_RATE * ctx.speed
    local offset = math.floor(ticker_scroll)
    local out = {}
    for x = 1, w do
      out[x] = text[(x - 1 + offset) % #text + 1]
    end
    put(0, h - 3, table.concat(out), "syntax.function")
  end,

  on_pass = function(ctx)
    passes = passes + 1
    local at = record("pass", ctx)
    event = { kind = "goal", at = ctx.time, from = event_from or { ctx.width * 0.2, 40 } }
    note = at and ("GOAL AT " .. at) or "GOAL"
    tip = nil
    return at and ("Goal! Build passed at " .. at .. ".") or "Goal! Build passed."
  end,

  on_recovered = function(ctx)
    passes = passes + 1
    local at = record("pass", ctx)
    event = { kind = "goal", at = ctx.time, from = event_from or { ctx.width * 0.2, 40 } }
    note = at and ("EQUALISER AT " .. at) or "EQUALISER"
    tip = nil
    return "Back level. Fixed and green."
  end,

  on_fail = function(ctx)
    fails = fails + 1
    local at = record("fail", ctx)
    -- alternate between the post and the keeper, so a run of fails does not look the same
    local kind = fails % 2 == 1 and "post" or "save"
    event = { kind = kind, at = ctx.time, from = event_from or { ctx.width * 0.2, 40 } }
    tip = TIPS[(fails - 1) % #TIPS + 1]
    local what = kind == "post" and "OFF THE POST" or "SAVED"
    note = at and (what .. " AT " .. at) or what
    return (kind == "post" and "Off the post. " or "Saved. ") .. tip:sub(1, 1):upper() .. tip:sub(2) .. "."
  end,
}
