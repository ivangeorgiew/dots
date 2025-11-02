-- Plugins which don't fit into any specific category
-- or are dependencies for other plugins

---@type LazyPluginSpec|LazyPluginSpec[]
return {
  -- Useful functions for other plugins
  { "nvim-lua/plenary.nvim" },

  -- https://github.com/nvim-tree/nvim-web-devicons?tab=readme-ov-file#setup
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      -- set the light or dark variant manually, instead of relying on `background`
      -- (default to nil)
      variant = "dark",

      -- globally enable default icons (default to false)
      -- will get overriden by `get_icons` option
      default = true,

      -- add/change icons
      override = {
        default_icon = { icon = "󰈚", name = "Default" },
        js = { icon = "󰌞", name = "js" },
        ts = { icon = "󰛦", name = "ts" },
        lock = { icon = "󰌾", name = "lock" },
        ["robots.txt"] = { icon = "󰚩", name = "robots" },
      },
    },
  },

  -- https://github.com/nvim-mini/mini.icons?tab=readme-ov-file#default-config
  { "nvim-mini/mini.icons", version = false },

  -- Restore cursor position
  -- https://github.com/ethanholz/nvim-lastplace
  { "ethanholz/nvim-lastplace", event = "BufReadPre", opts = {}, },
}
