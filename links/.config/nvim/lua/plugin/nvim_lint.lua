-- TODO: Add to statusline with https://github.com/mfussenegger/nvim-lint#get-the-current-running-linters-for-your-buffer
-- NOTE: Modify built-in linters: https://github.com/mfussenegger/nvim-lint#customize-built-in-linters
-- NOTE: Create custom linters: https://github.com/mfussenegger/nvim-lint#custom-linters

--- @type PluginSpec
local M = {
  src = "mfussenegger/nvim-lint",
  name = "lint",
  lazy = true,
  opts = {
    linters_by_ft = {
      javascript = { "eslint_d" },
    },
    alt_js_filetypes = {
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
    },
  },
}

M.opts.lint = tied.debounce_wrap(
  "Plugin nvim-lint -> lint",
  100,
  --- @param opts lint.try_lint.Opts?
  function(opts)
    vim.validate("opts", opts, "table", true)

    local bufnr = vim.api.nvim_get_current_buf()

    if tied.check_if_buf_is_file(bufnr) then
      require("lint").try_lint(nil, opts)
    end
  end
)

M.config = tie("Plugin nvim-lint -> config", function(opts)
  local nvim_lint = require("lint")
  local lint = M.opts.lint

  tied.do_block("Plugin nvim-lint -> Set javascript settings", function()
    tied.for_list(
      "Add alt js filetype to nvim-lint's linters_by_ft",
      opts.alt_js_filetypes,
      function(_, ft) opts.linters_by_ft[ft] = opts.linters_by_ft.javascript end
    )

    vim.env.ESLINT_D_PPID = vim.fn.getpid() -- Recommended eslint_d setting
  end)

  nvim_lint.linters_by_ft = opts.linters_by_ft

  lint() -- Run for current buffer

  tied.create_autocmd({
    desc = "Lint buffer",
    group = tied.create_augroup("my.nvim-lint.run_lint", true),
    event = { "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" },
    callback = function(e)
      if vim.list_contains({ "InsertLeave", "TextChanged" }, e.event) then
        -- Only run linters which can work with unsaved file
        lint({ filter = "stdin" })
      else
        lint()
      end
    end,
  })
end, tied.do_nothing)

return M
