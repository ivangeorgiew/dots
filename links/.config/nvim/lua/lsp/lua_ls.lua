---@type lsp_config
local M = {
  name = "lua_ls",
  features = {
    codelens = false,
    semantic_tokens = false,
    document_color = false,
    inline_completion = false,
    linked_editing_range = false,
    on_type_formatting = false,
  },
  config = {
    settings = {
      -- https://luals.github.io/wiki/settings/
      Lua = {
        format = {
          enable = false, -- use stylua instead
        },
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

M.config.on_init = tie(
  "LSP lua_ls -> on_init",
  ---@param client vim.lsp.Client
  function(client, _)
    -- NOTE: Manual setup of `---@module` without `lazydev` plugin
    -- Prefer lazydev, because of require() and @module being added on buf change
    local cwd = vim.tbl_get(client, "workspace_folders", 1, "name")

    if
      tied.plugins["lazydev"]
      or not cwd
      or vim.uv.fs_stat(cwd .. "/.luarc.json")
      or vim.uv.fs_stat(cwd .. "/.luarc.jsonc")
    then
      return
    end

    local file_paths = tied.dir({
      path = cwd,
      type = "file",
      ext = ".lua",
      map = function(file_name) return vim.fs.joinpath(cwd, file_name) end,
    })
    local module_regex = "%-%-%-%s*@module%s*[\"']([%w%.%-_/]*)[\"']"
    local modules = {}

    tied.for_list(
      "Find @module comment in a file",
      file_paths,
      function(_, file_path)
        for line in io.lines(file_path) do
          local module = line:match(module_regex)

          if module then
            modules[module] = true

            -- NOTE: assume only one module per file for perf
            return
          end
        end
      end
    )

    local settings = client.config.settings or {}
    local library = {
      vim.env.VIMRUNTIME .. "/lua",
      client.root_dir .. "/lua",
      "${3rd}/luv/library",
    }

    tied.for_list(
      "Add modules to lua_ls library",
      vim.tbl_keys(modules),
      function(_, name)
        local ok, opts = pcall(vim.pack.get, { name }, { info = false })

        if not ok or not opts[1] then
          return
        end

        local plugin_path = vim.fs.normalize(opts[1].path)

        if vim.uv.fs_stat(plugin_path .. "/lua") then
          plugin_path = plugin_path .. "/lua"
        end

        table.insert(library, plugin_path)
      end
    )

    -- Settings gotten from lazydev.nvim
    settings.Lua = vim.tbl_deep_extend("force", settings.Lua --[[@as table]], {
      runtime = {
        path = { "?.lua", "?/init.lua" },
        pathStrict = true,
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        ignoreDir = { "/lua" },
        library = library,
      },
    })
  end,
  tied.do_nothing
)

return M
