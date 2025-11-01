return {
  {
    -- Language parsing which provides better highlight, indentation, etc.
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = "User FilePost",
    cmd = { "TSUpdate", "TSInstall", "TSInstallFromGrammar", "TSLog", "TSUninstall" },
    -- :h nvim-treesitter.txt
    config = tie(
      "plugin nvim-treesitter -> config",
      function(_, opts)
        local ts = require("nvim-treesitter")

        -- Make sure we're on the "main" branch
        assert(ts.get_installed, "Please use `:Lazy` and update `nvim-treesitter`")

        ts.setup(opts)

        ---@type table<string,{ enable?: boolean, ignore?: string[] }>
        local config = {
          highlights = {},
          indents = {},
          folds = {},
        }
        local ignore = {
          "comment" -- interferes when todo-comments.nvim
        }

        -- NOTE: Can't install a parser only when a new filetype is opened,
        -- because some of the parsers are not filetype related
        local installed = ts.get_installed()
        local ensure_installed = {
          unpack(ts.get_available(1)), -- stable
          unpack(ts.get_available(2)), -- unstable
        }

        local to_delete = vim.iter(installed)
          :filter(function(parser) return vim.list_contains(ignore, parser) end)
          :totable()
        local to_install = vim.iter(ensure_installed)
          :filter(function(parser)
            return (
              not vim.list_contains(installed, parser) and
              not vim.list_contains(ignore, parser)
            )
          end)
          :totable()

        if #to_delete > 0 then ts.uninstall(to_delete, { summary = true }) end
        if #to_install > 0 then ts.install(to_install, { summary = true }) end

        tied.create_autocmd("FileType", {
          group = "start treesitter for a filetype",
          callback = function(ev)
            local ft = ev.match
            local lang = vim.treesitter.language.get_lang(ev.match)

            -- Update the list of installed parsers
            -- installed = ts.get_installed()

            if not lang or not vim.list_contains(installed, lang) then return end

            local should_enable = tie(
              "check if should enable treesitter feature for ft: " .. ft,
              ---@param query string
              function(query)
                vim.validate("query", query, "string")

                local c = config[query] or {}
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
    ),
    -- Most options are removed in the main branch
    opts = {},
  },
  {
    -- Add textobjects that depend on treesitter
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    -- TODO: config and enable nvim-treesitter-textobjects
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = false,
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    -- Automatically add closing tags for HTML, JSX, etc
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "User FilePost",
    opts = {},
  },
}
