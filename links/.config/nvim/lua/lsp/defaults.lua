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

M.config.on_init = tie(
  "LSP * -> on_init",
  ---@param client vim.lsp.Client
  function(client)
    -- NOTE: can use :Inspect to show hl group and priority used at cursor
    tied.do_block("Toggle LSP semantic tokens", function()
      if not M.extra.use_semantic_tokens then
        client.server_capabilities.semanticTokensProvider = nil
      else
        -- TODO: Remove when fixed
        -- https://github.com/neovim/neovim/issues/39785#issuecomment-4450886150
        local new = vim.lsp._capability.all.semantic_tokens.new

        vim.lsp._capability.all.semantic_tokens.new = function(...)
          local ret = new(...)
          ret.debounce = 1000 -- in ms
          return ret
        end
      end
    end)
  end,
  tied.do_nothing
)

return M
