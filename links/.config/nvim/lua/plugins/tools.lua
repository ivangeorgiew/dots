---@type LazyPluginSpec|LazyPluginSpec[]
return {
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    -- :h lspconfig
    config = tie(
      "plugin nvim-lspconfig -> config",
      function()
        tied.each(require("config.lsp"), "setup an LSP", function(name, lsp)
          if lsp.config then vim.lsp.config(name, lsp.config) end
          if lsp.enable ~= false then vim.lsp.enable(name) end
        end)
      end,
      tied.do_nothing
    ),
  },

  -- TODO: configure none-ls
  { "nvimtools/none-ls.nvim" },

  -- TODO: configure nvim-dap
  { "mfussenegger/nvim-dap" },

  {
    "mason-org/mason.nvim",
    event = "VeryLazy", -- always needed to provide binaries
    build = ":MasonUpdate",
    config = tie(
      "plugin mason -> config",
      function(_, opts)
        require("mason").setup(opts)

        local mr = require("mason-registry")

        tied.each_i(
          {
            "package:install:success",
            "package:install:failed",
            "package:uninstall:success",
            "package:uninstall:failed",
          },
          "notify about mason event status",
          function(_, event)
            mr:on(event, vim.schedule_wrap(function(payload)
              local action, status = event:match(":(.+):(.+)$")

              action = action:sub(1,1):upper() .. action:sub(2)

              vim.notify(("[mason]: %s `%s` %s"):format(action, payload.name, status))
            end))
          end
        )

        -- Try to load the newly installed package
        mr:on("package:install:success", vim.schedule_wrap(function()
          vim.api.nvim_exec_autocmds(
            "FileType",
            { buffer = vim.api.nvim_get_current_buf() }
          )
        end))

        mr.refresh(tie(
          "manage mason packages",
          function()
            local installed = mr.get_installed_package_names()
            local to_install = {}

            tied.each(require("config.lsp"), "queue LSP for mason install", function(_, lsp)
              if lsp.enable ~= false and lsp.pkg_name then
                to_install[#to_install + 1] = lsp.pkg_name
              end
            end)

            -- TODO: Add DAP tools
            -- TODO: Add null-ls tools

            tied.each_i(installed, "auto-remove mason tool", function(_, tool)
              if not vim.list_contains(to_install, tool) then
                local name = tool:match("^([^@]+)")

                mr.get_package(name):uninstall()
              end
            end)

            tied.each_i(to_install, "auto-install mason tool", function(_, tool)
              -- Intentionally fail if tool is missing to notify about it
              if not vim.list_contains(installed, tool) then
                local name = tool:match("^([^@]+)")
                local version = tool:match("^[^@]+@(.+)$")

                mr.get_package(name):install({ version = version })
              end
            end)
          end,
          tied.do_nothing
         ))
      end,
      tied.do_nothing
    ),
    opts = {
      -- default "prepend"
      ---@type '"prepend"' | '"append"' | '"skip"'
      PATH = "prepend",

      ui = {
        border = "single", -- same as nvim_open_win()
        width = 0.6, -- 0-1 for a percentage of screen width.
        height = 0.8, -- 0-1 for a percentage of screen height.
      },
    },
  },
}
