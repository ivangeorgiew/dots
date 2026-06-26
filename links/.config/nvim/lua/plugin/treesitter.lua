-- TODO: `nvim-treesitter/nvim-treesitter` is currently archived
-- So for now it's replaced by `neovim-treesitter/nvim-treesitter`
-- Check https://github.com/arborist-ts/arborist.nvim

-- NOTE: Some files which helped for auto installing parsers/queries
-- https://github.com/neovim-treesitter/nvim-treesitter/blob/main/lua/nvim-treesitter/parsers.lua
-- https://github.com/neovim-treesitter/nvim-treesitter/blob/main/runtime/queries/lua/injections.scm

--- @type plugin_spec
local M = {
  -- Language parsing which provides better highlight, indentation, etc.
  -- :h nvim-treesitter.txt
  src = "neovim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" },
  build = ":TSUpdate",
  lazy = false,
  opts = {
    -- NOTE: need to manually set install_dir due to a bug
    -- where rtp is not being set on fresh install of all plugins
    install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
  },
  custom = {
    ---@type string[]
    ignore = {
      "comment", -- interferes when todo-comments.nvim
      "kitty", -- broken highlighting and unneeded
    },
    ---@type table<string, { enable: boolean?, ignore: string[]? }>
    queries = {
      highlights = {},
      indents = { enable = false },
      folds = {},
    },
    -- Inner config
    available = {}, ---@type table<string, boolean>
    seen_langs = {}, ---@type table<string, boolean>
  },
}

M.custom.get_installed = tie(
  "Get list of treesitter installed langs",
  ---@return table<string,boolean>
  function()
    local ts = require("nvim-treesitter")

    return vim.iter(ts.get_installed()):fold({}, function(acc, lang)
      acc[lang] = true
      return acc
    end)
  end,
  tied.do_rethrow
)

M.custom.get_injected_langs = tie(
  "Get injected languages",
  ---@param installed string[]
  function(installed)
    vim.validate("installed", installed, "table")

    local injected = {}

    tied.for_list(
      "Check installed lang for injections",
      installed,
      function(_, lang)
        if not vim.treesitter.language.add(lang) then
          return
        end

        local patterns = vim.tbl_get(
          vim.treesitter.query.get(lang, "injections") or {},
          "info",
          "patterns"
        )

        if patterns then
          tied.for_list(
            "Collect injections in a language",
            vim.iter(patterns):flatten():totable(),
            function(_, pattern)
              local predicate, directive, inj = unpack(pattern)

              -- stylua: ignore
              if inj ~= lang and predicate == "set!" and directive == "injection.language" then
                injected[inj] = true
              end
            end
          )
        end
      end
    )

    return vim.tbl_keys(injected)
  end,
  function() return {} end
)

M.custom.delete_ignored_langs = tie(
  "Plugin nvim-treesitter -> Delete ignored languages",
  function()
    local ts = require("nvim-treesitter")
    local installed = M.custom.get_installed()
    local to_delete = {}

    tied.for_list(
      "Add treesitter language for deletion",
      M.custom.ignore,
      function(_, lang)
        if installed[lang] then
          to_delete[lang] = true
        end
      end
    )

    to_delete = vim.tbl_keys(to_delete)

    if #to_delete > 0 then
      ts.uninstall(to_delete, { max_jobs = 8, summary = true })
    end
  end,
  tied.do_nothing
)

M.custom.install_langs = tie(
  "Plugin nvim-treesitter -> Install languages",
  ---@param ensure_installed string[]
  ---@return boolean
  function(ensure_installed)
    vim.validate("ensure_installed", ensure_installed, "table")

    local ts = require("nvim-treesitter")
    local ts_parsers = require("nvim-treesitter.parsers")
    local installed = M.custom.get_installed()
    local queue = vim.deepcopy(ensure_installed)
    local to_install = {}

    while #queue > 0 do
      local lang = table.remove(queue, 1)

      -- Add langs from recursive calls
      M.custom.seen_langs[lang] = true

      if
        M.custom.available[lang]
        and not installed[lang]
        and not vim.list_contains(M.custom.ignore, lang)
      then
        tied.for_list(
          "Add all dependencies to queue",
          vim.tbl_get(ts_parsers, lang, "requires") or {},
          function(_, dep) table.insert(queue, dep) end
        )

        to_install[lang] = true
      end
    end

    to_install = vim.tbl_keys(to_install)

    if #to_install == 0 then
      return false
    end

    ts.install(to_install, { max_jobs = 8, summary = true })
      :await(tie("Update things after installing treesitter langs", function()
        -- Reload to get access to new injections so you can install them
        package.loaded["vim.treesitter.query"] = nil
        vim.treesitter.query = require("vim.treesitter.query")

        local injected = M.custom.get_injected_langs(to_install)
        local is_installing = M.custom.install_langs(injected)

        -- Every other task is finished because of :await()
        -- and last call didn't install any new langs
        if not is_installing then
          vim.notify("[treesitter]: Finished installs. Restart neovim!")
        end
      end, tied.do_nothing))

    return true
  end,
  function() return false end
)

M.custom.should_enable = tie(
  "Plugin nvim-treesitter -> Should enable query?",
  ---@param lang string
  ---@param query string
  function(lang, query)
    vim.validate("lang", lang, "string")
    vim.validate("query", query, "string")

    local c = M.custom.queries[query]
    local query_enabled = c.enable ~= false
    local lang_not_ignored = not vim.list_contains(c.ignore or {}, lang)
    local lang_supports_query = vim.treesitter.query.get(lang, query) ~= nil

    return query_enabled and lang_not_ignored and lang_supports_query
  end,
  function() return false end
)

M.config = tie("Plugin nvim-treesitter -> config", function(opts)
  local ts = require("nvim-treesitter")

  ts.setup(opts)

  for _, lang in ipairs(ts.get_available()) do
    M.custom.available[lang] = true
  end

  M.custom.delete_ignored_langs()
  M.custom.install_langs(vim.tbl_keys(M.custom.seen_langs))

  -- NOTE: High perf cost to check for unfinished installs of injected langs
  -- Run this command once in a while manually instead
  tied.create_usercmd("TSInstallInjected", function()
    local installed = ts.get_installed()
    local injected = M.custom.get_injected_langs(installed)

    M.custom.install_langs(injected)
  end, { desc = "Install all injected parsers", nargs = 0 })
end, tied.do_nothing)

M.init = tie("Plugin nvim-treesitter -> init", function()
  tied.create_autocmd({
    desc = "Setup treesitter for a buffer",
    group = tied.create_augroup("my.treesitter.setup", true),
    event = "FileType",
    callback = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match)
      local should_enable = M.custom.should_enable

      if not lang then
        return
      end

      if not M.custom.seen_langs[lang] then
        -- Used to both prevent needless fn calls
        -- and to install langs from before plugin load
        M.custom.seen_langs[lang] = true

        if tied.plugin_loaded("nvim-treesitter") then
          M.custom.install_langs({ lang })
        end
      end

      if not vim.treesitter.language.add(lang) then
        return
      end

      if should_enable(lang, "highlights") then
        pcall(vim.treesitter.start)
      end

      if should_enable(lang, "indents") then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      if should_enable(lang, "folds") then
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end
    end,
  })
end, tied.do_nothing)

return M
