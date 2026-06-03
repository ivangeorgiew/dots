-- Special Keys: SHIFT CAPS CTRL/CONTROL ALT MOD2 MOD3 SUPER/WIN/LOGO/MOD4 MOD5

-- If you disable UWSM, search and replace every instance of: app2unit, uwsm

-- Variables
local mod = "ALT"
local start = "app2unit" -- start every app with UWSM
local exec = hl.exec_cmd
local disp = hl.dsp.exec_cmd
local bind = hl.bind

hl.on("hyprland.start", function()
  -- Fixes
  -- exec("dbus-update-activation-environment --systemd --all")
  exec("uwsm finalize") -- replaces dbus-update-activation-environment

  -- Services setup is done in nix config

  -- Apps to start on login
  exec(start .. " $TERMINAL")
  exec(start .. " $BROWSER")
  exec(start .. " spotify")
  exec(start .. " vesktop")
  -- exec(start .. " obsidian")
  -- exec("~/.config/hypr/scripts/play_spotify.sh")
end)

-- https://wiki.hypr.land/Configuring/Basics/Binds/
bind(mod .. " + r", disp("systemctl restart --user reload-hypr.service"))
bind(mod .. " + SHIFT + r", disp("systemctl restart --user waybar.service")) -- sometimes breaks
bind(mod .. " + SHIFT + q", hl.dsp.window.close())
bind(mod .. " + SPACE", disp([[rofi -show drun -run-command "app2unit {cmd}"]]))
bind(mod .. " + RETURN", disp(start .. " $TERMINAL"))
bind(mod .. " + b", disp(start .. " $BROWSER"))
bind(mod .. " + e", disp(start .. " $FILE_MANAGER"))

bind(mod .. " + f", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" })) -- toggle fullscreen with gaps/bar
bind(mod .. " + SHIFT + f", hl.dsp.window.fullscreen({ action = "toggle" })) -- toggle fullsceen WITHOUT gaps/bar

-- Mouse binds. 272 is LMB, 273 is RMB, 276 and 275 are side buttons
bind("mouse:276", hl.dsp.window.drag(), { mouse = true }) -- depends on mouse movement
bind("mouse:275", hl.dsp.window.float({ action = "toggle" }))

-- Colorpicker
bind(mod .. " + p", disp("hyprpicker -a"))

-- Full and partial screenshot
bind("Print", disp("grim - | wl-copy"))
bind("SHIFT + Print", disp([[grim -g "$(slurp)" - | wl-copy]]))

-- Full and partial screen recording
bind("CTRL + Print", disp("~/.config/hypr/scripts/record.sh whole"))
bind("CTRL + SHIFT + Print", disp("~/.config/hypr/scripts/record.sh partial"))
bind("CTRL + SHIFT + BackSpace", disp("~/.config/hypr/scripts/record.sh stop"))

-- Alt+Tab behavior
bind("ALT + Tab", function()
  -- Change focus to next window and bring it to top
  hl.dsp.window.cycle_next()
  hl.dsp.window.alter_zorder()
end)
-- bind("ALT + Tab", disp("~/.config/hypr/scripts/alttab.sh")) -- switch between first 2 workspaces

for dir, key in pairs({ l = "h", r = "l", u = "k", d = "j" }) do
  -- Move focus to window
  bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))

  -- Move window
  bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

for i = 1, 9 do
  -- Move to workspace
  bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))

  -- Move window to workspace
  bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Control sound
bind("XF86AudioRaiseVolume", disp("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
bind("XF86AudioLowerVolume", disp("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
bind("XF86AudioMute", disp("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Control Spotify
bind("XF86AudioPrev", disp("playerctl -p spotify previous"))
bind("XF86AudioPlay", disp("playerctl -p spotify play-pause"))
bind("XF86AudioNext", disp("playerctl -p spotify next"))
