-- TODO: config and enable nvim-treesitter-textobjects

--- @class MyLazySpec
local M = {
  -- Add textobjects that depend on treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
  "nvim-treesitter/nvim-treesitter-textobjects",
  enabled = false,
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
}

return M
