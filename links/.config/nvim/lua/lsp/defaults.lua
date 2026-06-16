-- NOTE: Docs https://neovim.io/doc/user/lsp.html

---@type lsp_config
local M = {
  enable = false, -- not an actual LSP
  lsp_name = "*",
  config = {
    -- TODO: Check plugins like https://github.com/antosha417/nvim-lsp-file-operations
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  },
}

return M
