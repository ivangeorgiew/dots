-- TODO: `nvim-treesitter/nvim-treesitter` is currently archived
-- So for now it's replaced by `neovim-treesitter/nvim-treesitter`
-- Check https://github.com/arborist-ts/arborist.nvim

-- NOTE: Some files which helped for auto installing parsers/queries
-- https://github.com/neovim-treesitter/nvim-treesitter/blob/main/lua/nvim-treesitter/parsers.lua
-- https://github.com/neovim-treesitter/nvim-treesitter/blob/main/runtime/queries/lua/injections.scm

--- @type PluginSpec
local M = {
  -- Language parsing which provides better highlight, indentation, etc.
  -- :h nvim-treesitter.txt
  src = "neovim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" },
  version = "main",
  build = ":TSUpdate",
  lazy = true,
  opts = {
    -- NOTE: need to manually set install_dir due to a bug
    -- where rtp is not being set on fresh install of all plugins
    install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
    custom = {
      ---@type string[]
      ignore = {
        "comment", -- interferes when todo-comments.nvim
        "kitty", -- broken highlighting and unneeded
      },
      ---@type table<string, { enable: boolean?, ignore: string[]? }>
      queries = {
        highlights = {},
        indents = { ignore = { "lua" } },
        folds = {},
      },
      -- Inner config
      installed = {}, ---@type string[]
      available = {}, ---@type table<string, boolean>
      seen_langs = {}, ---@type table<string, boolean>
    },
  },
}

M.opts.custom.get_injections = tie(
  "Plugin nvim-treesitter -> Get injected languages",
  ---@param lang string
  ---@return string[]
  function(lang)
    vim.validate("lang", lang, "string")

    local injected = {}

    if
      not vim.list_contains(M.opts.custom.installed, lang)
      or not vim.treesitter.language.add(lang)
    then
      return injected
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

    return vim.tbl_keys(injected)
  end,
  function() return {} end
)

M.opts.custom.delete_ignored_langs = tie(
  "Plugin nvim-treesitter -> Delete ignored languages",
  function()
    local ts = require("nvim-treesitter")
    local custom = M.opts.custom
    local to_delete = {}

    tied.for_list(
      "Add treesitter language for deletion",
      custom.ignore,
      function(_, lang)
        if vim.list_contains(custom.installed, lang) then
          to_delete[lang] = true
        end
      end
    )

    to_delete = vim.tbl_keys(to_delete)

    if #to_delete > 0 then
      ts.uninstall(to_delete, { max_jobs = 8, summary = true })
        :await(function() custom.installed = ts.get_installed() end)
    end
  end,
  tied.do_nothing
)

M.opts.custom.install_langs = tie(
  "Plugin nvim-treesitter -> Install languages",
  ---@param ensure_installed string[]
  ---@return boolean
  function(ensure_installed)
    vim.validate("ensure_installed", ensure_installed, "table")

    local ts = require("nvim-treesitter")
    local ts_parsers = require("nvim-treesitter.parsers")
    local custom = M.opts.custom
    local queue = vim.deepcopy(ensure_installed)
    local to_install = {}

    while #queue > 0 do
      local lang = table.remove(queue, 1)

      if
        custom.available[lang]
        and not vim.list_contains(custom.installed, lang)
        and not vim.list_contains(custom.ignore, lang)
      then
        to_install[lang] = true

        tied.for_list(
          "Add all dependencies to queue",
          vim.tbl_get(ts_parsers, lang, "requires") or {},
          function(_, dep) table.insert(queue, dep) end
        )
      end
    end

    to_install = vim.tbl_keys(to_install)

    if #to_install == 0 then
      return false
    end

    ts.install(to_install, { max_jobs = 8, summary = true })
      :await(tie("Update things after installing treesitter langs", function()
        custom.installed = ts.get_installed()

        -- Reload to get access to new injections so you can install them
        package.loaded["vim.treesitter.query"] = nil
        vim.treesitter.query = require("vim.treesitter.query")

        local injected = {}

        tied.for_list(
          "Check installed lang for injections",
          to_install,
          function(_, lang)
            tied.for_list(
              "Add injected lang to queue",
              custom.get_injections(lang),
              function(_, inj) injected[inj] = true end
            )
          end
        )

        local has_installs = custom.install_langs(vim.tbl_keys(injected))

        -- Every other task is finished because of :await()
        -- and last call didn't install any new langs
        if not has_installs then
          vim.notify("[treesitter]: Finished installs")

          tied.for_list(
            "Start ts in all possible bufs",
            vim.api.nvim_list_bufs(),
            function(_, bufnr)
              local lang =
                vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)

              if lang then
                custom.start_ts_in_buf(lang, bufnr)
              end
            end
          )
        end
      end, tied.do_nothing))

    return true
  end,
  function() return false end
)

M.opts.custom.should_enable = tie(
  "Plugin nvim-treesitter -> Should enable query?",
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

M.opts.custom.start_ts_in_buf = tie(
  "Plugin nvim-treesitter -> Start in a buffer",
  ---@param lang string
  ---@param bufnr number
  function(lang, bufnr)
    vim.validate("lang", lang, "string")
    vim.validate("bufnr", bufnr, "number")

    if
      not vim.api.nvim_buf_is_loaded(bufnr)
      or not vim.treesitter.language.add(lang)
    then
      return
    end

    local should_enable = M.opts.custom.should_enable

    if should_enable(lang, "highlights") then
      pcall(vim.treesitter.start, bufnr)
    end

    if should_enable(lang, "indents") then
      vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    if should_enable(lang, "folds") then
      if bufnr == 0 then
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      else
        tied.for_list(
          "Set treesitter fold opts",
          vim.fn.win_findbuf(bufnr),
          function(_, winid)
            vim.wo[winid].foldmethod = "expr"
            vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        )
      end
    end
  end,
  tied.do_nothing
)

M.config = tie("Plugin nvim-treesitter -> config", function(opts)
  local ts = require("nvim-treesitter")
  local custom = opts.custom

  ts.setup(opts)

  for _, lang in ipairs(ts.get_available()) do
    custom.available[lang] = true
  end

  custom.installed = ts.get_installed()
  custom.delete_ignored_langs()
  custom.install_langs(vim.tbl_keys(custom.seen_langs))
end, tied.do_nothing)

M.init = tie("Plugin nvim-treesitter -> init", function()
  tied.create_autocmd({
    desc = "Setup treesitter for a buffer",
    group = tied.create_augroup("my.treesitter.setup", true),
    event = "FileType",
    callback = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match)
      local custom = M.opts.custom

      if not lang then
        return
      end

      if not custom.seen_langs[lang] then
        -- Used to both prevent needless fn calls
        -- and to install langs from before plugin load
        custom.seen_langs[lang] = true

        if tied.plugin_loaded("nvim-treesitter") then
          custom.install_langs({ lang })
        end
      end

      -- Set bufnr 0 so that only current window fold settings are changed
      custom.start_ts_in_buf(lang, 0)
    end,
  })
end, tied.do_nothing)

return M
