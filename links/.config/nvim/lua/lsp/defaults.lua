-- NOTE: Docs https://neovim.io/doc/user/lsp.html

---@type lsp_config
local M = {
  name = "*",
  enabled = false, -- not an actual LSP
  config = {
    -- TODO: Check plugins like https://github.com/antosha417/nvim-lsp-file-operations
    -- NOTE: Those are the defaults, no need to pass them
    -- capabilities = vim.lsp.protocol.make_client_capabilities(),
  },
}

return M
