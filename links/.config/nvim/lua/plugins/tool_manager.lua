-- Some of the configs are only to describe dependencies order
-- Other configs like nvim-lspconfig and nvim-dap are in other files
return {
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
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "nvimtools/none-ls.nvim",
    }
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",

      "neovim/nvim-lspconfig",
      "mason-org/mason-lspconfig.nvim",

      "mfussenegger/nvim-dap",
      "jay-babu/mason-nvim-dap.nvim",

      "nvimtools/none-ls.nvim",
      "jay-babu/mason-null-ls.nvim",
    },
    event = "VeryLazy",
    -- order matters and this is the cleanest working setup
    config = tie(
      "plugin mason -> config",
      function()
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
    ),
  }
}
