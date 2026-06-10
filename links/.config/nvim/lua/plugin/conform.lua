--- @module "conform"
--- @type PluginSpec
local M = {
  -- File formatter by filetype
  src = "stevearc/conform.nvim",
  lazy = true,
  ---@type conform.setupOpts
  opts = {
    -- NOTE: In addition to the vim doc, there are recipes and explanations on:
    -- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "alejandra" },
      javascript = { "prettierd" },
    },
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      -- Experimental formatter for code chunks of different language than the filetype
      -- injected = { options = { ignore_errors = true } },
    },
    notify_no_formatters = true,
    notify_on_error = true,
    default_format_opts = {
      timeout_ms = 3000,
      lsp_format = "never", ---@type "never"|"fallback"|"prefer"|"first"|"last"
    },
    format_on_save = {}, -- {} == default_format_opts
  },
}

M.config = tie("Plugin conform -> config", function(opts)
  require("conform").setup(opts)

  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

  tied.do_block("Plugin conform -> Install formatters with mason", function()
    local to_install = {}

    tied.for_table(
      "Go through all conform formatters",
      opts.formatters_by_ft,
      function(_, formatters)
        tied.for_list(
          "Queue a code formatter for install with mason",
          formatters,
          function(_, formatter)
            if type(formatter) == "string" then
              to_install[#to_install + 1] = formatter
            end
          end
        )
      end
    )

    tied.mason_install(to_install)
  end)
end, tied.do_nothing)

return M
