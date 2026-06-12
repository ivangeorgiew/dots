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
    use_semantic_tokens = true,
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

      vim.lsp.semantic_tokens.enable(
        M.custom.use_semantic_tokens,
        { client_id = client.id }
      )

      -- TODO: remove when bug is fixed https://github.com/neovim/neovim/issues/40208
      local log_error = vim.lsp.log.error

      -- Convert semantic_tokens errors to debug
      vim.lsp.log.error = function(...)
        local args = vim.F.pack_len(...)

        if args[1] == "semantic_tokens" then
          return vim.lsp.log.debug(vim.F.unpack_len(args))
        end

        return log_error(vim.F.unpack_len(args))
      end
    end)
  end,
  tied.do_nothing
)

return M
