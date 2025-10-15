-- TODO: fix the issue when doing `:cfdo search and replace` command causing LSP errors

return {
  -- TODO: "neovim/nvim-lspconfig",
  -- TODO: "nvimtools/none-ls.nvim",

  -- Configures LuaLS to support auto-completion and type checking
  -- while editing your Neovim configuration.
  -- https://github.com/folke/lazydev.nvim
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
        -- { path = "snacks.nvim", words = { "Snacks" } },
        -- { path = "LazyVim", words = { "LazyVim" } },
      },
    },
  },
}
