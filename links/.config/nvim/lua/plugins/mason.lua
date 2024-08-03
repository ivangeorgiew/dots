-- Search for packages: https://mason-registry.dev/registry/list

-- TODO: integrate mason dependencies in nvim-lspconfig, nvim-dap, none-ls

local ensure_installed = {
  -- you can pin a tool to a particular version
  -- { 'golangci-lint', version = 'v1.47.0' },

  -- you can turn off/on auto_update per tool
  -- { 'bash-language-server', auto_update = true },

  "lua-language-server",
}

return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "jay-babu/mason-nvim-dap.nvim",
    "mfussenegger/nvim-dap",
    "jay-babu/mason-null-ls.nvim",
    "nvimtools/none-ls.nvim",
  },
  event = "VeryLazy",
  config = tie(
    "configure mason",
    {},
    function()
      require("mason").setup({
        -- The directory in which to install packages.
        -- install_root_dir = vim.fn.stdpath("data") .. "/mason",

        -- Where Mason should put its bin location in your PATH.
        ---@type '"prepend"' | '"append"' | '"skip"'
        PATH = "skip",

        -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
        -- debugging issues with package installations.
        -- log_level = vim.log.levels.INFO,

        -- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
        -- packages that are requested to be installed will be put in a queue.
        -- max_concurrent_installers = 4,

        -- [Advanced setting]
        -- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
        -- multiple registries, the registry listed first will be used.
        -- registries = {
        --   "github:mason-org/mason-registry",
        -- },

        -- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
        -- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
        -- Builtin providers are:
        --   - mason.providers.registry-api  - uses the https://api.mason-registry.dev API
        --   - mason.providers.client        - uses only client-side tooling to resolve metadata
        -- providers = {
        --   "mason.providers.registry-api",
        --   "mason.providers.client",
        -- },

        -- github = { ... },

        -- pip = { ... },

        ui = {
          -- Whether to automatically check for new versions when opening the :Mason window.
          -- check_outdated_packages_on_open = true,

          -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
          border = "single",

          -- Float in the range of 0-1 for a percentage of screen width.
          width = 0.6,

          -- Float in the range of 0-1 for a percentage of screen height.
          height = 0.8,

          -- icons = { ... },

          -- keymaps = { ... },
        },
      })

      require("mason-lspconfig").setup({
        -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
        -- This setting has no relation with the `ensure_installed` setting.
        -- Can either be:
        --   - false: Servers are not automatically installed.
        --   - true: All servers set up via lspconfig are automatically installed.
        --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
        --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
        ---@type boolean
        -- automatic_installation = false,

        -- See `:h mason-lspconfig.setup_handlers()`
        ---@type table<string, fun(server_name: string)>?
        -- handlers = nil
      })

      require("mason-nvim-dap").setup({
        -- automatic_installation = false,

        -- https://github.com/jay-babu/mason-nvim-dap.nvim/tree/main?tab=readme-ov-file#handlers-usage-automatic-setup
        -- handlers = nil
      })

      require("mason-null-ls").setup({
        -- Enable or disable null-ls methods to get set up
        -- This setting is useful if some functionality is handled by other plugins such as `conform` and `nvim-lint`
        methods = {
          diagnostics = true,
          formatting = true,
          code_actions = true,
          completion = true,
          hover = true,
        },

        -- automatic_installation = true,

        -- https://github.com/jay-babu/mason-null-ls.nvim?tab=readme-ov-file#handlers-usage
        -- handlers = nil,
      })

      local mason_tool_installer = require("mason-tool-installer")

      mason_tool_installer.setup({
        ensure_installed = ensure_installed,

        auto_update = false,

        -- if enabled, runs on VimEnter event
        -- instead .check_install(false) is used below
        run_on_start = false,

        -- If you turn on an integration and you have the required module(s)
        -- installed this means you can use alternative names, supplied by
        -- the modules, for the thing that you want to install.
        -- integrations = {
        --   ['mason-lspconfig'] = true,
        --   ['mason-null-ls'] = true,
        --   ['mason-nvim-dap'] = true,
        -- },
      })

      mason_tool_installer.clean() -- remove packages not declared in ensure_installed
      mason_tool_installer.check_install(false) -- install without updating
    end
  ),
}
