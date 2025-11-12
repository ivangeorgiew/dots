--- @type table<string,MyLazySpec>
local M = {
  retirement = {
    -- Auto-close unneeded buffers
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    -- :h nvim-early-retirement-nvim-early-retirement--configuration
    opts = { retirementAgeMins = 10, },
  },
  garbage_day = {
    -- Garbage collector that stops inactive LSP clients to free RAM
    "zeioth/garbage-day.nvim",
    event = "VeryLazy",
    -- :h garbage-day.nvim-available-options
    opts = {},
  }
}

return M
