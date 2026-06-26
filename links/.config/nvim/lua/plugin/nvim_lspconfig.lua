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

  tied.for_list("Setup an LSP", require("lsp"), function(_, lsp)
    local on_init = tie(
      "LSP -> Set generic settings on init",
      function(client, _)
        if lsp.features then
          tied.set_lsp_features(client.id, lsp.features)
        end

        if vim.tbl_get(lsp, "config", "on_init") then
          lsp.config.on_init(client, _)
        end
      end,
      tied.do_nothing
    )

    if lsp.exe then
      table.insert(tied.exes, lsp.exe)
    end

    vim.lsp.config(
      lsp.name,
      vim.tbl_deep_extend("force", lsp.config or {}, { on_init = on_init })
    )

    if lsp.enabled ~= false then
      vim.lsp.enable(lsp.name)
    end
  end)
end, tied.do_nothing)

return M
