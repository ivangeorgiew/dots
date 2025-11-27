---@class MyLazySpec
local M = {
  -- Pretty icons
  -- https://github.com/nvim-tree/nvim-web-devicons?tab=readme-ov-file#setup
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
}

return M
