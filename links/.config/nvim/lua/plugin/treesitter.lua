-- TODO: `nvim-treesitter/nvim-treesitter` is currently archived
-- So for now it's replaced by `neovim-treesitter/nvim-treesitter`
-- Check https://github.com/arborist-ts/arborist.nvim
-- Check https://github.com/romus204/tree-sitter-manager.nvim

--- @type LazyPluginSpec
local M = {
  -- Language parsing which provides better highlight, indentation, etc.
  -- :h nvim-treesitter.txt
  "neovim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" },
  branch = "main",
  build = ":TSUpdate",
  event = tied.LazyEvent,
  opts = {
    custom = {
      installed = {},
      --- @type table<string, { enable: boolean?, ignore: table? }>
      queries = {
        highlights = {},
        indents = { ignore = { "lua" } },
        folds = {},
      },
      ignore = {
        "comment", -- interferes when todo-comments.nvim
      },
    },
  },
}

M.opts.custom.delete_parsers = tie(
  "Plugin treesitter -> Delete parsers",
  ---@param ensure_installed string[]
  function(ensure_installed)
    vim.validate("ensure_installed", ensure_installed, "table")

    local ts = require("nvim-treesitter")
    local custom = M.opts.custom
    local to_delete = {}

    tied.each_i(
      "Add treesitter parser for deletion",
      custom.installed,
      function(_, parser)
        if
          not vim.list_contains(ensure_installed, parser)
          or vim.list_contains(custom.ignore, parser)
        then
          to_delete[#to_delete + 1] = parser
        end
      end
    )

    if #to_delete > 0 then
      ts.uninstall(to_delete, { max_jobs = 8, summary = true })
        :await(function() custom.installed = ts.get_installed() end)
    end
  end,
  tied.do_nothing
)

M.opts.custom.install_parsers = tie(
  "Plugin treesitter -> Install parsers",
  function()
    local ts = require("nvim-treesitter")
    local custom = M.opts.custom
    local ensure_installed = ts.get_available()
    local to_install = {}

    tied.each_i(
      "Add treesitter parser for installation",
      ensure_installed,
      function(_, parser)
        if
          not vim.list_contains(custom.installed, parser)
          and not vim.list_contains(custom.ignore, parser)
        then
          to_install[#to_install + 1] = parser
        end
      end
    )

    if #to_install > 0 then
      ts.install(to_install, { max_jobs = 8, summary = true }):await(function()
        custom.installed = ts.get_installed()
        custom.delete_parsers(ensure_installed)
      end)
    else
      custom.delete_parsers(ensure_installed)
    end
  end,
  tied.do_nothing
)

M.opts.custom.should_enable = tie(
  "Plugin treesitter -> Should enable query?",
  ---@param lang string
  ---@param query string
  function(lang, query)
    vim.validate("lang", lang, "string")
    vim.validate("query", query, "string")

    local c = M.opts.custom.queries[query]
    local query_enabled = c.enable ~= false
    local lang_not_ignored = not vim.list_contains(c.ignore or {}, lang)
    local lang_supports_query = vim.treesitter.query.get(lang, query) ~= nil

    return query_enabled and lang_not_ignored and lang_supports_query
  end,
  function() return false end
)

M.config = tie("Plugin nvim-treesitter -> config", function(_, opts)
  local ts = require("nvim-treesitter")
  local custom = M.opts.custom

  ts.setup(opts)

  custom.installed = ts.get_installed()
  custom.install_parsers()
end, tied.do_nothing)

M.init = tie("Plugin treesitter -> init", function()
  tied.create_autocmd({
    desc = "Setup treesitter for a buffer",
    group = tied.create_augroup("my.treesitter.setup", true),
    event = "FileType",
    callback = vim.schedule_wrap(function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match)
      local should_enable = M.opts.custom.should_enable

      -- Don't check if lang is installed
      if not lang then
        return
      end

      if should_enable(lang, "highlights") then
        pcall(vim.treesitter.start, ev.buf)
      end

      if should_enable(lang, "indents") then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      if should_enable(lang, "folds") then
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end
    end),
  })
end, tied.do_nothing)

return M
