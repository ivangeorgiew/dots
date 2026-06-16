--- @type plugin_spec
local M = {
  -- Enchances native comments functionality
  src = "folke/ts-comments.nvim",
  lazy = true,
  opts = {
    lang = {
      kitty = "# %s",
    },
  },
}

return M
