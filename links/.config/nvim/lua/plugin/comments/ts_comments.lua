--- @class MyLazySpec
local M = {
  -- Enchances native comments functionality
  "folke/ts-comments.nvim",
  event = tied.LazyEvent,
  opts = {
    lang = {
      kitty = "# %s",
    },
  },
}

return M
