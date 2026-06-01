-- TODO: Enable if you encourter filetypes without LSP that you want to lint
-- Check out the LazyVim config for this plugin when setting it up

--- @type PluginSpec
local M = {
  src = "mfussenegger/nvim-lint",
  name = "lint",
  enabled = false,
  lazy = true,
  opts = {},
}

return M
