local configs = {}

configs["nvim-lspconfig"] = tie(
  "plugin nvim-lspconfig -> config",
  function()
    -- Recommended config from nvim-lspconfig
    vim.lsp.config('lua_ls', {
      settings = { Lua = {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua', },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luv/library", -- vim.uv
            vim.fn.stdpath("data").."/lazy/lazy.nvim",
            -- TODO: vim.fn.stdpath("data").."/lazy/snacks.nvim",
          }
        },
      } },
      on_init = tie(
        "lsp lua_ls -> on_init",
        function(client)
          vim.validate("client", client, "table")

          if client.workspace_folders then
            local path = client.workspace_folders[1].name

            if (
              vim.uv.fs_stat(path .. "/.luarc.json") or
              vim.uv.fs_stat(path .. "/.luarc.jsonc")
            ) then
              client.config.settings.Lua = {}
            end
          end
        end,
        tied.do_nothing
      ),
    })
  end,
  tied.do_nothing
)

configs["mason-tool-installer"] = tie(
  "plugin mason -> config",
  function()
    -- Order matters and this is the cleanest working setup

    -- :h mason-settings
    require("mason").setup({
      ---@type '"prepend"' | '"append"' | '"skip"'
      -- default: "prepend"
      -- PATH = "prepend", -- use `append` to search mason dir only after others

      ui = {
        border = "single", -- same as nvim_open_win()
        width = 0.6, -- 0-1 for a percentage of screen width.
        height = 0.8, -- 0-1 for a percentage of screen height.
      },
    })

    -- :h mason-lspconfig-settings
    require("mason-lspconfig").setup({
      -- Don't specify ensure_installed here
      -- Whether to call vim.lsp.enable on all installed LSPs
      automatic_enable = true
    })

    -- :h mason-nvim-dap.nvim-configuration
    require("mason-nvim-dap").setup({
      -- Don't specify ensure_installed here
      -- Whether to auto-install DAPs configured in nvim-dap
      automatic_installation = false
    })

    -- :h mason-null-ls.nvim-configuration
    require("mason-null-ls").setup({
      -- Don't specify ensure_installed here
      -- Whether to auto-install tools configured in null-ls
      automatic_installation = false
    })

    local mti = require("mason-tool-installer")

    mti.setup({
      -- List of LSP, DAP, Formatters and Linters to install
      -- check available ones with :Mason or https://mason-registry.dev/registry/list
      ensure_installed = {
        "lua-language-server",
      },
      auto_update = false, -- whether to auto-update tools
      run_on_start = false, -- instead use .check_install(false)
    })

    mti.clean() -- remove packages not declared in ensure_installed
    mti.check_install(false) -- install without updating
  end,
  tied.do_nothing
)

-- Specify dependencies
return {
  {
    "neovim/nvim-lspconfig",
    -- :h lspconfig
    config = configs["nvim-lspconfig"],
  },

  -- TODO: configure none-ls
  { "nvimtools/none-ls.nvim" },

  -- TODO: configure nvim-dap
  { "mfussenegger/nvim-dap" },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    }
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
    }
  },
  {
    "adrian-the-git/mason-null-ls.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "nvimtools/none-ls.nvim",
    }
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "adrian-the-git/mason-null-ls.nvim",
    },
    event = "VeryLazy",
    config = configs["mason-tool-installer"],
  }
}
