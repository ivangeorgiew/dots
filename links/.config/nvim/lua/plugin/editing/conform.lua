--- @type MyLazySpec
local M = {
  -- File formatter by filetype
  "stevearc/conform.nvim",
  event = tied.LazyEvent,
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "alejandra" },
      -- javascript = { "prettierd" },
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
      "Go through all conform formatters",
      opts.formatters_by_ft,
      function(_, formatters)
        tied.each_i(
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
