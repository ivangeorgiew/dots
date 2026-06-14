-- NOTE: Docs https://neovim.io/doc/user/lsp.html

---@type LspConfig
local M = {
  enable = false, -- not an actual LSP
  lsp_name = "*",
  -- TODO: Check plugins like https://github.com/antosha417/nvim-lsp-file-operations
  config = {},
}

return M
