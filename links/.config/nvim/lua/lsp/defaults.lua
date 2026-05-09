-- NOTE: Docs https://neovim.io/doc/user/lsp.html

---@type LspConfig
local M = {
  enable = false, -- not an actual LSP
  lsp_name = "*",
  config = {
    -- TODO: Check plugins like https://github.com/antosha417/nvim-lsp-file-operations
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  },
  extra = {
    use_semantic_tokens = true,
  },
}

M.config.on_init = tie("LSP * -> on_init", function(client)
  -- NOTE: can use :Inspect to show hl group and priority used at cursor
  tied.do_block("Toggle LSP semantic tokens", function()
    if not M.extra.use_semantic_tokens then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end)
end, tied.do_nothing)

return M
