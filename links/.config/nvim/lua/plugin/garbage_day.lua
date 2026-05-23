--- @type LazyPluginSpec
local M = {
  -- Garbage collector that stops inactive LSP clients to free RAM
  "zeioth/garbage-day.nvim",
  event = "AfterUI",
  opts = {},
}

return M
