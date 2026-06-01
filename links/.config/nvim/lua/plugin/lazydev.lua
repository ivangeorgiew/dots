-- TODO: fix errors lsp errors in log: "semantic_tokens" { code = -32801, message = "Content modified." }

--- @type PluginSpec
local M = {
  src = "ivangeorgiew/lazydev.nvim",
  lazy = true,
  ---@module "lazydev"
  ---@type lazydev.Config
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
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
