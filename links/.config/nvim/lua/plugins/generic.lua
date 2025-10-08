-- Plugins which don't fit into any specific category
-- or are dependencies for other plugins

return {
  -- Useful functions for other plugins
  { "nvim-lua/plenary.nvim" },

  -- https://github.com/nvim-tree/nvim-web-devicons?tab=readme-ov-file#setup
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      -- set the light or dark variant manually, instead of relying on `background`
      -- (default to nil)
      variant = "dark";
      -- globally enable default icons (default to false)
      -- will get overriden by `get_icons` option
      default = true;
    },
  },

  -- https://github.com/nvim-mini/mini.icons?tab=readme-ov-file#default-config
  { "nvim-mini/mini.icons", version = false },

  -- Restore cursor position
  -- https://github.com/ethanholz/vim-lastplace
  { "ethanholz/nvim-lastplace", event = "BufReadPre", opts = {}, },
}
