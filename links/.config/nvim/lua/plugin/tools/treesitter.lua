--- @class MyLazySpec
local M = {
  -- Language parsing which provides better highlight, indentation, etc.
  -- :h nvim-treesitter.txt
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = tied.LazyEvent,
  cmd = {
    "TSUpdate",
    "TSInstall",
    "TSInstallFromGrammar",
    "TSLog",
    "TSUninstall",
  },
  extra = {
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
}

M.extra.delete_ignored = tie("Plugin treesitter -> Delete parsers", function()
  local ts = require("nvim-treesitter")
  local to_delete = {}

  tied.each_i(
    "Add treesitter parser for deletion",
    M.extra.installed,
    function(_, parser)
      if vim.list_contains(M.extra.ignore, parser) then
        to_delete[#to_delete + 1] = parser
      end
    end
  )

  if #to_delete > 0 then
    ts.uninstall(to_delete, { summary = true })
      :await(function() M.extra.installed = ts.get_installed() end)
  end
end, tied.do_nothing)

M.extra.install_parsers = tie("Plugin treesitter -> Install parsers", function()
  local ts = require("nvim-treesitter")
  local ensure_installed = {
    unpack(ts.get_available(1)), -- stable
    unpack(ts.get_available(2)), -- unstable
  }
  local to_install = {}

  tied.each_i(
    "Add treesitter parser for installation",
    ensure_installed,
    function(_, parser)
      if
        not vim.list_contains(M.extra.installed, parser)
        and not vim.list_contains(M.extra.ignore, parser)
      then
        to_install[#to_install + 1] = parser
      end
    end
  )

  if #to_install > 0 then
    ts.install(to_install, { summary = true }):await(function()
      M.extra.installed = ts.get_installed()
      M.extra.delete_ignored()
    end)
  end
end, tied.do_nothing)

M.extra.should_enable = tie(
  "Plugin treesitter -> Should enable query?",
  ---@param lang string
  ---@param query string
  function(lang, query)
    vim.validate("lang", lang, "string")
    vim.validate("query", query, "string")

    local c = M.extra.queries[query]
    local query_enabled = c.enable ~= false
    local lang_not_ignored = not vim.list_contains(c.ignore or {}, lang)
    local lang_supports_query = (vim.treesitter.query.get(lang, query) ~= nil)

    return query_enabled and lang_not_ignored and lang_supports_query
  end,
  function() return false end
)

M.config = tie("Plugin nvim-treesitter -> config", function(_, opts)
  local ts = require("nvim-treesitter")

  -- Make sure we're on the "main" branch
  assert(ts.get_installed, "You need to update `nvim-treesitter`")

  ts.setup(opts)

  M.extra.installed = ts.get_installed()
  M.extra.install_parsers()

  tied.create_autocmd({
    desc = "Enable treesitter queries",
    group = tied.create_augroup("my.treesitter.on_filetype", true),
    event = "FileType",
    callback = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match)

      if not lang or not vim.list_contains(M.extra.installed, lang) then
        return
      end

      if M.extra.should_enable(lang, "highlights") then
        pcall(vim.treesitter.start, ev.buf)
        -- vim.notify("Setup highlighting for: "..lang)
      else
        pcall(vim.treesitter.stop, ev.buf)
      end

      if M.extra.should_enable(lang, "indents") then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        -- vim.notify("Setup indenting for: "..lang)
      end

      if M.extra.should_enable(lang, "folds") then
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        -- vim.notify("Setup folding for: "..lang)
      end
    end,
  })
end, tied.do_nothing)

return M
