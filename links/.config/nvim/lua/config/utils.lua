-- Docs: https://neovim.io/doc/user/lua.html
-- NOTE: Useful API used in this or other files:
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
  "create_map",
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
      rhs = tie("create_map -> "..opts.desc, rhs, do_nothing)
    end

    vim.keymap.set(modes, lhs, rhs, opts)
  end,
  do_nothing
)

tied.delete_maps = tie(
  "delete_maps",
  --- @param modes string|table
  --- @param commands table
  function(modes, commands)
    for _, lhs in ipairs(commands) do
      tied.create_map(modes, lhs, "<nop>", { desc = "Nothing" })
    end
  end,
  do_nothing
)

tied.create_au = tie(
  "create_au",
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

tied.create_cmd = tie(
  "create_cmd",
  --- @param name string
  --- @param command string|fun()
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

tied.find_files = tie(
  "find_files",
  --- @param opts table
  function(opts)
    local ext, path, map = opts.ext, opts.path, opts.map

    if map == nil then
      map = function(file) return path .. "/" .. file end
    end

    map = tie("find_files -> map", map, do_nothing)

    local entries = {}

    for name, type in vim.fs.dir(path, { depth = math.huge }) do
      if type == "file" and name:match("%"..ext.."$") then
        table.insert(entries, map(name))
      end
    end

    return entries
  end,
  do_nothing
)

tied.ui_input = tie(
  "ui_input",
  --- @param opts table
  --- @param func function
  function(opts, func)
    local desc = "ui_input -> prompt: "

    if type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "[not defined]"
    end


    vim.schedule(function() vim.ui.input(opts, tie(desc, func, do_nothing)) end)
  end,
  do_nothing
)

tied.ui_select = tie(
  "ui_select",
  --- @param list table
  --- @param opts table
  --- @param func function
  function(list, opts, func)
    local desc = "ui_select -> prompt: "

    if type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "[not defined]"
    end

    -- vim.schedule(function()
    vim.ui.select(list, opts, tie(desc, func, do_nothing))
    -- end)
  end,
  do_nothing
)

tied.colorscheme_config = tie(
  "colorscheme_config",
  function(_, opts)
    require(vim.g.colorscheme).setup(opts)
    vim.cmd("colorscheme "..vim.g.colorscheme)
  end,
  do_nothing
)

tied.delay_notifications = tie(
  "delay_notifications",
  function()
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
