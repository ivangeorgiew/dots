--- @module "conform"
--- @type plugin_spec
local M = {
  -- File formatter by filetype
  src = "stevearc/conform.nvim",
  lazy = true,
  ---@type conform.setupOpts
  opts = {
    -- NOTE: In addition to the vim doc, there are recipes and explanations on:
    -- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md
    -- NOTE: Every filetype can have additional options specified
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "alejandra" },
      javascript = { "prettierd" },
    },
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      ["biome-check"] = { require_cwd = true },

      -- Experimental formatter for code chunks of different language than the filetype
      -- injected = { options = { ignore_errors = true } },
    },
    notify_no_formatters = false,
    notify_on_error = true,
    default_format_opts = {
      timeout_ms = 3000,
      lsp_format = "fallback", ---@type "never"|"fallback"|"prefer"|"first"|"last"
    },
    format_on_save = {}, -- {} == default_format_opts
  },
}

M.config = tie("Plugin conform -> config", function(opts)
  tied.do_block("Modify formatters", function()
    -- Run prettierd only if prettier is installed
    vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = 1

    tied.for_list(
      "Add biome as formatter for ft",
      require("lsp.biome").config.filetypes,
      function(_, ft)
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "biome-check")
      end
    )
  end)

  require("conform").setup(opts)

  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
end, tied.do_nothing)

return M
