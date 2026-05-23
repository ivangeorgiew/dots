--- @type LazyPluginSpec
local M = {
  -- Enchances native comments functionality
  "folke/ts-comments.nvim",
  event = "AfterUI",
  opts = {
    lang = {
      kitty = "# %s",
    },
  },
}

return M
