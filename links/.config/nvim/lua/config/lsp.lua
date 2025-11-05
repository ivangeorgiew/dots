-- Configs that are setup in the nvim-lspconfig plugin

---@class LspConfig
---@field enable? boolean
---@field pkg_name? string
---@field config? vim.lsp.Config

---@type table<string,LspConfig>
return {
  -- Recommended config from nvim-lspconfig
  ["lua_ls"] = {
    enable = true,
    pkg_name = "lua-language-server",
    config = {
      settings = { Lua = {
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
            -- TODO: vim.fn.stdpath("data").."/lazy/snacks.nvim",
          }
        },
      }, },
      on_init = tie(
        "LSP lua_ls -> on_init",
        function(client)
          vim.validate("client", client, "table")

          if client.workspace_folders then
            local path = client.workspace_folders[1].name

            if
              vim.uv.fs_stat(path .. "/.luarc.json") or
              vim.uv.fs_stat(path .. "/.luarc.jsonc")
            then
              client.config.settings.Lua = {}
            end
          end
        end,
        tied.do_nothing
      ),
    },
  },
}
