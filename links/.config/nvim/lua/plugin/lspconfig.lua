local S = vim.diagnostic.severity

--- @type PluginSpec
local M = {
  -- Provides good default LSP configs
  -- :h lspconfig
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  opts = {
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
        wrap = true,
        severity = { S.ERROR, S.WARN },
      },
    },
  },
}

M.config = tie("Plugin nvim-lspconfig -> config", function(_, opts)
  tied.do_block("Config, enable and install LSPs", function()
    local to_install = {}

    tied.for_list("Setup an LSP", require("lsp"), function(_, lsp)
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

  tied.do_block(
    "Set color highlighting",
    function() vim.lsp.document_color.enable(true, {}, { style = "virtual" }) end
  )

  tied.do_block(
    "Set vim.diagnostic options",
    function() vim.diagnostic.config(opts.diagnostics) end
  )

  -- NOTE: Example inlay hints configs: https://github.com/MysticalDevil/inlay-hints.nvim/tree/master
  tied.set_hl(0, "LspInlayHint", { link = "Comment" })
end, tied.do_nothing)

return M
