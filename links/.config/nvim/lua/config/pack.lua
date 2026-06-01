-- NOTE:
-- vim.pack guide from creator: https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
-- Inspired from: https://github.com/kite12580/pack.lua/blob/main/README.md
-- Another plugin manager with vim.pack: https://github.com/zuqini/zpack.nvim

local M = {
  ---@type table<string,PluginSpec>
  plugins = {},
  local_plugins_dir = "~/projects",
  to_install = {},
  early_load_queue = {},
  lazy_load_queue = {},
  input_props = {
    src = "string",
    name = "string",
    submodule = "boolean",
    version = { "string", "table" },
    dependencies = "table",
    enabled = "boolean",
    lazy = "boolean",
    dev = "boolean",
    opts = "table",
    init = "function",
    config = "function",
    build = { "string", "function" },
    cmd = { "string", "table" },
    ft = { "string", "table" },
  },
}

M.parse_src = tie(
  "Convert plugin spec src to url",
  ---@param src string
  ---@return string
  function(src)
    vim.validate("src", src, "string")
    assert(src:match(".*/.*") ~= nil, "Invalid src")

    -- stylua: ignore
    return vim.startswith("https://", src) and src or ("https://github.com/" .. src)
  end,
  tied.do_rethrow
)

M.parse_name = tie(
  "Convert plugin spec src to name",
  ---@param src string
  ---@return string
  function(src) return src:match("([^/]+)$"):gsub("%.nvim$", "") end,
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

    local sub_opts = {}

    tied.for_list("Parse plugin spec", raw_plugins, function(_, spec)
      for prop_name, prop_type in pairs(M.input_props) do
        vim.validate(prop_name, spec[prop_name], prop_type, true)
      end

      if spec.enabled == false then
        return
      end

      spec.src = M.parse_src(spec.src)

      if not spec.name then
        spec.name = M.parse_name(spec.src)
      end

      if type(spec.build) == "string" then
        local build_cmd = string.sub(spec.build --[[@as string]], 2)

        spec.build = tie(
          ("Plugin %s -> build"):format(spec.name),
          function() vim.cmd(build_cmd) end,
          tied.do_nothing
        )
      end

      if spec.opts and not spec.config then
        spec.config = tie(
          ("Plugin %s -> config"):format(spec.name),
          function(opts) require(spec.name).setup(opts) end,
          tied.do_nothing
        )
      end

      if spec.dev == true then
        spec.src = ("file:///%s/%s"):format(
          vim.fn.expand(M.local_plugins_dir),
          spec.src:match("([^/]+)$") -- repo name, not plugin name
        )
      end

      if spec.submodule then
        sub_opts[spec.name] =
          vim.tbl_deep_extend("error", sub_opts[spec.name] or {}, spec.opts)
      elseif not M.plugins[spec.name] then
        M.plugins[spec.name] = spec
      else
        error(("Plugin %s is defined more than once"):format(spec.name))
      end
    end)

    tied.for_table(
      "Merge submodule opts into main spec",
      sub_opts,
      function(spec_name, opts)
        local main_spec = M.plugins[spec_name]

        if main_spec then
          main_spec.opts =
            vim.tbl_deep_extend("error", main_spec.opts or {}, opts)
        end
      end
    )

    tied.for_list(
      "Add missing dependencies to plugin list",
      vim.tbl_values(M.plugins),
      function(_, spec)
        if not spec.dependencies then
          return
        end

        local parsed_deps = {}

        for idx, dependency in ipairs(spec.dependencies) do
          local dep_spec = {}

          if type(dependency) == "table" then
            dep_spec.src = dependency.src
            dep_spec.name = dependency.name or dep_spec.src
          elseif type(dependency) == "string" then
            dep_spec.src = dependency
            dep_spec.name = dependency
          end

          vim.validate(("deps[%d].src"):format(idx), dep_spec.src, "string")
          vim.validate(("deps[%d].name"):format(idx), dep_spec.name, "string")

          dep_spec.src = M.parse_src(dep_spec.src)
          dep_spec.name = M.parse_name(dep_spec.name)

          table.insert(parsed_deps, dep_spec)

          if not M.plugins[dep_spec.name] then
            M.plugins[dep_spec.name] = dep_spec
          end
        end

        spec.dependencies = parsed_deps
      end
    )
  end,
  tied.do_nothing
)

