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
  -- Do defaults setup before enabling LSPs

  tied.set_hl(0, "LspInlayHint", { link = "Comment" })

  tied.do_block(
    "Setup diagnostics",
    function() vim.diagnostic.config(opts.diagnostics) end
  )

  tied.do_block("Setup lsp document_color", function()
    -- Disable by default (has toggle keybind)
    vim.lsp.document_color.enable(false, {}, { style = "virtual" })
  end, tied.do_nothing)

  tied.do_block("Setup lsp semantic_tokens", function()
    -- Disable by default (enable in a specific lsp's `on_init` if needed)
    vim.lsp.semantic_tokens.enable(false)

    -- TODO: remove when bug is fixed https://github.com/neovim/neovim/issues/40208
    local log_error = vim.lsp.log.error
    vim.lsp.log.error = tie("Log lsp error", function(...)
      local args = vim.F.pack_len(...)

      if args[1] == "semantic_tokens" then
        return vim.lsp.log.debug(vim.F.unpack_len(args))
      end

      return log_error(vim.F.unpack_len(args))
    end, tied.do_nothing)
  end)

  tied.do_block("Config, enable and install LSPs", function()
    local to_install = {}

    tied.for_list("Setup an LSP", require("lsp"), function(_, lsp)
      if lsp.config then
        vim.lsp.config(lsp.lsp_name, lsp.config)
      end

      if lsp.enable ~= false then
        vim.lsp.enable(lsp.lsp_name)

        if lsp.pkg_name then
          to_install[lsp.pkg_name] = true
        end
      end
    end)

    tied.mason_install(vim.tbl_keys(to_install))
  end)
end, tied.do_nothing)

return M
