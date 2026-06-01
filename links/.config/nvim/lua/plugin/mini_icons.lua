--- @type PluginSpec
local M = {
  -- Pretty icons
  src = "nvim-mini/mini.icons",
  opts = {
    filetype = {
      json = { glyph = "" },
    },
  },
  config = tie("Plugin mini.icons -> config", function(opts)
    require("mini.icons").setup(opts)
    MiniIcons.mock_nvim_web_devicons()
  end, tied.do_nothing),
}

return M
