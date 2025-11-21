--- @type table<string,MyLazySpec>
local M = {
  -- TODO: fix indentation after replace and paste
  substitute = {
    -- Adds replace and exchange commands
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    -- https://github.com/gbprod/substitute.nvim?tab=readme-ov-file
    opts = {
      highlight_substituted_text = { enabled = false },
      preserve_cursor_position = false,
    },
  },
  -- TODO: alternative is mini.pairs with LazyVim's additions
  autopairs = {
    -- Adds closing pairs (), "", etc
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    -- :h nvim-autopairs-default-values
    opts = {},
  },
  -- TODO: config and enable nvim-treesitter-textobjects
  treesitter_textobjects = {
    -- Add textobjects that depend on treesitter
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = false,
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  -- TODO: config and test it
  autotag = {
    -- Auto-add closing tags for HTML, JSX, etc
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "User FilePost",
    opts = {},
  },
  -- TODO: config
  conform = {
    -- File formatter by filetype
    "stevearc/conform.nvim",
    event = "VeryLazy",
    cmd = "ConformInfo",
    config = tie("Plugin conform -> config", function(_, opts)
      require("conform").setup(opts)
      vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
    end, tied.do_nothing),
  },
}

M.substitute.config = tie("Plugin substitute -> config", function(_, opts)
  local subs = require("substitute")
  local exch = require("substitute.exchange")

  local r = "r" -- replace key
  local x = "x" -- exchange key

  subs.setup(opts)
  tied.each_i(
    {
      { "n", r, subs.operator, { desc = "Replace" } },
      { "x", r, subs.visual, { desc = "Replace" } },
      { "n", r .. r, subs.line, { desc = "Replace Line" } },

      { "n", x, exch.operator, { desc = "Exchange" } },
      { "x", x, exch.visual, { desc = "Exchange" } },
      { "n", x .. x, exch.line, { desc = "Exchange Line" } },
      { "n", x:upper(), exch.cancel, { desc = "Exchange cancel" } },
    },
    "Plugin substitute -> Create keymap",
    function(_, map_opts) tied.create_map(unpack(map_opts)) end
  )
  tied.on_plugin_load(
    { "which-key.nvim" },
    "Modify substitute.nvim mappings for which-key",
    function()
      require("which-key").add({
        mode = { "n" },
        { r, group = "Replace", op = true },
        { x, group = "Exchange", op = true },
      })
    end
  )
end, tied.do_nothing)

M.conform.opts = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettierd" },
    nix = { "alejandra" },
  },
  notify_no_formatters = true,
  notify_on_error = true,
  default_format_opts = {
    timeout_ms = 3000,
    lsp_format = "fallback",
  },
  format_on_save = true,
}

M.conform.config = tie("Plugin conform -> config", function(_, opts)
  local to_install = {}
  local mr = require("mason-registry")

  tied.each(
    opts.formatters_by_ft,
    "Queue all code formatters for install with mason",
    function(_, formatters)
      tied.each_i(
        formatters,
        "Queue a code formatter for install with mason",
        function(_, formatter)
          if type(formatter) == "string" and mr.has_package(formatter) then
            to_install[#to_install + 1] = formatter
          end
        end
      )
    end
  )

  vim.g.mason_install(to_install)

  require("conform").setup(opts)
end, tied.do_nothing)

return M
