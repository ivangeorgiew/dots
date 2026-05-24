--- @type PluginSpec
local M = {
  -- Garbage collector that stops inactive LSP clients to free RAM
  "zeioth/garbage-day.nvim",
  event = "VeryLazy",
  opts = {},
}

return M
