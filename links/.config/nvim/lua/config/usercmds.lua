local M = {}

M.setup = vim.schedule_wrap(tie("Setup usercmds", function()
  tied.for_list(
    "Queue usercmd to create",
    M.config,
    function(_, usercmd) tied.create_usercmd(unpack(usercmd)) end
  )
end, tied.do_nothing))

M.get_all_plugin_names = tie(
  "Get the names of all installed plugins",
  function()
    return vim
      .iter(vim.pack.get(nil, { info = false }))
      :map(function(plugin) return plugin.spec.name end)
      :totable()
  end,
  tied.do_rethrow
)

M.get_plugin_name_completions = tie(
  "Get completions for a vim.pack command",
  ---@param typed string
  function(typed)
    vim.validate("typed", typed, "string")

    local completions = {}
    local plugin_names = M.get_all_plugin_names()

    if #plugin_names < 1 then
      return {}
    end

    if vim.startswith("all", typed) then
      table.insert(completions, "all")
    end

    tied.for_list("Append plugin completion", plugin_names, function(_, name)
      if vim.startswith(name, typed) then
        table.insert(completions, name)
      end
    end)

    return completions
  end,
  function() return {} end
)

---@type UserCmdArgs[]
M.config = {
  {
    "Navigate",
    function(opts)
      local vim_dir = opts.fargs[1]
      local kitty_dirs = { h = "left", l = "right", j = "bottom", k = "top" }

      if vim.fn.winnr(vim_dir) ~= vim.fn.winnr() then
        vim.cmd("wincmd " .. vim_dir)
      else
        vim.system({
          "kitty",
          "@",
          "focus-window",
          "--match",
          "neighbor:" .. kitty_dirs[vim_dir],
        })
      end
    end,
    { desc = "Navigate between splits", nargs = 1 },
  },
  {
    "Find",
    "execute('silent lgrep! ' .. <q-args>) | lopen",
    { desc = "Find in all files", nargs = "+", complete = "dir" },
  },
  {
    "NvimClearCache",
    function()
      tied.ui_select(
        { "Yes", "No" },
        { prompt = "Are you sure you want to reset nvim config?" },
        function(choice)
          if type(choice) ~= "string" or not choice:match("Yes") then
            return
          end

          tied.for_list(
            "Remove an nvim related dir",
            { "data", "cache", "state" },
            function(_, name)
              local dir = vim.fn.stdpath(name)

              if vim.uv.fs_stat(dir) then
                vim.fs.rm(dir, { recursive = true, force = true })
              end
            end
          )
          vim.cmd("qall")
        end
      )
    end,
    { desc = "Remove all files related to neovim besides config", nargs = 0 },
  },
  {
    "Replace",
    function()
      local is_loclist = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist
        == 1

      if not is_loclist then
        vim.notify(
          "This command needs to be executed in a loclist!",
          vim.log.levels.WARN
        )
        return
      end

      tied.ui_input({ prompt = "Search for: " }, function(search)
        if type(search) ~= "string" then
          return
        end

        tied.ui_input({ prompt = "Replace with: " }, function(replace)
          if type(replace) ~= "string" then
            return
          end

          tied.ui_select(
            { "Yes, but only full words", "Yes, any occurance", "No" },
            { prompt = ("Replace `%s` with `%s` ?"):format(search, replace) },
            function(choice)
              if type(choice) ~= "string" then
                return
              end

              if choice:match("full words") then
                search = ("\\<%s\\>"):format(search)
              end

              if choice:match("Yes") then
                vim.cmd("lfirst | only | lopen")
                vim.cmd(
                  ("%s %%sno@%s@%s@gIe | update | bdelete"):format(
                    "silent noautocmd keepjumps keepalt lfdo",
                    search,
                    replace
                  )
                )
                vim.cmd("llast | lclose")
              end
            end
          )
        end)
      end)
    end,
    { desc = "Replace text in files", nargs = 0 },
  },
  {
    "PluginListAll",
    function() vim.pack.update(nil, { offline = true }) end,
    { desc = "List all installed plugins", nargs = 0 },
  },
  {
    "PluginListInactive",
    function()
      local plugin_names = {}

      for _, plugin in ipairs(vim.pack.get()) do
        if not tied.plugin_loaded(plugin.spec.name) then
          table.insert(plugin_names, plugin.spec.name)
        end
      end

      -- stylua: ignore
      vim.notify(vim.inspect(plugin_names), vim.log.levels.INFO, { title = "Inactive Plugins" })
    end,
    { desc = "List inactive plugins", nargs = 0 },
  },
  {
    "PluginDelete",
    function(opts)
      local plugin_names = opts.fargs
      local should_delete_all = vim.list_contains(plugin_names, "all")

      if should_delete_all then
        plugin_names = M.get_all_plugin_names()
      end

      vim.pack.del(plugin_names, { force = true })
      vim.notify("Uninstalled plugins, please restart")
    end,
    {
      desc = "Delete plugins with vim.pack",
      nargs = "+",
      complete = M.get_plugin_name_completions,
    },
  },
  {
    "PluginDeleteInactive",
    function()
      local plugin_names = {}

      for _, plugin in ipairs(vim.pack.get()) do
        if not tied.plugin_loaded(plugin.spec.name) then
          table.insert(plugin_names, plugin.spec.name)
        end
      end

      vim.pack.del(plugin_names, { force = true })
      vim.notify("Uninstalled plugins, please restart")
    end,
    { desc = "Clear inactive plugins with vim.pack", nargs = 0 },
  },
  {
    "PluginUpdate",
    function(opts)
      local plugin_names = nil

      if not vim.list_contains(opts.fargs, "all") then
        plugin_names = opts.fargs
      end

      vim.pack.update(plugin_names, { force = true })
    end,
    {
      desc = "Update plugins with vim.pack",
      nargs = "+",
      complete = M.get_plugin_name_completions,
    },
  },
  {
    "PluginRevert",
    function(opts)
      local plugin_names = opts.fargs
      local targets = nil

      if not vim.list_contains(plugin_names, "all") then
        targets = plugin_names
      end

      vim.pack.update(
        targets,
        { force = true, offline = true, target = "lockfile" }
      )
    end,
    {
      desc = "Revert plugins with vim.pack",
      nargs = "+",
      complete = M.get_plugin_name_completions,
    },
  },
}

return M
