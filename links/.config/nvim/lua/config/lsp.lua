-- Configs that are setup in the nvim-lspconfig plugin

---@class LspConfig
---@field enable? boolean
---@field pkg_name? string
---@field config? vim.lsp.Config
---@field utils? table

---@type table<string,LspConfig>
local M = {}

M.lua_ls = {
  enable = true,
  pkg_name = "lua-language-server",
  utils = {
    libs_queue = {},
  },
  config = {
    settings = { Lua = {}, },
  },
}

M.lua_ls.utils.add_plugin = tie(
  "LSP lua_ls -> Add nvim plugin as library",
  function(plugin_name)
    tied.on_plugin_load(
      { "nvim-lspconfig", plugin_name },
      "Add nvim plugin as lua_ls library",
      function(plugins)
        local plugin_dir = plugins[plugin_name].dir

        if not vim.g.lua_ls_loaded then
          local queue = M.lua_ls.utils.libs_queue

          if not vim.list_contains(queue, plugin_dir) then
            table.insert(queue, plugin_dir)
          end
        else
          local client = vim.lsp.get_clients({ name = "lua_ls" })[1]

          if not client or not vim.g.is_nvim_project then return end

          ---@diagnostic disable-next-line: undefined-field
          local libs = client.config.settings.Lua.workspace.library

          if not vim.list_contains(libs, plugin_dir) then
            table.insert(libs, plugin_dir)
          end
        end
      end
    )
  end,
  tied.do_nothing
)

M.lua_ls.config.on_init = tie(
  "LSP lua_ls -> On init",
  function(client)
    vim.g.lua_ls_loaded = true

    if not client.workspace_folders then return end

    local path = client.workspace_folders[1].name

    vim.g.is_nvim_project = (
      not vim.uv.fs_stat(path .. "/.luarc.json") and
      not vim.uv.fs_stat(path .. "/.luarc.jsonc")
    )

    if not vim.g.is_nvim_project then return end

    client.config.settings.Lua = vim.tbl_deep_extend(
      "force",
      client.config.settings.Lua,
      {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua', },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luv/library", -- vim.uv
            vim.fn.stdpath("data").."/lazy/lazy.nvim",
            unpack(M.lua_ls.utils.libs_queue),
            -- TODO: vim.fn.stdpath("data").."/lazy/snacks.nvim",
          }
        },
      }
    )
  end,
  tied.do_nothing
)

return M
