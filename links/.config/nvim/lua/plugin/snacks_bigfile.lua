---@module "snacks"
---@type LazyPluginSpec
local M = { "snacks.nvim", opts = { styles = {} } }

---@class snacks.bigfile.Config
M.opts.bigfile = {
  enabled = true,
  notify = true,
  size = 1024 * 1024 * 1.5,
  line_length = 1000,
}

return M
