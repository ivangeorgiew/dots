hl.on("hyprland.start", function() hl.exec_cmd([[hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprbars.so"]]) end)

hl.config({
  plugin = {
    hyprbars = {
      enabled = true,
      bar_color = "rgba(492A78FF)",
      bar_height = 30,
      bar_blur = true,
      col = { text = "rgb(E5E5E5)" },
      bar_title_enabled = true,
      bar_text_size = 14,
      bar_text_font = "Jetbrains Mono Nerd Font Mono",
      bar_text_align = "center", -- left or center
      bar_buttons_alignment = "right", -- left or right
      bar_part_of_window = true,
      bar_precedence_over_border = true,
      bar_padding = 10,
      bar_button_padding = 12,
      icon_on_hover = false,
      -- inactive_button_color = "rgb(000000)",
      on_double_click = [[hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })']],
    },
  },
})

hl.plugin.hyprbars.add_button({
  bg_color = "rgb(ff4040)",
  fg_color = "rgb(ffffff)",
  size = 14,
  icon = "",
  action = "hyprctl dispatch 'hl.dsp.window.close()'",
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(ed9915)",
  fg_color = "rgb(000000)",
  size = 14,
  icon = "",
  action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" })']],
})

-- TODO: Fix when lua support for plugin window rules is adedd
-- hl.window_rule({ match = { focus = false }, hyprbars = { bar_color = "rgba(33333399)" } }) -- same as col.inactive_border
-- hl.window_rule({ match = { focus = true }, hyprbars = { bar_color = "rgba(492A78FF)" } }) -- same as col.active_border
