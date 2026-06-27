-- https://wiki.hypr.land/Configuring/Basics/Variables/
-- NOTE: fix for chrome/brave browsers: Check the "Use system title bar and borders"

require("plugins")
require("dispatch")

-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
  output = "", -- leave blank to auto find a monitor
  mode = "highrr",
  position = "auto",
  scale = 1,
  bitdepth = 8,
  vrr = 0,
  supports_wide_color = -1, -- -1, 0, 1
  supports_hdr = -1, -- -1, 0, 1
})

hl.config({
  dwindle = {
    force_split = 2,
    preserve_split = true,
  },

  general = {
    layout = "dwindle",
    gaps_in = 8,
    gaps_out = 16,
    resize_on_border = true,
    border_size = 4,
    col = {
      inactive_border = "rgba(33333399)",
      active_border = "rgba(492A78FF)",
    },
    resize_corner = 0,
    extend_border_grab_area = 20,
    allow_tearing = false,
  },

  decoration = {
    blur = {
      enabled = false,
      size = 4,
      ignore_opacity = true,
      xray = true,
    },
    shadow = {
      enabled = false,
      range = 10,
      color = "rgba(A7CAFFFF)",
      color_inactive = "rgba(00000050)",
    },
    dim_inactive = false,
    rounding = 8,
    rounding_power = 4,
    border_part_of_window = true,
    active_opacity = 1,
  },

  render = {
    cm_enabled = false,
    cm_auto_hdr = 0,
    cm_sdr_eotf = "default", -- Change if wrong terminal colors (use hyprpicker)
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    disable_autoreload = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
    on_focus_under_fullscreen = 2,
    middle_click_paste = false,
  },

  xwayland = {
    force_zero_scaling = true,
  },

  input = {
    -- hyprland doesn't use the keyboard settings from nix
    -- except for the custom layouts
    kb_model = "pc104",
    kb_layout = "us,bgd",
    kb_variant = "dvorak,",
    kb_options = "grp:win_space_toggle,lv3:menu_switch",

    repeat_rate = 70,
    repeat_delay = 250,
    sensitivity = -0.75,
    accel_profile = "flat",
    follow_mouse = 2,
    float_switch_override_focus = 0,
  },

  animations = { enabled = true },
})

local an = hl.animation
local wr = hl.window_rule

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

-- From https://easings.net/
-- hl.curve( NAME, { type = "bezier", points = { {X0, Y0}, {X1, Y1} } })
hl.curve("easeOutBack", { type = "bezier", points = { { 0.34, 1.26 }, { 0.64, 1 } } })

-- hl.animation({ leaf = STRING, enabled = BOOLEAN, speed = FLOAT, curve = STRING[, style = STRING] })
an({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutBack", style = "slide" })
an({ leaf = "windows", enabled = true, speed = 3, bezier = "easeOutBack", style = "slide" })
an({ leaf = "fade", enabled = true, speed = 3, bezier = "easeOutBack" })
an({ leaf = "border", enabled = false, speed = 3, bezier = "easeOutBack" })
an({ leaf = "borderangle", enabled = false, speed = 3, bezier = "easeOutBack", style = "loop" })

-- https://wiki.hyprland.org/Configuring/Window-Rules/

-- Make all windows floting by default
wr({ match = { class = ".*" }, float = true })

-- Tiled or not and window allocation
wr({ match = { class = "kitty" }, tile = true, workspace = "1 silent" })
wr({ match = { class = "^(code)$" }, tile = true, workspace = "1 silent" })
wr({ match = { class = "dev.zed.Zed" }, tile = true, workspace = "1 silent" })
wr({ match = { class = "firefox" }, tile = true, workspace = "2 silent" })
wr({ match = { class = "google-chrome" }, tile = true, workspace = "2 silent" })
wr({ match = { class = "obsidian" }, tile = true, workspace = "3 silent" })
wr({ match = { class = "vesktop" }, tile = true, workspace = "4 silent" })
wr({ match = { class = "spotify" }, tile = true, workspace = "5 silent" })
wr({ match = { class = "vlc" }, tile = false, workspace = "5" })
wr({ match = { class = "org.qbittorrent.qBittorrent" }, tile = false, workspace = "5" })
wr({ match = { class = "org.keepassxc.KeePassXC" }, tile = true })
wr({ match = { class = "io.github.timasoft.hyprviz" }, tile = true })

-- Opacity
wr({ match = { class = "spotify" }, opacity = 0.9 })
-- wr({ match = { class = "^(vesktop)$" }, opacity = 0.97, })

-- Size
wr({ match = { class = "org.pulseaudio.pavucontrol" }, size = { "(monitor_w * 0.6)", "(monitor_h * 0.6)" } })
wr({ match = { class = "nemo" }, size = { "(monitor_w * 0.6)", "(monitor_h * 0.6)" } })
wr({ match = { class = "mpv" }, size = { "(monitor_w * 0.6)", "(monitor_h * 0.6)" } })
