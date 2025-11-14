-- NOTE: Coding guide for nvim development -> :h dev
-- NOTE: Docs:
-- https://neovim.io/doc/user/lua.html
-- https://neovim.io/doc/user/lua-guide
-- NOTE: Useful API:
-- vim.g - set or get global variable
-- vim.o or vim.opt - set option
-- vim.notify() - better print
-- vim.cmd() - execute command
-- vim.tbl_contains() - check if lua table contains a value
-- vim.tbl_deep_extend() - extend lua table
-- vim.schedule(some_func) - execute function async
-- vim.defer_fn(some_func, 500) - execute function after specified time
-- vim.fn.some_func() - call any builtin vim function

-- NOTE: Enter keys as if the user typed them (useful for partial commands):
-- local ctrlc = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
-- vim.api.nvim_feedkeys(ctrlc .. ":'<,'>", "n", false)

-- Aliases for tied global builtins
tied.create_usercmd = vim.api.nvim_create_user_command
tied.ui_input = vim.ui.input
tied.ui_select = vim.ui.select

local foreach = tie(
  "Foreach wrapper",
  ---@param is_list boolean
  function(is_list)
    vim.validate("is_list", is_list, "boolean")

    local outer_desc = (
      is_list and
      "Tied foreach in list" or
      "Tied foreach in table"
    )

    return tie(
      outer_desc,
      --- Use this function when one iteration shouldn't
      --- prevent other iterations from trying to execute
      ---@param iter table|function
      ---@param desc string
      ---@param on_try function
      function(iter, desc, on_try)
        vim.validate("iter", iter, { "table", "function", })
        vim.validate("desc", desc, "string")
        vim.validate("on_try", on_try, "function")

        local fn = tie(desc, on_try, tied.do_nothing)

        if type(iter) == "table" then
          local create = is_list and ipairs or pairs
          for key, val in create(iter) do fn(key, val) end
        else
          for key, val in iter do fn(key, val) end
        end
      end,
      tied.do_nothing
    )
  end,
  tied.do_rethrow
)
tied.each_i = foreach(true)
tied.each = foreach(false)

tied.create_map = tie(
  "Create vim keymap",
  --- @param modes string|string[]
  --- @param lhs string
  --- @param rhs string|function
  --- @param opts vim.keymap.set.Opts?
  function(modes, lhs, rhs, opts)
    vim.validate("modes", modes, { "string", "table" })
    vim.validate("lhs", lhs, "string")
    vim.validate("rhs", rhs, { "string", "function" })
    vim.validate("opts", opts, "table")

    opts = opts or {}

    local isnt_abbrev = type(modes) == "table" or (modes ~= "ca" and modes ~= "!a")

    if opts.silent == nil and isnt_abbrev then
      opts.silent = true
    end

    -- rhs is tied in builtins if function
    vim.keymap.set(modes, lhs, rhs, opts)
  end,
  tied.do_nothing
)

tied.delete_maps = tie(
  "Delete vim keymaps",
  --- @param modes string|table
  --- @param commands table
  function(modes, commands)
    vim.validate("modes", modes, { "string", "table", })
    vim.validate("commands", commands, "table")

    tied.each_i(commands, "Delete vim keymap", function(_, lhs)
      -- vim.keymap.del() can fail if the mapping doesn't exist
      -- so use create_map instead
      tied.create_map(modes, lhs, "<nop>", { desc = "Nothing" })
    end)
  end,
  tied.do_nothing
)

tied.apply_maps = tie(
  "Apply vim keymaps",
  --- @param to_create table?
  --- @param to_delete table?
  function(to_create, to_delete)
    vim.validate("to_create", to_create, "table", true)
    vim.validate("to_delete", to_delete, "table", true)

    -- Order matters, first delete and then create
    if to_delete then
      for _, v in ipairs(to_delete) do
        tied.delete_maps(unpack(v))
      end
    end
    if to_create then
      for _, v in ipairs(to_create) do
        tied.create_map(unpack(v))
      end
    end
  end,
  tied.do_nothing
)