M.load_plugins = tie(
  "Load plugins",
  ---@param plugin_names string[]
  function(plugin_names)
    vim.validate("plugin_names", plugin_names, "table")

    tied.for_list("Load a plugin", plugin_names, function(_, plugin_name)
      local spec = M.plugins[plugin_name]

      assert(spec, ("Plugin %s not defined"):format(plugin_name))

      if spec.loaded ~= nil then
        return
      end

      -- Show that plugin has started to load
      spec.loaded = false

      if spec.dependencies then
        local deps_to_load = {}

        for _, dep_spec in ipairs(spec.dependencies) do
          -- Fail on dependency not being listed as plugin
          if not M.plugins[dep_spec.name].loaded then
            table.insert(deps_to_load, dep_spec.name)
          end
        end

        if #deps_to_load > 0 then
          M.load_plugins(deps_to_load)
          M.on_plugins_load(
            "Load plugin " .. spec.name,
            deps_to_load,
            function()
              spec.loaded = nil
              M.load_plugins({ spec.name })
            end
          )

          return
        end
      end

      -- Loads the plugin
      vim.cmd("packadd " .. spec.name)

      -- From the original load function in vim.pack.add
      -- Fail on error deliberately
      if vim.v.vim_did_enter == 1 then
        local opts = vim.pack.get({ spec.name }, { info = false })[1]
        local after_paths =
          vim.fn.glob(opts.path .. "/after/plugin/**/*.{vim,lua}", false, true)

        vim.tbl_map(
          function(path) vim.cmd.source({ path, magic = { file = false } }) end,
          after_paths
        )
      end

      -- build() before config()
      vim.api.nvim_exec_autocmds("User", {
        pattern = "PluginBuild",
        modeline = false,
        data = { name = spec.name },
      })

      if spec.config then
        spec.config(spec.opts or {})
      end

      spec.loaded = true

      vim.api.nvim_exec_autocmds("User", {
        pattern = "OnPluginLoad",
        modeline = false,
        data = { name = spec.name },
      })
    end)
  end,
  tied.do_nothing
)

M.create_ft_event = tie(
  "Create event for loading a plugin",
  ---@param spec PluginSpec
  function(spec)
    vim.validate("spec", spec, "table")

    tied.create_autocmd({
      desc = "Load plugin " .. spec.name,
      event = "FileType",
      pattern = type(spec.ft) == "string" and { spec.ft } or spec.ft,
      once = true,
      group = tied.create_augroup("my.pack.load." .. spec.name, true),
      callback = function(e)
        pcall(vim.api.nvim_del_autocmd, e.id)

        if vim.g.did_ui_enter then
          M.load_plugins({ spec.name })
        else
          -- Execute after UIEnter has finished
          vim.schedule(function() M.load_plugins({ spec.name }) end)
        end
      end,
    })
  end,
  tied.do_nothing
)

