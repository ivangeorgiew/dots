-- NOTE: Useful API used in this or other files:
-- vim.g - set or get global variable
-- vim.o or vim.opt - set option
-- vim.notify() - better print
-- vim.cmd() - execute command
-- vim.tbl_contains() - check if lua table contains a value
-- vim.tbl_deep_extend() -- extend lua table
-- vim.ui.input({ prompt = "Name: " }, function(input) end) -- get input and use it
-- vim.schedule(some_func) -- execute function async
-- vim.defer_fn(some_func, 500) -- execute function after specified time
-- vim.call(reg_recording) -- call builtin vim function

-- NOTE: Enter keys as if the user typed them (useful for partial commands):
-- local ctrlc = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
-- vim.api.nvim_feedkeys(ctrlc .. ":'<,'>", "n", false)

-- don't substitute error(), because you lose the traceback
-- and function termination functionality
local local_print = tie(
  "print",
  {},
  function(...)
    local args = {...}
    local print_safe_args = {}

    for i=1, #args do
      table.insert(print_safe_args, tostring(args[i]))
    end

    vim.notify(table.concat(print_safe_args, ' '), vim.log.levels.INFO)
  end,
  function(props)
    _print(unpack(props.args))
  end
)

local create_map = tie(
  "create mapping",
  { { "string", "table" }, "string", { "string", "function" }, "table" },
  function(modes, lhs, rhs, opts)
    local isnt_abbrev = type(modes) == "table" or (modes ~= "ca" and modes ~= "!a")

    if opts.silent == nil and isnt_abbrev then
      opts.silent = true
    end

    if type(rhs) == "function" then
      rhs = tie(opts.desc, {}, rhs)
    end

    vim.keymap.set(modes, lhs, rhs, opts)
  end
)

local create_au = tie(
  "create augroup",
  { "string", { "string", "table" }, "table"},
  function(group_name, events, opts)
    opts.group = vim.api.nvim_create_augroup(group_name, { clear = true })

    if type(opts.callback) == "function" then
      -- type `:h nvim_create_autocmd` to see all the args for `callback`
      opts.callback = tie(group_name, { "table" }, opts.callback)
    end

    vim.api.nvim_create_autocmd(events, opts)
  end,
  function(props)
    vim.api.nvim_del_augroup_by_name(group_name)
  end
)

local create_cmd = tie(
  "create user command",
  { "string", { "string", "function" }, "table"},
  function(name, command, opts)
    if type(command) == "function" then
      local desc = name

      if type(opts.desc == "string") then desc = opts.desc end

      command = tie(desc, { "table" }, command)
    end

    vim.api.nvim_create_user_command(name, command, opts)
  end
)

_G._print = _G.print
_G.print = local_print
_G.create_map = create_map
_G.create_au = create_au
_G.create_cmd = create_cmd
