---@type LspConfig
local M = {
  lsp_name = "lua_ls",
  pkg_name = "lua-language-server",
  extra = {
    libs_queue = {},
    nvim_settings = {
      runtime = {
        version = "LuaJIT",
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
      Lua = {},
    },
  },
}

M.extra.add_library = tie(
  "LSP lua_ls -> Add nvim plugin as library",
  function(plugin_name)
    tied.on_plugin_load(
      { "nvim-lspconfig", plugin_name },
      "Add nvim plugin as lua_ls library",
      function(plugins)
        local plugin_dir = plugins[plugin_name].dir

        if not vim.g.lua_ls_loaded then
          local queue = M.extra.libs_queue

          if not vim.list_contains(queue, plugin_dir) then
            table.insert(queue, plugin_dir)
          end
        else
          tied.each_i(
            vim.lsp.get_clients({ name = "lua_ls" }),
            "Add plugin as lua_ls library to loaded clients",
            function(_, client)
              if not client or not vim.g.is_nvim_project then
                return
              end

              ---@diagnostic disable-next-line: undefined-field
              local libs = client.config.settings.Lua.workspace.library

              if not vim.list_contains(libs, plugin_dir) then
                table.insert(libs, plugin_dir)
              end
            end
          )
        end
      end
    )
  end,
  tied.do_nothing
)

M.config.on_init = tie("LSP lua_ls -> On init", function(client)
  vim.g.lua_ls_loaded = true

  if not client.workspace_folders then
    return
  end

  local path = client.workspace_folders[1].name

  vim.g.is_nvim_project = (
    not vim.uv.fs_stat(path .. "/.luarc.json")
    and not vim.uv.fs_stat(path .. "/.luarc.jsonc")
  )

  if vim.g.is_nvim_project then
    local s = client.config.settings

    s.Lua = vim.tbl_deep_extend("force", s.Lua, M.extra.nvim_settings)

    vim.list_extend(s.Lua.workspace.library, M.extra.libs_queue)
  end
end, tied.do_nothing)

return M
