--- @class MyLazySpec
local M = {
  -- Auto-close unneeded buffers
  "chrisgrieser/nvim-early-retirement",
  event = tied.LazyEvent,
  -- :h nvim-early-retirement-nvim-early-retirement--configuration
  opts = { retirementAgeMins = 10 },
}

return M
