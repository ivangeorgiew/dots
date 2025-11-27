-- TODO: alternative are blink.pairs or mini.pairs with LazyVim's additions

--- @class MyLazySpec
local M = {
  -- Adds closing pairs (), "", etc
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  -- :h nvim-autopairs-default-values
  opts = {},
}

return M