tied.dir = tie(
  "Traverse a directory and return item names",
  --- @class TiedDirOpts
  --- @field path string
  --- @field type "file"|"dir"
  --- @field ext string?
  --- @field depth number?
  --- @field map function?
  --- @param opts TiedDirOpts
  function(opts)
    vim.validate("opts", opts, "table")
    vim.validate("opts.path", opts.path, "string")
    vim.validate("opts.type", opts.type, "string")
    vim.validate("opts.ext", opts.ext, "string", true)
    vim.validate("opts.depth", opts.depth, "number", true)
    vim.validate("opts.map", opts.map, "function", true)

    local entries = {}
    local item_type = opts.type ---@type string

    if opts.type == "dir" then
      item_type = "directory"
    end

    for name, type in vim.fs.dir(opts.path, { depth = opts.depth or math.huge }) do
      local matches_ext = not opts.ext or vim.endswith(name, "."..opts.ext)

      if type == item_type and matches_ext then
        table.insert(entries, opts.map and opts.map(name) or name)
      end
    end

    return entries
  end,
  function() return {} end
)

tied.colorscheme_config = tie(
  "Configure colorscheme plugin",
  --- @param opts table
  function(_, opts)
    vim.validate("opts", opts, "table")

    require(vim.g.colorscheme).setup(opts)
    vim.cmd("colorscheme "..vim.g.colorscheme)
  end,
  tied.do_nothing
)

tied.get_fold_text = tie(
  "Get fold text",
  function()
    local start_line_nr = vim.v.foldstart
    local end_line_nr = vim.v.foldend
    local first_line = vim.fn.getline(start_line_nr)
    local fold_lines_nr = end_line_nr - start_line_nr + 1
    local text = string.format("%s ⮞ [%d lines]", first_line, fold_lines_nr)

    return text
  end,
  function()
    return vim.fn.getline(vim.v.foldstart)
  end
)

-- From LazyVim
tied.on_plugin_load = tie(
  "Run code if a plugin is enabled",
  --- @param plugin_names string[]
  --- @param desc string
  --- @param on_load function
  function(plugin_names, desc, on_load)
    vim.validate("plugin_names", plugin_names, "table")
    vim.validate("desc", desc, "string")
    vim.validate("on_load", on_load, "function")

    on_load = vim.schedule_wrap(tie(desc, on_load, tied.do_nothing))

    local lazy_plugins = require("lazy.core.config").plugins
    local plugins_loaded = {}

    for _, name in ipairs(plugin_names) do
      plugins_loaded[name] = false

      if lazy_plugins[name] and lazy_plugins[name]._.loaded then
        plugins_loaded[name] = true
      end
    end

    if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
      on_load(lazy_plugins)
    else
      tied.create_autocmd({
        desc = "On plugin load -> " .. desc,
        event = "User",
        -- Don't clear autocmds for the group
        group = tied.create_augroup("my.on_plugin_load", false),
        pattern = "LazyLoad",
        callback = function(e)
          if vim.list_contains(vim.tbl_keys(plugins_loaded), e.data) then
            plugins_loaded[e.data] = true
          end

          if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
            on_load(lazy_plugins)
            return true -- clear autocmd
          end
        end,
      })
    end
  end,
  tied.do_nothing
)

tied.create_augroup = tie(
  "Create augroup",
  --- @param name string
  --- @param clear boolean
  --- @return integer
  function(name, clear)
    vim.validate("name", name, "string")
    vim.validate("clear", clear, "boolean")

    return vim.api.nvim_create_augroup(name, { clear = clear })
  end,
  tied.do_rethrow
)

---@class MyAutocmdOpts : vim.api.keyset.create_autocmd
---@field desc string
---@field event string|string[]

tied.create_autocmd = tie(
  "Create autocmd",
  --- @param opts MyAutocmdOpts
  --- @return integer
  function(opts)
    vim.validate("opts", opts, "table")
    vim.validate("opts.desc", opts.desc, "string")
    vim.validate("opts.event", opts.event, { "string", "table" })

    local event = opts.event

    opts.event = nil

    return vim.api.nvim_create_autocmd(event, opts)
  end,
  tied.do_rethrow
)

tied.check_keys = tie(
  "Check if a table has nested keys",
  ---@param tbl table
  ---@param keys string[]
  function(tbl, keys)
    vim.validate("tbl", tbl, "table")
    vim.validate("keys", keys, "table")

    for _, key in ipairs(keys) do
      if type(tbl) == "table" and tbl[key] then
        tbl = tbl[key]
      else
        return false
      end
    end

    return true
  end,
  tied.do_rethrow
)
