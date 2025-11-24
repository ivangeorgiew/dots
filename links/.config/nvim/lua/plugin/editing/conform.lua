--- @type MyLazySpec
local M = {
  -- File formatter by filetype
  "stevearc/conform.nvim",
  event = "VeryLazy",
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd" },
      nix = { "alejandra" },
    },
    notify_no_formatters = false,
    notify_on_error = false,
    default_format_opts = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },
    format_on_save = true,
  },
}

M.config = tie("Plugin conform -> config", function(_, opts)
  require("conform").setup(opts)

  tied.do_block(
    "Plugin conform -> Set formatexpr",
    function() vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()" end
  )

  tied.do_block("Plugin conform -> Install formatters with mason", function()
    local to_install = {}

    tied.each(
      opts.formatters_by_ft,
      "Go through all conform formatters",
      function(_, formatters)
        tied.each_i(
          formatters,
          "Queue a code formatter for install with mason",
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
