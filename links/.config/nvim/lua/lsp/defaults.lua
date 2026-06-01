-- NOTE: Docs https://neovim.io/doc/user/lsp.html

---@type LspConfig
local M = {
  enable = false, -- not an actual LSP
  lsp_name = "*",
  config = {
    -- TODO: Check plugins like https://github.com/antosha417/nvim-lsp-file-operations
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  },
  custom = {
    -- NOTE: No point in enabling them.
    -- You would get worse CPU performance on any text edit, highlighting delay,
    -- logging errors and visual noise
    use_semantic_tokens = false,
  },
}

M.config.on_init = tie(
  "LSP * -> on_init",
  ---@param client vim.lsp.Client
  function(client)
    tied.do_block("Toggle LSP semantic tokens", function()
      if not client:supports_method("textDocument/semanticTokens") then
        return
      end

      if not M.custom.use_semantic_tokens then
        client.server_capabilities.semanticTokensProvider = nil
      else
        -- TODO: Increases debounce time. Remove when fixed
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
