-- Plugins which don't fit into any specific category
-- or are dependencies for other plugins

--- @type table<string,MyLazySpec>
local M = {
  plenary = {
    -- Useful functions for other plugins
    "nvim-lua/plenary.nvim"
  },
  devicons = {
    -- Pretty icons
    -- https://github.com/nvim-tree/nvim-web-devicons?tab=readme-ov-file#setup
    "nvim-tree/nvim-web-devicons"
  },
  mini_icons = {
    -- Pretty icons
    -- https://github.com/nvim-mini/mini.icons?tab=readme-ov-file#default-config
    "nvim-mini/mini.icons",
    version = false
  },
  lastplace = {
    -- Restore cursor position
    -- https://github.com/ethanholz/nvim-lastplace
    "ethanholz/nvim-lastplace",
    event = "BufReadPre",
    opts = {},
  },
}

M.devicons.opts = {
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
}

return M
