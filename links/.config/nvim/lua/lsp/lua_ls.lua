---@type LspConfig
local M = {
  lsp_name = "lua_ls",
  pkg_name = "lua-language-server",
  extra = {
    lsp_did_init = false,
    libs_queue = {},
    nvim_settings = {
      runtime = {
        version = "LuaJIT",
        pathStrict = true,
        path = { "lua/?.lua", "lua/?/init.lua" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library", -- vim.uv
          vim.fn.stdpath("data") .. "/lazy/lazy.nvim",
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
          keywordSnippet = "Replace", -- TODO: maybe "Disable"
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

    if not lazy_plugins[plugin_name] then
      return
    end

    local plugin_dir = lazy_plugins[plugin_name].dir

    if not M.extra.lsp_did_init then
      local queue = M.extra.libs_queue

      if not vim.list_contains(queue, plugin_dir) then
        table.insert(queue, plugin_dir)
      end
    else
      tied.each_i(
        "Add plugin as lua_ls library to loaded clients",
        vim.lsp.get_clients({ name = "lua_ls" }),
        function(_, client)
          if not client or not M.extra.check_if_nvim(client) then
            return
          end

          ---@diagnostic disable-next-line: undefined-field
          local libs = client.config.settings.Lua.workspace.library

          if not vim.list_contains(libs, plugin_dir) then
            table.insert(libs, plugin_dir)

            client:notify("workspace/didChangeConfiguration", {
              settings = { Lua = {} },
            })
          end
        end
      )
    end
  end),
  tied.do_nothing
)

M.config.on_init = tie("LSP lua_ls -> On init", function(client)
  M.extra.lsp_did_init = true

  if M.extra.check_if_nvim(client) then
    local s = client.config.settings

    s.Lua = vim.tbl_deep_extend("force", s.Lua, M.extra.nvim_settings)

    vim.list_extend(s.Lua.workspace.library, M.extra.libs_queue)
  end
end, tied.do_nothing)

return M
