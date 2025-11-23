--- @type MyLazySpec
local M = {
  -- Garbage collector that stops inactive LSP clients to free RAM
  "zeioth/garbage-day.nvim",
  event = "VeryLazy",
  -- :h garbage-day.nvim-available-options
  opts = {},
}

return M
