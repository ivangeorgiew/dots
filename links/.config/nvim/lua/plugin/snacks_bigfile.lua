---@module "snacks"
---@type plugin_spec
local M = {
  src = "ivangeorgiew/snacks.nvim",
  submodule = true,
  opts = {},
}

---@class snacks.bigfile.Config
M.opts.bigfile = {
  enabled = true,
  notify = true,
  size = 1024 * 1024 * 1.5,
  line_length = 1000,
}

return M
