-- Mainly dependencies for other plugins
-- or plugins which don't fit into any specific category.

return {
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-tree/nvim-web-devicons",
    -- https://github.com/nvim-tree/nvim-web-devicons?tab=readme-ov-file#setup
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
}
