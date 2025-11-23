--- @type MyLazySpec
local M = {
  -- Provides good default LSP configs
  "neovim/nvim-lspconfig",
  event = "User FilePost",
  -- :h lspconfig
  extra = {
    defaults = {
      -- TODO: Check plugins like https://github.com/antosha417/nvim-lsp-file-operations
      -- capabilities = vim.lsp.protocol.make_client_capabilities(),
    },
  },
}
M.extra.defaults.on_attach = tie("LSP * -> on_attach", function(client, bufnr)
  tied.do_block("Setup LSP keymaps", function()
    -- stylua: ignore
    tied.each_i(
      {
        { "gra", { "n", "v" } },
        { "gri", { "n", "v" } },
        { "grn", { "n", "v" } },
        { "grr", { "n", "v" } },
        { "grt", { "n", "v" } },
      },
      "Delete default LSP keymap",
      function(_, map_opts)
        tied.delete_map(unpack(map_opts))
      end
    )

    local p = "-" -- mapping prefix

    -- stylua: ignore
    tied.each_i(
      {
        { "n", p .. "e", function() local h = vim.diagnostic.open_float; h(); h(); end, { desc = "Show errors on current line" } },
        { "n", p .. "h", function() local h = vim.lsp.buf.hover; h(); h(); end, { desc = "Show hover popup" } },
        { "n", p .. "s", function() local h = vim.lsp.buf.signature_help; h(); h(); end, { desc = "Show function signature" } },
        -- { "n", p .. "D", function() vim.lsp.buf.declaration({ loclist = true }) end, { desc = "Go to declaration" } }, -- prefer `implementation`
        -- { "n", p .. "d", function() vim.lsp.buf.definition({ loclist = true }) end, { desc = "Go to definition" } }, -- prefer `implementation`
        { "n", p .. "i", function() vim.lsp.buf.implementation({ loclist = true }) end, { desc = "Go to implementation" } },
        { "n", p .. "t", function() vim.lsp.buf.type_definition({ loclist = true }) end, { desc = "Go to type definition" } },
        { "n", p .. "r", function() vim.lsp.buf.references(nil, { loclist = true }) end, { desc = "Show references" } },
        { "n", p .. "n", function() vim.lsp.buf.rename() end, { desc = "Rename variable" } },
        { { "n", "v" }, p .. "a", function() vim.lsp.buf.code_action() end, { desc = "Select code action" } },
        { "n", "<leader>ti", function() vim.lsp.inlay_hint.enable( not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr }) end, { desc = "Toggle inlay hints" } },
      },
      "Create LSP keymap",
      function(_, map_opts)
        map_opts[4].buffer = bufnr
        tied.create_map(unpack(map_opts))
      end
    )

    tied.on_plugin_load(
      { "which-key.nvim" },
      "Modify LSP keymaps in which-key",
      function() require("which-key").add({ p, group = "LSP" }) end
    )
  end)

  -- NOTE: can use :Inspect to show hl group and priority used at cursor
  tied.do_block("Lower semantic tokens highlight priority", function()
    if client:supports_method("textDocument/semanticTokens") then
      -- vim.highlight.priorities.semantic_tokens = 95
    end
  end)
end, tied.do_nothing)

M.config = tie("Plugin nvim-lspconfig -> config", function()
  tied.do_block(
    "Plugin nvim-lspconfig -> Setup defaults",
    function() vim.lsp.config("*", M.extra.defaults) end
  )

  tied.do_block("Plugin nvim-lspconfig -> Setup LSPs", function()
    local to_install = {}

    tied.each_i(require("lsp"), "Setup an LSP", function(_, lsp)
      if lsp.config then
        vim.lsp.config(lsp.lsp_name, lsp.config)
      end

      if lsp.enable ~= false then
        vim.lsp.enable(lsp.lsp_name)

        if lsp.pkg_name then
          to_install[#to_install + 1] = lsp.pkg_name
        end
      end
    end)

    tied.mason_install(to_install)
  end)

  -- NOTE: Example inlay hints configs: https://github.com/MysticalDevil/inlay-hints.nvim/tree/master
  tied.set_hl(0, "LspInlayHint", { link = "Comment" })
end, tied.do_nothing)

return M
