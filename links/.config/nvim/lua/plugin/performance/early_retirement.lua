--- @type MyLazySpec
local M = {
  -- Auto-close unneeded buffers
  "chrisgrieser/nvim-early-retirement",
  event = "VeryLazy",
  -- :h nvim-early-retirement-nvim-early-retirement--configuration
  opts = { retirementAgeMins = 10 },
}

return M
