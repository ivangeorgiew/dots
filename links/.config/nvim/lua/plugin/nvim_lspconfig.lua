local S = vim.diagnostic.severity

--- @type PluginSpec
local M = {
  -- Provides good default LSP configs
  -- :h lspconfig
  src = "neovim/nvim-lspconfig",
  lazy = true,
  opts = {
    --- @type vim.diagnostic.Opts
    diagnostics = {
      update_in_insert = false,
      severity_sort = true,
      underline = false,
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

M.config = tie("Plugin nvim-lspconfig -> config", function(opts)
  tied.for_list("Setup an LSP", require("lsp"), function(_, lsp)
    if lsp.config then
      vim.lsp.config(lsp.lsp_name, lsp.config)
    end

    if lsp.enable ~= false then
      vim.lsp.enable(lsp.lsp_name)
    end
  end)

  tied.do_block("Set color highlighting style", function()
    -- Disable by default for performance (has toggle keybind)
    vim.lsp.document_color.enable(false, {}, { style = "virtual" })
  end)

  tied.do_block(
    "Set diagnostics options",
    function() vim.diagnostic.config(opts.diagnostics) end
  )

  tied.set_hl(0, "LspInlayHint", { link = "Comment" })
end, tied.do_nothing)

return M
