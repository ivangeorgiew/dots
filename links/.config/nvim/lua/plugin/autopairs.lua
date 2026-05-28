-- TODO: alternative are blink.pairs or mini.pairs with LazyVim's additions

--- @type PluginSpec
local M = {
  -- Adds closing pairs (), "", etc
  src = "windwp/nvim-autopairs",
  lazy = true,
  -- :h nvim-autopairs-default-values
  opts = {},
}

return M
