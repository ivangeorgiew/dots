-- TODO: config and test it

--- @type LazyPluginSpec
local M = {
  -- Auto-add closing tags for HTML, JSX, etc
  "windwp/nvim-ts-autotag",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = tied.LazyEvent,
  opts = {},
}

return M
