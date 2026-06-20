--- @type plugin_spec
local M = {
  -- Garbage collector that stops inactive LSP clients to free RAM
  src = "moqsien/garbage-day.nvim",
  lazy = true,
  opts = {},
}

return M
