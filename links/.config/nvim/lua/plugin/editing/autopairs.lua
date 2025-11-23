-- TODO: alternative is mini.pairs with LazyVim's additions

--- @type MyLazySpec
local M = {
  -- Adds closing pairs (), "", etc
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  -- :h nvim-autopairs-default-values
  opts = {},
}

return M
