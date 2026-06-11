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

M.config = tie("Plugin nvim-lint -> config", function(opts)
  local nvim_lint = require("lint")

  tied.for_list(
    "Add alt js filetype to nvim-lint's linters_by_ft",
    opts.alt_js_filetypes,
    function(_, ft) opts.linters_by_ft[ft] = opts.linters_by_ft.javascript end
  )

  nvim_lint.linters_by_ft = opts.linters_by_ft

  -- Recommended eslint_d settings
  vim.env.ESLINT_D_PPID = vim.fn.getpid()

  tied.create_autocmd({
    desc = "Lint buffer",
    group = tied.create_augroup("my.nvim-lint.run_lint", true),
    event = { "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" },
    callback = tied.debounce_wrap("Lint buffer", 100, function(e)
      local lint_opts = {}

      -- Only run linters which can work with unsaved file
      if vim.list_contains({ "InsertLeave", "TextChanged" }, e.event) then
        lint_opts.filter = "stdin"
      end

      nvim_lint.try_lint(nil, lint_opts)
    end),
  })
end, tied.do_nothing)

return M
