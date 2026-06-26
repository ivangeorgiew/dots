--- @module "conform"
--- @type plugin_spec
local M = {
  -- File formatter by filetype
  src = "stevearc/conform.nvim",
  lazy = true,
  custom = {
    -- Required globally installed executables
    exes = { "stylua", "alejandra", "prettierd" },
    ---@type table<string,string[]> Set formatters for multiple filetypes
    fts_by_formatter = {},
  },
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
      -- prettierd = { require_cwd = true },

      -- Experimental formatter for code chunks of different language than the filetype
      -- injected = { options = { ignore_errors = true } },
    },
    log_level = vim.log.levels.WARN,
    notify_no_formatters = false,
    notify_on_error = false,
    default_format_opts = {
      lsp_format = "first",
      timeout_ms = 1000,
    },
  },
}

M.config = tie("Plugin conform -> config", function(opts)
  local conform = require("conform")

  tied.do_block("Plugin conform -> Modify options", function()
    -- Run prettierd only if prettier is installed
    vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = 1

    vim.list_extend(tied.exes, M.custom.exes)

    tied.for_table(
      "Setup plugin conform fts_by_formatter",
      M.custom.fts_by_formatter,
      function(formatter, filetypes)
        for _, ft in ipairs(filetypes) do
          opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
          table.insert(opts.formatters_by_ft[ft], formatter)
        end
      end
    )
  end)

  conform.setup(opts)

  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

  tied.do_block("Plugin conform -> Set keymaps", function()
    ---@type tied.create_map.args[]
    local maps = {
      -- stylua: ignore start
      { "n", "<leader>tF", ":lua vim.b.no_autoformat = not vim.b.no_autoformat<cr>", { desc = "Toggle buffer auto-formatting" }, },
      -- stylua: ignore end
    }

    tied.for_list(
      "Plugin conform -> Create keymap",
      maps,
      function(_, map_args) tied.create_map(unpack(map_args)) end
    )
  end)

  tied.do_block("Plugin conform -> Set usercmds", function()
    local report = tie("Report format erorr", function(err)
      if err then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end, tied.do_nothing)

    tied.create_usercmd(
      "ConformFormat",
      function() conform.format({ async = true }, report) end,
      { desc = "Format buffer with conform.nvim", nargs = 0 }
    )
  end)

  tied.create_autocmd({
    desc = "Format file before save",
    event = "BufWritePre",
    group = tied.create_augroup("my.plugin.conform.format_on_save", true),
    callback = function(ev)
      local bufnr = ev.buf

      if not tied.check_if_buf_is_file(bufnr) or vim.b[bufnr].no_autoformat then
        return
      end

      vim.api.nvim_exec_autocmds("User", {
        pattern = "BeforeConformFormat",
        modeline = false,
        data = {},
      })

      conform.format({ bufnr = bufnr })

      vim.api.nvim_exec_autocmds("User", {
        pattern = "AfterConformFormat",
        modeline = false,
        data = {},
      })
    end,
  })
end, tied.do_nothing)

return M