M.create_cmd_stubs = tie(
  "Create usercmd stubs for loading a plugin",
  ---@param spec PluginSpec
  function(spec)
    vim.validate("spec", spec, "table")

    local cmds = type(spec.cmd) == "string" and { spec.cmd } or spec.cmd

    tied.for_list(
      "Create usercmd for loading plugin " .. spec.name,
      cmds --[[@as string[] ]],
      function(_, cmd)
        local create_opts = {
          desc = "Load plugin " .. spec.name,
          nargs = "*",
          bang = true,
          count = -1,
        }

        tied.create_usercmd(cmd, function(cmd_opts)
          pcall(vim.api.nvim_del_user_command, cmd)
          local range

          if (cmd_opts.range or 0) > 0 then
            if cmd_opts.range == 1 then
              range = { cmd_opts.line1 }
            else
              range = { cmd_opts.line1, cmd_opts.line2 }
            end
          end

          M.load_plugins({ spec.name })
          M.on_plugins_load(
            "Execute the original usercmd after plugin loaded",
            { spec.name },
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
  end,
  tied.do_nothing
)

M.plugin_loaded = tie(
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
  tied.do_rethrow
)

M.on_plugins_load = tie(
  "Run code if/when a plugin is loaded",
  --- @param desc string
  --- @param plugin_names string[]
  --- @param on_load function
  function(desc, plugin_names, on_load)
    vim.validate("desc", desc, "string")
    vim.validate("plugin_names", plugin_names, "table")
    vim.validate("on_load", on_load, "function")

    on_load = tie(desc, on_load, tied.do_nothing)

    local plugins_loaded = {}

    for _, name in ipairs(plugin_names) do
      assert(M.plugins[name], ("Plugin %s not defined"):format(name))

      plugins_loaded[name] = M.plugins[name].loaded == true
    end

    if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
      on_load()
    else
      tied.create_autocmd({
        desc = "On plugin load -> " .. desc,
        event = "User",
        pattern = "OnPluginLoad",
        group = tied.create_augroup("my.on_plugins_load", false), -- don't clear
        callback = function(e)
          local plugin_name = e.data.name

          if vim.list_contains(vim.tbl_keys(plugins_loaded), plugin_name) then
            plugins_loaded[plugin_name] = true
          end

          if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
            pcall(vim.api.nvim_del_autocmd, e.id)
            on_load()
          end
        end,
      })
    end
  end,
  tied.do_nothing
)

M.autocmds = {
  {
    desc = "Build on plugin install/update",
    event = "PackChangedPre",
    group = tied.create_augroup("my.pack.build", true),
    callback = function(ev)
      if not vim.list_contains({ "install", "update" }, ev.data.kind) then
        return
      end

      local plugin_name = ev.data.spec.name
      local spec = M.plugins[plugin_name] or {}

      if not spec.build then
        return
      end

      if spec.loaded then
        spec.build()
      else
        tied.create_autocmd({
          desc = "Run build command for plugin " .. plugin_name,
          event = "User",
          pattern = "PluginBuild",
          group = tied.create_augroup("my.pack.build." .. plugin_name, true),
          callback = function(e)
            if e.data.name == plugin_name then
              pcall(vim.api.nvim_del_autocmd, e.id)
              spec.build()
            end
          end,
        })
      end
    end,
  },
  {
    desc = "Call AfterUI event",
    event = "UIEnter",
    once = true,
    group = tied.create_augroup("my.pack.run_after_uienter", true),
    callback = vim.schedule_wrap(function()
      vim.g.did_ui_enter = true
      vim.api.nvim_exec_autocmds("User", {
        pattern = "AfterUI",
        modeline = false,
      })
    end),
  },
  {
    desc = "Load early plugins",
    event = "UIEnter",
    group = tied.create_augroup("my.pack.load_early_plugins", true),
    once = true,
    callback = function() M.load_plugins(M.early_load_queue) end,
  },
  {
    desc = "Load lazy plugins",
    event = "User",
    pattern = "AfterUI",
    group = tied.create_augroup("my.pack.load_lazy_plugins", true),
    once = true,
    callback = function() M.load_plugins(M.lazy_load_queue) end,
  },
}

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
  tied.plugin_loaded = M.plugin_loaded
  tied.load_plugins = M.load_plugins
  tied.on_plugins_load = M.on_plugins_load

  tied.for_list(
    "Create plugin related autocmd",
    M.autocmds,
    function(_, cmd_opts) tied.create_autocmd(cmd_opts) end
  )

  tied.for_table("Setup a plugin", M.plugins, function(_, spec)
    -- Init functions are ran before any plugin is loaded
    if spec.init then
      spec.init()
    end

    -- Don't load at all on lazy = nil

    if spec.lazy == false then
      table.insert(M.early_load_queue, spec.name)
    end

    if spec.lazy == true then
      table.insert(M.lazy_load_queue, spec.name)
    end

    if spec.ft then
      M.create_ft_event(spec)
    end

    if spec.cmd then
      M.create_cmd_stubs(spec)
    end

    table.insert(M.to_install, {
      src = spec.src,
      version = spec.version,
      name = spec.name,
    })
  end)

  -- Install, but don't load
  pcall(vim.pack.add, M.to_install, { load = function() end, confirm = false })

  -- Enable built-in plugins later
  vim.schedule(function()
    vim.cmd("packadd nvim.undotree")
    vim.cmd("packadd nvim.difftool")
  end)
end, tied.do_nothing)

return M
