return {
  -- :h lspconfig
  {
    "neovim/nvim-lspconfig",
    config = tie(
      "plugin nvim-lspconfig -> config",
      function()
        -- Recommended config from nvim-lspconfig
        vim.lsp.config('lua_ls', {
          settings = { Lua = {} },
          on_init = tie(
            "lsp lua_ls -> on_init",
            function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name

                if (
                  vim.uv.fs_stat(path .. "/.luarc.json") or
                  vim.uv.fs_stat(path .. "/.luarc.jsonc")
                ) then
                  return
                end
              end

              -- nvim related lua settings
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
                      -- TODO: vim.fn.stdpath("data").."/lazy/snacks.nvim",
                    }
                  },
                }
              )
            end,
            tied.do_nothing
          ),
        })
      end,
      tied.do_nothing
    ),
  },

  -- :h null-ls.txt
  {
    "nvimtools/none-ls.nvim",
  }
}
