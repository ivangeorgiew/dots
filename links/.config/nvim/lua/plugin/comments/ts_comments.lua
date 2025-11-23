--- @type MyLazySpec
local M = {
  -- Enchances native comments functionality
  "folke/ts-comments.nvim",
  event = "VeryLazy",
  opts = {
    lang = {
      kitty = "# %s",
    },
  },
}

return M
