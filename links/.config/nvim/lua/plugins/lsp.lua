return {
  -- Configures lua_ls for neovim plugin development
  -- https://github.com/folke/lazydev.nvim
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    -- TODO: setup config for nvim-cmp and blink.cmp when added
    opts = {
      enabled = tie(
        "plugin lazydev -> opts.enabled",
        function(root_dir)
          local enabled = true

          enabled = enabled and not vim.uv.fs_stat(root_dir .. "/.luarc.json")
          enabled = enabled and not vim.uv.fs_stat(root_dir .. "/.luarc.jsonc")

          return enabled
        end,
        function() return false end
      ),
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        -- { path = "LazyVim", words = { "LazyVim" } },
      },
    },
  },

  -- TODO: configure "neovim/nvim-lspconfig",
  {
    "neovim/nvim-lspconfig",
    dependencies = { "folke/lazydev.nvim" },
  },

  -- TODO: configure "nvimtools/none-ls.nvim",
  {
    "nvimtools/none-ls.nvim",
  }
}
