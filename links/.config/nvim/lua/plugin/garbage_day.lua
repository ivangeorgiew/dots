--- @type PluginSpec
local M = {
  -- Garbage collector that stops inactive LSP clients to free RAM
  src = "zeioth/garbage-day.nvim",
  lazy = true,
  opts = {},
}

return M
