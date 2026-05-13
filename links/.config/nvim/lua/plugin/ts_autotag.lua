-- TODO: config and test it

--- @type LazyPluginSpec
local M = {
  -- Auto-add closing tags for HTML, JSX, etc
  "windwp/nvim-ts-autotag",
  enabled = false,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  opts = {},
}

return M
