--- @type MyLazySpec
local M = {
  "ivangeorgiew/lazydev.nvim",
  event = tied.LazyEvent,
  ---@module "lazydev"
  ---@type lazydev.Config
  opts = {
    library = {
      vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy/types.lua",
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim", words = { "Snacks" } },
    },
    enabled = tie(
      "Plugin lazydev -> opts.enabled",
      function(path)
        return (
          vim.g.lazydev_enabled ~= false
          and not vim.uv.fs_stat(path .. "/.luarc.json")
          and not vim.uv.fs_stat(path .. "/.luarc.jsonc")
        )
      end,
      function() return false end
    ),
  },
}

return M
