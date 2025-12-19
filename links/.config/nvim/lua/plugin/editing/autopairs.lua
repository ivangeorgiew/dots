-- TODO: alternative are blink.pairs or mini.pairs with LazyVim's additions

--- @type LazyPluginSpec
local M = {
  -- Adds closing pairs (), "", etc
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  -- :h nvim-autopairs-default-values
  opts = {},
}

return M
