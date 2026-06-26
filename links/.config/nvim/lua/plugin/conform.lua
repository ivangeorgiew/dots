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
    custom = {
      ---@type table<string,string[]> Custom table that specifies formatters for multiple filetypes
      fts_by_formatter = {},
    },
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "alejandra" },
      javascript = { "prettierd" },
    },
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      prettierd = { require_cwd = true },

      -- Experimental formatter for code chunks of different language than the filetype
      -- injected = { options = { ignore_errors = true } },
    },
    log_level = vim.log.levels.WARN,
    notify_no_formatters = false,
    notify_on_error = true,
    default_format_opts = {
      lsp_format = "fallback", ---@type "never"|"fallback"|"prefer"|"first"|"last"
    },
    format_on_save = { timeout_ms = 1000 }, -- sync formatting before saving (preferred)
    -- format_after_save = { timeout_ms = 3000 }, -- async formatting after saving
  },
}

---@type tied.create_map.args[]
M.opts.custom.maps = {
  -- stylua: ignore start
  { "n", "<leader>tF", ":lua vim.b.no_autoformat = not vim.b.no_autoformat<cr>", { desc = "Toggle buffer auto-formatting" }, },
  -- stylua: ignore end
}

M.opts.custom.set_format_opts = tie(
  "Plugin conform -> Set format_*",
  ---@param opts_key string
  function(opts_key)
    vim.validate("opts_key", opts_key, "string")

    if not M.opts[opts_key] then
      return
    end

    ---@type conform.FormatOpts?
    local format_opts = M.opts[opts_key]

    M.opts[opts_key] = tie(
      "Plugin conform -> " .. opts_key,
      ---@param bufnr integer
      ---@return conform.FormatOpts?
      function(bufnr)
        if not tied.check_if_buf_is_file(bufnr) then
          return
        end

        local path = vim.api.nvim_buf_get_name(bufnr)

        if vim.b[bufnr].no_autoformat or path:match("/node_modules/") then
          return
        end

        return format_opts
      end,
      tied.do_nothing
    )
  end,
  tied.do_nothing
)

M.config = tie("Plugin conform -> config", function(opts)
  local custom = opts.custom

  tied.do_block("Plugin conform -> Modify options", function()
    -- Run prettierd only if prettier is installed
    vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = 1

    tied.for_table(
      "Setup plugin conform fts_by_formatter",
      custom.fts_by_formatter,
      function(formatter, filetypes)
        for _, ft in ipairs(filetypes) do
          opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
          table.insert(opts.formatters_by_ft[ft], formatter)
        end
      end
    )

    custom.set_format_opts("format_on_save")
    custom.set_format_opts("format_after_save")

    tied.for_list(
      "Plugin conform -> Create keymap",
      custom.maps,
      function(_, map_args) tied.create_map(unpack(map_args)) end
    )
  end)

  opts.custom = nil
  require("conform").setup(opts)

  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
end, tied.do_nothing)

return M
