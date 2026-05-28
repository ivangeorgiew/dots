--- @type PluginSpec
local M = {
  -- Pretty icons
  -- https://github.com/nvim-mini/mini.icons?tab=readme-ov-file#default-config
  src = "nvim-mini/mini.icons",
  opts = {
    extension = {
      json = { glyph = "" },
    },
  },
  config = tie("Plugin mini.icons -> config", function(opts)
    require("mini.icons").setup(opts)
    MiniIcons.mock_nvim_web_devicons()
  end, tied.do_nothing),
}

return M
