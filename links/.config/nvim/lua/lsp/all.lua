---@type LspConfig
local M = {
  enable = false,
  lsp_name = "*",
  config = {},
}

M.config.on_attach = tie("LSP * -> on_attach", function(client, bufnr)
  -- stylua: ignore
  tied.each_i(
    {
      { "n", "<leader>ti", function() vim.lsp.inlay_hint.enable( not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr }) end, { desc = "vim.lsp.inlay_hint()" } },
      { "n", "K", function() local h = vim.lsp.buf.hover; h(); h(); end, { desc = "vim.lsp.buf.hover()" } },
      { "n", "grd", function() vim.lsp.buf.definition({ loclist = true }) end, { desc = "vim.lsp.buf.definition()" } }, -- prefer to use `gri`
      { "n", "grD", function() vim.lsp.buf.declaration({ loclist = true }) end, { desc = "vim.lsp.buf.declaration()" } }, -- prefer to use `gri`
      { "n", "gri", function() vim.lsp.buf.implementation({ loclist = true }) end, { desc = "vim.lsp.buf.implementation()" } },
      { "n", "grr", function() vim.lsp.buf.references(nil, { loclist = true }) end, { desc = "vim.lsp.buf.references()" } },
      { "n", "grt", function() vim.lsp.buf.type_definition({ loclist = true }) end, { desc = "vim.lsp.buf.type_definition()" } },
    },
    "Create LSP keymap",
    function(_, map_opts)
      map_opts[4].buffer = bufnr
      tied.create_map(unpack(map_opts))
    end
  )

  -- Prevent semantic tokens from interfering with treesitter highlighting
  if client:supports_method("textDocument/semanticTokens") then
    -- Set < 100 to not overwrite treesitter
    -- vim.highlight.priorities.semantic_tokens = 95
  end
end, tied.do_nothing)

-- M.config.capabilities = {}

return M
