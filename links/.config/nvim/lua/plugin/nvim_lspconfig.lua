local S = vim.diagnostic.severity

--- @type plugin_spec
local M = {
  -- Provides good default LSP configs
  -- :h lspconfig
  src = "neovim/nvim-lspconfig",
  lazy = true,
  opts = {
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
      float = { source = false, severity_sort = true },
      jump = { wrap = true, severity = { S.ERROR, S.WARN } },
    },
  },
}

M.config = tie("Plugin nvim-lspconfig -> config", function(opts)
  -- To enable any feature, call this function in an LSP's on_init
  tied.set_lsp_features(nil, {
    semantic_tokens = false,
    codelens = false,
    document_color = false,
    inline_completion = false,
    linked_editing_range = false,
    on_type_formatting = false,
  })

  tied.create_autocmd({
    desc = "Remove built-in LSP defaults",
    event = "LspAttach",
    group = tied.create_augroup("my.lsp.attach.remove_defaults", true),
    callback = function(ev)
      vim.bo[ev.buf].formatexpr = nil
      vim.bo[ev.buf].omnifunc = nil
      vim.bo[ev.buf].tagfunc = nil
    end,
  })

  tied.set_hl(0, "LspInlayHint", { link = "Comment" })

  tied.do_block(
    "Set diagnostics config",
    function() vim.diagnostic.config(opts.diagnostics) end
  )

  tied.do_block("Fix lsp issues", function()
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
    tied.for_list("Setup an LSP", require("lsp"), function(_, lsp)
      if lsp.config then
        vim.lsp.config(lsp.lsp_name, lsp.config)
      end

      if lsp.enable ~= false then
        vim.lsp.enable(lsp.lsp_name)
      end
    end)
  end)
end, tied.do_nothing)

return M
