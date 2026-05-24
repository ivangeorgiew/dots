-- NOTE:
-- vim.pack guide from creator: https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
-- Inspired from: https://github.com/kite12580/pack.lua/blob/main/README.md
-- Another plugin manager with vim.pack: https://github.com/zuqini/zpack.nvim

local M = {
  ---@type table<string,PluginSpecParsed>
  plugins = {},
  local_plugins_dir = "~/projects",
  input_props = {
    name = "string",
    main = "string",
    version = "string",
    branch = "string", -- not in output
    tag = "string", -- not in output
    commit = "string", -- not in output
    dependencies = "table",
    enabled = "boolean",
    lazy = "boolean",
    dev = "boolean",
    opts = "table",
    init = "function",
    config = "function",
    build = { "string", "function" },
    event = { "string", "table" },
    cmd = { "string", "table" },
  },
}

M.create_base_spec = tie(
  "Create base plugin spec",
  ---@param src string
  ---@return PluginSpecParsed
  function(src)
    vim.validate("src", src, "string")

    local spec = {}

    -- stylua: ignore
    spec.src = vim.startswith("https://", src) and src or ("https://github.com/" .. src)
    spec.name = spec.src:match("([^/]+)$")
    spec.main = spec.name:gsub("%.nvim$", "")

    return spec
  end,
  tied.do_rethrow
)

