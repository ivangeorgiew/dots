--- @class MyLazySpec
local M = {
  -- Restore cursor position
  -- https://github.com/ethanholz/nvim-lastplace
  "ethanholz/nvim-lastplace",
  event = "BufReadPre",
  opts = {},
}

return M
