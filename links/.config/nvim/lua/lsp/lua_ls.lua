---@class LspConfig
local M = {
  lsp_name = "lua_ls",
  pkg_name = "lua-language-server",
  extra = {
    plugin_libs = {},
    nvim_settings = {
      runtime = {
        version = "LuaJIT",
        pathStrict = true,
        path = { "?.lua", "?/init.lua" },
      },
      workspace = {
        checkThirdParty = false,
        ignoreDir = { "/lua" },
        library = {
          vim.env.VIMRUNTIME .. "/lua",
          vim.fn.stdpath("config") .. "/lua",
          "${3rd}/luv/library", -- vim.uv
          vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua",
        },
      },
    },
  },
  config = {
    settings = {
      -- https://github.com/LuaLS/lua-language-server/wiki/Settings
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

M.extra.check_if_nvim = tie(
  "Check if nvim project",
  ---@param client vim.lsp.Client
  function(client)
    vim.validate("client", client, "table")

    if not client.workspace_folders then
      return false
    end

    local path = client.workspace_folders[1].name

    return (
      not vim.uv.fs_stat(path .. "/.luarc.json")
      and not vim.uv.fs_stat(path .. "/.luarc.jsonc")
    )
  end,
  function() return false end
)

M.extra.add_library = tie(
  "LSP lua_ls -> Add nvim plugin as library",
  --- @param plugin_name string
  vim.schedule_wrap(function(plugin_name)
    vim.validate("plugin_name", plugin_name, "string")

    local lazy_plugins = require("lazy.core.config").plugins

    if lazy_plugins[plugin_name] then
      local plugin_dir = lazy_plugins[plugin_name].dir .. "/lua"

      if not vim.list_contains(M.extra.plugin_libs, plugin_dir) then
        table.insert(M.extra.plugin_libs, plugin_dir)
      end
    end
  end),
  tied.do_nothing
)

M.config.on_init = tie("LSP lua_ls -> On init", function(client)
  if not M.extra.check_if_nvim(client) then
    return
  end

  local s = client.config.settings

  s.Lua = vim.tbl_deep_extend("force", s.Lua, M.extra.nvim_settings)
end, tied.do_nothing)

M.config.on_attach = tie("LSP lua_ls -> On attach", function(client, bufnr)
  require("lsp.defaults").config.on_attach(client, bufnr)

  if not M.extra.check_if_nvim(client) then
    return
  end

  local libs = client.config.settings.Lua.workspace.library
  local to_add = {}

  tied.each_i(
    "Add unique plugin lua_ls libs",
    M.extra.plugin_libs,
    function(_, lib)
      if not vim.list_contains(libs, lib) then
        to_add[#to_add + 1] = lib
      end
    end
  )

  if #to_add > 0 then
    vim.list_extend(libs, to_add)
  end

  -- Not needed here, but keep as reference
  -- client:notify("workspace/didChangeConfiguration", {
  --   settings = { Lua = { workspace = { library = {} } } },
  -- })
end, tied.do_nothing)

return M
