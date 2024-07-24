-- NOTE: Useful API used in this or other files:
-- vim.g - set or get global variable
-- vim.o or vim.opt - set option
-- vim.notify() - better print
-- vim.cmd() - execute command
-- vim.tbl_contains() - check if lua table contains a value
-- vim.tbl_deep_extend() -- extend lua table
-- vim.ui.input({ prompt = "Name: " }, function(input) end) -- get input and use it

-- NOTE: Call builtin vim function
-- vim.call(reg_recording)

-- NOTE: Execute function after time:
-- vim.defer_fn(some_func, 500)

-- NOTE: Enter keys as if the user typed them (useful for partial commands):
-- local ctrlc = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
-- vim.api.nvim_feedkeys(ctrlc .. ":'<,'>", "n", false)

local RETHROW = "__tie_rethrow__"

local validate_args = function(descr, args, spec)
  local err_msg = ""

  for k, t in ipairs(spec) do
    local arg_type = type(args[k])

    if type(t) == "string" then
      if arg_type ~= t and t ~= "any" then
        err_msg = string.format("args[%d] must be %s, instead got %s", k, t, arg_type)
      end
    elseif type(t) == "table" then
      local arg_is_valid = false
      local all_types = "{ "

      for _, possible_type in ipairs(t) do
        if arg_type == possible_type or possible_type == "any" then
          arg_is_valid = true
        end

        all_types = string.format([[%s"%s", ]], all_types, possible_type)
      end

      all_types = all_types:gsub(", $", " }")

      if not arg_is_valid then
        err_msg = string.format("args[%d] must be one of %s, instead got %s", k, all_types, arg_type)
      end
    end

    if err_msg ~= "" then
      -- second argument is for the traceback
      error("Spec Error at [" .. descr .. "]: " .. err_msg, 3)
    end
  end
end

local tie = function(descr, spec, on_try, on_catch)
  local val_descr = type(descr) == "string" and descr or "unknown"
  local tie_args = { descr, spec, on_try, on_catch }
  local tie_spec = { "string", "table", "function", { "function", "nil" } }

  -- will throw error if args are invalid
  validate_args(val_descr, tie_args, tie_spec)

  local inner_catch = function(args)
    return function(err)
      local value
      local catch_was_valid = true
      local is_error = false

      -- vim.log.levels.ERROR screws up the message
      vim.notify("Error at [" .. descr .. "]:\n  " .. err, vim.log.levels.WARN)

      if type(on_catch) == "function" then
        local on_catch_args = { descr = descr, err = err, args = args }

        catch_was_valid, value = pcall(on_catch, on_catch_args)
      end

      if value == RETHROW then
        value = "\nWhile calling [" .. descr .. "]:\n  " .. err
        is_error = true
      elseif not catch_was_valid then
        value = "\nWhile catching error for [" .. descr .. "]:\n  " .. value
        is_error = true
      end

      return { value = value, is_error = is_error }
    end
  end

  return function(...)
    local args = {...}

    -- will throw error if args are invalid
    validate_args(descr, args, spec)

    local was_valid, result = xpcall(on_try, inner_catch(args), unpack(args))

    if not was_valid then
      if result.is_error then
        error(result.value, 2)
      else
        return result.value
      end
    end

    return result
  end
end

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
_G.RETHROW = RETHROW
_G.tie = tie
_G.create_map = create_map
_G.create_au = create_au
_G.create_cmd = create_cmd
