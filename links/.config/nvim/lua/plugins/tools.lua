--- @type table<string,MyLazySpec>
local M = {
  nvim_lspconfig = {
    -- Provides good default LSP configs
    "neovim/nvim-lspconfig",
    event = "User FilePost",
  },

  -- TODO: configure none-ls
  none_ls = { "nvimtools/none-ls.nvim" },

  -- TODO: configure nvim-dap
  nvim_dap = { "mfussenegger/nvim-dap" },

  mason = {
    --- External tools installer
    "mason-org/mason.nvim",
    event = "VeryLazy", -- always needed to provide binaries
    build = ":MasonUpdate",
  },

  treesitter = {
    -- Language parsing which provides better highlight, indentation, etc.
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = "User FilePost",
    cmd = { "TSUpdate", "TSInstall", "TSInstallFromGrammar", "TSLog", "TSUninstall" },
  },
}

-- :h lspconfig
M.nvim_lspconfig.config = tie(
  "Plugin nvim-lspconfig -> config",
  function()
    tied.each_i(require("lsp"), "Setup an LSP", function(_, lsp)
      if lsp.config then vim.lsp.config(lsp.lsp_name, lsp.config) end
      if lsp.enable ~= false then vim.lsp.enable(lsp.lsp_name) end
    end)

    -- Example inlay hints configs:
    -- https://github.com/MysticalDevil/inlay-hints.nvim/tree/master
    vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })
    -- vim.lsp.inlay_hint.enable()
  end,
  tied.do_nothing
)

M.mason.opts = {
  ui = {
    border = "single", -- same as nvim_open_win()
    width = 0.6, -- 0-1 for a percentage of screen width.
    height = 0.8, -- 0-1 for a percentage of screen height.
  },
}

M.mason.config = tie(
  "Plugin mason -> config",
  function(_, opts)
    require("mason").setup(opts)

    local mr = require("mason-registry")
    local install_tools = tie(
      "Install tools with mason",
      function(gather_tools)
        local installed = mr.get_installed_package_names()
        local to_install = {}

        -- No need to tie, let it fail
        gather_tools(to_install)

        tied.each_i(to_install, "Auto-install a mason tool", function(_, tool)
          if not vim.list_contains(installed, tool) then
            vim.cmd("MasonInstall " .. tool)
          end
        end)
      end,
      tied.do_nothing
    )

    install_tools(function(to_install)
      tied.each_i(require("lsp"), "Queue LSP for mason install", function(_, lsp)
        if lsp.enable ~= false and lsp.pkg_name then
          to_install[#to_install + 1] = lsp.pkg_name
        end
      end)
    end)

    tied.on_plugin_load(
      { "conform.nvim" },
      "Install code formatters from conform.nvim",
      function(plugins)
        install_tools(function(to_install)
          tied.each(
            plugins["conform.nvim"].opts.formatters_by_ft,
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
        end)
      end
    )

    -- TODO: Add DAP tools
    -- TODO: Add null-ls tools
  end,
  tied.do_nothing
)

-- :h nvim-treesitter.txt
---@type table<string,{ enable?: boolean, ignore?: string[] }>
M.treesitter.extra_opts = {
  highlights = {},
  indents = {
    ignore = { "lua", },
  },
  folds = {},
  ignore = {
    "comment", -- interferes when todo-comments.nvim
  },
}

M.treesitter.config = tie(
  "Plugin nvim-treesitter -> config",
  function(_, opts)
    local ts = require("nvim-treesitter")

    -- Make sure we're on the "main" branch
    assert(ts.get_installed, "Please use `:Lazy` and update `nvim-treesitter`")

    ts.setup(opts)

    local extra_opts = M.treesitter.extra_opts or {}

    -- NOTE: Can't install a parser only when a new filetype is opened,
    -- because some of the parsers are not filetype related
    local installed = ts.get_installed()
    local ensure_installed = {
      unpack(ts.get_available(1)), -- stable
      unpack(ts.get_available(2)), -- unstable
    }

    local to_install, to_delete = {}, {}

    tied.each_i(
      installed,
      "Add treesitter parser for deletion",
      function(_, parser)
        if vim.list_contains(extra_opts.ignore, parser) then
          to_delete[#to_delete + 1] = parser
        end
      end
    )

    tied.each_i(
      ensure_installed,
      "Add treesitter parser for installation",
      function(_, parser)
        if
          not vim.list_contains(installed, parser) and
          not vim.list_contains(extra_opts.ignore, parser)
        then
          to_install[#to_install + 1] = parser
        end
      end
    )

    if #to_delete > 0 then ts.uninstall(to_delete, { summary = true }) end
    if #to_install > 0 then ts.install(to_install, { summary = true }) end

    tied.create_autocmd({
      desc = "Setup treesitter for a filetype",
      group = tied.create_augroup("my.treesitter.on_filetype", true),
      event = "FileType",
      callback = function(ev)
        local ft = ev.match
        local lang = vim.treesitter.language.get_lang(ev.match)

        -- Update the list of installed parsers
        -- installed = ts.get_installed()

        if not lang or not vim.list_contains(installed, lang) then return end

        local should_enable = tie(
          "Check if should enable treesitter feature for ft: " .. ft,
          ---@param query string
          function(query)
            vim.validate("query", query, "string")

            local c = extra_opts[query] or {}
            local query_enabled = c.enable ~= false
            local lang_not_ignored = not vim.list_contains(c.ignore or {}, lang)
            local lang_supports_query = vim.treesitter.query.get(lang, query) ~= nil

            return query_enabled and lang_not_ignored and lang_supports_query
          end,
          function() return false end
        )

        if should_enable("highlights") then
          pcall(vim.treesitter.start, ev.buf)
          -- vim.notify("Setup highlighting for: "..lang)
        else
          pcall(vim.treesitter.stop, ev.buf)
        end

        if should_enable("indents") then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          -- vim.notify("Setup indenting for: "..lang)
        end

        if should_enable("folds") then
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          -- vim.notify("Setup folding for: "..lang)
        end
      end
    })
  end,
  tied.do_nothing
)

return M
