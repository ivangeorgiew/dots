---@type LspConfig
local M = {
  lsp_name = "lua_ls",
  pkg_name = "lua-language-server",
  config = {
    settings = {
      -- https://luals.github.io/wiki/settings/
      Lua = {
        completion = {
          callSnippet = "Both",
          keywordSnippet = "Replace",
        },
        hint = {
          arrayIndex = "Disable",
          setType = true,
        },
        doc = {
          privateName = { "^_" },
        },
        diagnostics = {
          disable = {},
        },
      },
    },
  },
}

return M
