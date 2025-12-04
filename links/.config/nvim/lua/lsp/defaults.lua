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
    map_prefix = "-",
    --- @type vim.lsp.LocationOpts
    map_list_opts = { loclist = true },
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

---@type KeymapSetArgs[]
-- stylua: ignore
M.extra.keys = {
  { "n", "<leader>ti", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 }) end, { desc = "Toggle inlay hints" } },

  -- NOTE: `_` is substituted with `map_prefix`
  { "n", "_e", function() vim.diagnostic.open_float() end, { desc = "Show line errors" } },
  { "n", "_k", function() vim.lsp.buf.hover() end, { desc = "Show documentation popup" } },
  { "n", "_j", function() vim.lsp.buf.signature_help() end, { desc = "Show function signature" } },
  { "n", "_u", function() vim.lsp.buf.rename() end, { desc = "Rename variable" } },
  { "n", "_D", function() vim.lsp.buf.declaration(M.extra.map_list_opts) end, { desc = "Go to declaration" } }, -- prefer `implementation`
  { "n", "_d", function() vim.lsp.buf.definition(M.extra.map_list_opts) end, { desc = "Go to definition" } }, -- prefer `implementation`
  { "n", "_i", function() vim.lsp.buf.implementation(M.extra.map_list_opts) end, { desc = "Go to implementation" } },
  { "n", "_t", function() vim.lsp.buf.type_definition(M.extra.map_list_opts) end, { desc = "Go to type definition" } },
  { "n", "_r", function() vim.lsp.buf.references(nil, M.extra.map_list_opts) end, { desc = "Show references" } },
  { { "n", "x" }, "_a", function() vim.lsp.buf.code_action() end, { desc = "Select code action" } },
}

M.config.on_attach = tie("LSP * -> on_attach", function(client, bufnr)
  tied.do_block("Create LSP keymaps", function()
    tied.each_i("Create LSP keymap", M.extra.keys, function(_, map_opts)
      map_opts[2] = map_opts[2]:gsub("^_", M.extra.map_prefix)
      map_opts[4].buffer = bufnr

      tied.create_map(unpack(map_opts))
    end)

    tied.on_plugin_load(
      "which-key.nvim",
      "Modify LSP maps in which-key",
      function() require("which-key").add({ M.extra.map_prefix, group = "LSP" }) end
    )
  end)

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
