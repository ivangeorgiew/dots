-- NOTE: Docs https://neovim.io/doc/user/lsp.html

local S = vim.diagnostic.severity

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
    --- @type vim.diagnostic.Opts
    diagnostics = {
      update_in_insert = false,
      severity_sort = true,
      underline = true,
      -- virtual_lines = { current_line = true },
      virtual_text = { source = false, prefix = "", spacing = 1 },
      signs = {
        text = {
          [S.ERROR] = "󰅙",
          [S.WARN] = "",
          [S.INFO] = "",
          [S.HINT] = "󰌵",
        },
      },
      float = {
        source = false,
        severity_sort = true,
      },
      jump = {
        float = false,
        wrap = true,
        severity = { S.ERROR, S.WARN },
      },
    },
  },
}

M.config.on_init = tie("LSP * -> on_init", function(client)
  -- NOTE: can use :Inspect to show hl group and priority used at cursor
  tied.do_block("Toggle LSP semantic tokens", function()
    if not M.extra.use_semantic_tokens then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end)

  tied.do_block(
    "Set vim.diagnostic options",
    function() vim.diagnostic.config(M.extra.diagnostics) end
  )
end, tied.do_nothing)

return M
