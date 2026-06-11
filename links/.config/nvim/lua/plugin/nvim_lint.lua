-- TODO: Add to statusline with https://github.com/mfussenegger/nvim-lint#get-the-current-running-linters-for-your-buffer
-- NOTE: Modify built-in linters: https://github.com/mfussenegger/nvim-lint#customize-built-in-linters
-- NOTE: Create custom linters: https://github.com/mfussenegger/nvim-lint#custom-linters

--- @type PluginSpec
local M = {
  src = "mfussenegger/nvim-lint",
  name = "lint",
  enabled = false,
  lazy = true,
  opts = {},
}

return M
