-- Docs: https://neovim.io/doc/user/lua.html
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

local M = {}
local tied = {}

tied.create_map = tie(
  "tied.create_map",
  --- @param modes string|table
  --- @param lhs string
  --- @param rhs string|fun(...: any): any
  --- @param opts table
  function(modes, lhs, rhs, opts)
    local isnt_abbrev = type(modes) == "table" or (modes ~= "ca" and modes ~= "!a")

    if opts.silent == nil and isnt_abbrev then
      opts.silent = true
    end

    if type(rhs) == "function" then
      rhs = tie("tied.create_map -> "..opts.desc, rhs, do_nothing)
    end

    vim.keymap.set(modes, lhs, rhs, opts)
  end,
  do_nothing
)

tied.delete_maps = tie(
  "tied.delete_maps",
  --- @param modes string|table
  --- @param commands table
  function(modes, commands)
    for _, lhs in ipairs(commands) do
      -- vim.keymap.del() can fail if the mapping doesn't exist
      -- so use create_map instead
      tied.create_map(modes, lhs, "<nop>", { desc = "Nothing" })
    end
  end,
  do_nothing
)

tied.apply_maps = tie(
  "tied.apply_maps",
  --- @param to_create table?
  --- @param to_delete table?
  function(to_create, to_delete)
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
  do_nothing
)

tied.create_autocmd = tie(
  "tied.create_autocmd",
  --- @param group_name string
  --- @param events string|table
  --- @param opts table
  function(group_name, events, opts)
    opts.group = vim.api.nvim_create_augroup(group_name, { clear = true })

    if type(opts.callback) == "function" then
      -- type `:h nvim_create_autocmd` to see all the args for `callback`
      opts.callback = tie(group_name, opts.callback, do_nothing)
    end

    vim.api.nvim_create_autocmd(events, opts)
  end,
  function(props)
    local group_name = props.args.group_name
    vim.api.nvim_del_augroup_by_name(group_name)
  end
)

tied.create_usercmd = tie(
  "tied.create_usercmd",
  --- @param name string
  --- @param command string|fun(t: table)
  --- @param opts table
  function(name, command, opts)
    if type(command) == "function" then
      local desc = name

      if type(opts.desc == "string") then desc = opts.desc end

      command = tie(desc, command, do_nothing)
    end

    vim.api.nvim_create_user_command(name, command, opts)
  end,
  function(props)
    local name = props.args.name
    vim.api.nvim_del_user_command(name)
  end
)

tied.get_files = tie(
  "tied.get_files",
  --- @param opts { ext: string, path: string, map: function }
  function(opts)
    local ext, path, map = opts.ext, opts.path, opts.map

    if map == nil then
      map = function(file) return path .. "/" .. file end
    end

    map = tie("tied.get_files -> map", map, do_nothing)

    local entries = {}

    for name, type in vim.fs.dir(path, { depth = math.huge }) do
      if type == "file" and name:match("%"..ext.."$") then
        table.insert(entries, map(name) or name)
      end
    end

    return entries
  end,
  do_nothing
)

tied.ui_input = tie(
  "tied.ui_input",
  --- @param opts table
  --- @param func function
  function(opts, func)
    local desc = "tied.ui_input -> prompt: "

    if type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "none"
    end

    vim.schedule(function() vim.ui.input(opts, tie(desc, func, do_nothing)) end)
  end,
  do_nothing
)

tied.ui_select = tie(
  "tied.ui_select",
  --- @param list table
  --- @param opts table
  --- @param func function
  function(list, opts, func)
    local desc = "tied.ui_select -> prompt: "

    if type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "none"
    end

    -- vim.schedule(function()
    vim.ui.select(list, opts, tie(desc, func, do_nothing))
    -- end)
  end,
  do_nothing
)

tied.colorscheme_config = tie(
  "tied.colorscheme_config",
  --- @param opts table
  function(_, opts)
    require(vim.g.colorscheme).setup(opts)
    vim.cmd("colorscheme "..vim.g.colorscheme)
  end,
  do_nothing
)

tied.get_fold_text = tie(
  "tied.get_fold_text",
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

-- from LazyVim
tied.on_plugin_load = tie(
  "tied.on_plugin_load",
  --- @param name string
  --- @param fn function
  function(name, fn)
    local lazy_config = require("lazy.core.config")

    if not lazy_config.plugins[name] then return end

    local is_loaded = lazy_config.plugins[name]._.loaded
    local fn_desc = "on_plugin_load -> "..name

    fn = vim.schedule_wrap(tie(fn_desc, fn, do_nothing))

    if is_loaded then
      fn()
      return
    end

    tied.create_autocmd(
      "augroup -> "..fn_desc,
      "User",
      {
        pattern = "LazyLoad",
        callback = function(event)
          if event.data == name then
            fn()
            return true -- clear autocmd
          end
        end,
      }
    )
  end,
  do_nothing
)

M.setup = tie(
  "setup utils",
  function()
    _G.tied = tied
  end,
  do_nothing
)

return M
