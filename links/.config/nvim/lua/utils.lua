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
      vim.notify("Issue at [" .. descr .. "]: " .. err, vim.log.levels.ERROR)

      if type(on_catch) == "function" then
        return on_catch(err, args)
      end
    end
  end

  return function(...)
    local args = {...}

    -- will throw error if args are invalid
    validate_args(descr, args, spec)

    local _, result = xpcall(on_try, inner_catch(args), unpack(args))

    return result;
  end
end

-- substitute print() with the customisable vim.notify()
_G._print = _G.print
_G.print = tie(
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
  function(e, args)
    _print(unpack(args))
  end
)

-- don't substitute error(), because you lose the traceback
-- and function termination functionality

local map = tie(
  "create mapping",
  { { "string", "table" }, "string", { "string", "function" }, "table" },
  function(modes, lhs, rhs, opts)
    -- too lazy to write out spec for args right now

    if opts.silent == nil then
      opts.silent = true
    end

    if type(rhs) == "function" and opts.should_tie ~= false then
      rhs = tie(opts.desc, {}, rhs)
    end

    vim.keymap.set(modes, lhs, rhs, opts)
  end
)

local au = tie(
  "create augroup",
  { "string", { "string", "table" }, "table"},
  function(group_name, events, opts)
    opts.group = vim.api.nvim_create_augroup(group_name, { clear = true })

    if type(opts.callback) == "function" and opts.should_tie ~= false then
      -- type `:h nvim_create_autocmd` to see all the args for `callback`
      opts.callback = tie(group_name, { "table" }, opts.callback)
    end

    vim.api.nvim_create_autocmd(events, opts)
  end
)

local create_cmd = tie(
  "create user command",
  { "string", { "string", "function" }, "table"},
  function(name, command, opts)
    if type(command) == "function" and opts.should_tie ~= false then
      local desc = name

      if type(opts.desc == "string") then desc = opts.desc end

      command = tie(desc, {}, command)
    end

    if opts.should_tie ~= nil then opts.should_tie = nil end

    vim.api.nvim_create_user_command(name, command, opts)
  end
)

local M = {}

M.tie = tie
M.map = map
M.au = au
M.create_cmd = create_cmd
M.uv = vim.uv or vim.loop

return M