M.add_plugin_specs = tie(
  "Add plugin specs from files",
  ---@param raw_data table
  function(raw_data)
    vim.validate("raw_data", raw_data, "table")

    local queue = { raw_data }
    local raw_plugins = {}

    while #queue > 0 do
      local curr_data = table.remove(queue, 1)

      if type(curr_data) == "table" then
        if type(curr_data[1]) == "table" then
          tied.for_list(
            "Add raw plugin info to queue",
            curr_data,
            function(_, inner_data) queue[#queue + 1] = inner_data end
          )
        else
          table.insert(raw_plugins, curr_data)
        end
      end
    end

    tied.for_list("Parse plugin spec", raw_plugins, function(_, raw_info)
      vim.validate("[1]", raw_info[1], "string")

      local spec = M.create_base_spec(raw_info[1])

      -- Fail deliberately on error
      for prop_name, prop_type in pairs(M.input_props) do
        local raw_val = raw_info[prop_name]

        vim.validate(prop_name, raw_val, prop_type, true)

        if raw_val ~= nil then
          local key = prop_name
          local val = raw_val

          if vim.list_contains({ "branch", "tag", "commit" }, prop_name) then
            key = "version"
          end

          if prop_name == "version" then
            val = vim.version.range(raw_val)
          end

          if prop_name == "build" and type(raw_val) == "string" then
            val = function() vim.cmd(string.sub(raw_val, 2)) end
          end

          if
            vim.list_contains({ "event", "cmd" }, prop_name)
            and type(raw_val) == "string"
          then
            val = { raw_val }
          end

          spec[key] = val
        end
      end

      if spec.enabled == false then
        return
      end

      if spec.opts and not spec.config then
        spec.config = tie(
          ("Plugin %s -> config"):format(spec.name),
          function(_, opts) require(spec.main).setup(opts) end,
          tied.do_nothing
        )
      end

      if spec.dev == true then
        spec.src = ("file:///%s/%s"):format(
          vim.fn.expand(M.local_plugins_dir),
          spec.name
        )
      end

      if vim.tbl_get(M.plugins, spec.name, "opts") and spec.opts then
        M.plugins[spec.name].opts =
          vim.tbl_deep_extend("force", M.plugins[spec.name].opts, spec.opts)
      else
        M.plugins[spec.name] = spec
      end
    end)
  end,
  tied.do_nothing
)

M.load_plugin = tie(
  "Load a plugin",
  ---@param plugin_name string
  function(plugin_name)
    vim.validate("plugin_name", plugin_name, "string")

    local spec = M.plugins[plugin_name]

    assert(spec, ("Plugin %s not defined"):format(plugin_name))

    if spec.loaded ~= nil then
      return
    end

    -- Show that plugin has started to load
    spec.loaded = false

    if spec.dependencies then
      for _, dependency in ipairs(spec.dependencies) do
        local dep_name = dependency:match("([^/]+)$")
        local has_repo = dependency:match(".*/.*") ~= nil

        if not M.plugins[dep_name] then
          assert(has_repo, ("Plugin %s doesn't have repo"):format(dependency))

          M.plugins[dep_name] = M.create_base_spec(dependency)
          M.load_plugin(dep_name)
        elseif M.plugins[dep_name].loaded == nil then
          M.load_plugin(dep_name)
        end
      end
    end

    local vimpack_spec = {
      src = spec.src,
      version = spec.version,
      name = spec.name,
    }

    -- Only way to actually know when a plugin has loaded
    local load = tie("vim.pack.add -> load", function(opts)
      vim.cmd("packadd " .. plugin_name)

      -- From the original load function in vim.pack.add
      -- Fail on error deliberately
      if vim.v.vim_did_enter == 1 then
        local after_paths =
          vim.fn.glob(opts.path .. "/after/plugin/**/*.{vim,lua}", false, true)

        vim.tbl_map(
          function(path) vim.cmd.source({ path, magic = { file = false } }) end,
          after_paths
        )
      end

      if spec.config then
        spec.config(spec, spec.opts or {})
      end

      -- Show that plugin has finished loading
      spec.loaded = true

      vim.api.nvim_exec_autocmds("User", {
        pattern = "PluginLoad",
        modeline = false,
        data = { name = spec.name },
      })
    end, tied.do_nothing)

    vim.pack.add({ vimpack_spec }, { load = load, confirm = false })
  end,
  tied.do_rethrow
)

M.create_stubs = tie(
  "Create events/cmds for loading plugin",
  ---@param plugin_name string
  function(plugin_name)
    vim.validate("plugin_name", plugin_name, "string")

    local spec = M.plugins[plugin_name]

    assert(spec, ("Plugin %s not defined"):format(plugin_name))

    if spec.event then
      local group = tied.create_augroup("my.plugin.load." .. plugin_name, true)

      tied.for_list(
        "Create event for loading plugin " .. plugin_name,
        spec.event,
        function(_, full_event)
          local event_name, pattern = full_event:match("^(%S+)%s*(.*)$")

          vim.validate("event_name", event_name, "string")
          vim.validate("pattern", pattern, "string", true)

          if event_name == "VeryLazy" then
            event_name, pattern = "User", "VeryLazy"
          end

          tied.create_autocmd({
            desc = "Load plugin " .. plugin_name,
            event = event_name,
            pattern = pattern,
            once = true,
            group = group,
            callback = function()
              pcall(vim.api.nvim_del_augroup_by_id, group)

              if event_name == "UIEnter" or vim.g.did_ui_enter then
                M.load_plugin(plugin_name)
              else
                -- Execute after UIEnter has finished
                vim.schedule(function() M.load_plugin(plugin_name) end)
              end
            end,
          })
        end
      )
    end

    if spec.cmd then
      tied.for_list(
        "Create usercmd for loading plugin " .. plugin_name,
        spec.cmd,
        function(_, cmd)
          local create_opts = {
            desc = "Load plugin " .. plugin_name,
            nargs = "*",
            bang = true,
            count = -1,
          }

          tied.create_usercmd(cmd, function(cmd_opts)
            pcall(vim.api.nvim_del_user_command, cmd)
            M.load_plugin(plugin_name)

            local range

            if (cmd_opts.range or 0) > 0 then
              if cmd_opts.range == 1 then
                range = { cmd_opts.line1 }
              else
                range = { cmd_opts.line1, cmd_opts.line2 }
              end
            end

            M.on_plugin_load(
              plugin_name,
              "Execute the original usercmd after plugin loaded",
              function()
                vim.api.nvim_cmd({
                  cmd = cmd,
                  range = range,
                  args = cmd_opts.fargs,
                  bang = cmd_opts.bang,
                  mods = cmd_opts.smods,
                }, {})
              end
            )
          end, create_opts)
        end
      )
    end
  end,
  tied.do_nothing
)

M.check_if_plugin_loaded = tie(
  "Check if a plugin is loaded",
  ---@param plugin_name string
  ---@return boolean?
  function(plugin_name)
    vim.validate("plugin_name", plugin_name, "string")

    -- nil: hasn't started loading
    -- false: has started loading
    -- true: has finished loading
    return vim.tbl_get(M.plugins, plugin_name, "loaded")
  end,
  function() return false end
)

M.on_plugin_load = tie(
  "Run code if/when a plugin is loaded",
  --- @param plugin string|string[]
  --- @param desc string
  --- @param on_load function
  function(plugin, desc, on_load)
    vim.validate("plugin", plugin, { "string", "table" })
    vim.validate("desc", desc, "string")
    vim.validate("on_load", on_load, "function")

    on_load = vim.schedule_wrap(tie(desc, on_load, tied.do_nothing))

    local plugin_names = type(plugin) == "string" and { plugin } or plugin --[[@as string[] ]]
    local plugins_loaded = {}

    for _, name in ipairs(plugin_names) do
      plugins_loaded[name] = vim.tbl_get(M.plugins, name, "loaded") == true
    end

    if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
      on_load()
    else
      tied.create_autocmd({
        desc = "On plugin load -> " .. desc,
        event = "User",
        pattern = "PluginLoad",
        group = tied.create_augroup("my.on_plugin_load", false), -- don't clear
        callback = function(e)
          local plugin_name = e.data.name

          if vim.list_contains(vim.tbl_keys(plugins_loaded), plugin_name) then
            plugins_loaded[plugin_name] = true
          end

          if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
            on_load()
            vim.api.nvim_del_autocmd(e.id)
          end
        end,
      })
    end
  end,
  tied.do_nothing
)

M.setup = tie("Setup plugin manager", function()
  M.add_plugin_specs(tied.dir({
    path = vim.fn.stdpath("config") .. "/lua/plugin",
    type = "file",
    ext = ".lua",
    map = function(file_name)
      return require("plugin." .. file_name:gsub("%.lua$", ""))
    end,
  }))

  tied.plugins = M.plugins
  tied.check_if_plugin_loaded = M.check_if_plugin_loaded
  tied.load_plugin = M.load_plugin
  tied.on_plugin_load = M.on_plugin_load

  tied.create_autocmd({
    desc = "Load lazy plugins",
    event = "UIEnter",
    once = true,
    group = tied.create_augroup("my.pack.load_after", true),
    callback = vim.schedule_wrap(function()
      vim.g.did_ui_enter = true
      vim.api.nvim_exec_autocmds("User", {
        pattern = "VeryLazy",
        modeline = false,
      })
    end),
  })
  tied.create_autocmd({
    desc = "Build on plugin install/update",
    event = "PackChanged",
    group = tied.create_augroup("my.pack.build", true),
    callback = vim.schedule_wrap(function(ev)
      if vim.list_contains({ "install", "update" }, ev.data.kind) then
        local plugin_name = ev.data.spec.name
        local build = vim.tbl_get(M.plugins, plugin_name, "build")

        if build then
          M.on_plugin_load(plugin_name, "Run build command", build)
        end
      end
    end),
  })

  -- Run all init functions first, before loading any plugin
  tied.for_table("Init plugin", M.plugins, function(_, spec)
    if spec.init then
      spec.init()
    end
  end)

  tied.for_table("Setup plugin loading", M.plugins, function(_, spec)
    if spec.lazy == false then
      M.load_plugin(spec.name)
    elseif spec.event or spec.cmd then
      M.create_stubs(spec.name)
    end
  end)

  -- Enable built-in plugins later
  vim.schedule(function()
    vim.cmd("packadd nvim.undotree")
    vim.cmd("packadd nvim.difftool")
  end)
end, tied.do_nothing)

return M
