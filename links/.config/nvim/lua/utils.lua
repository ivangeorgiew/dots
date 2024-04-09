local validate_args = function(descr, params, spec)
  local err_msg = ""

  for k, t in ipairs(spec) do
    local arg_type = type(params[k])

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

local tie = function (descr, spec, on_try, on_catch)
  local val_descr = type(descr) == "string" and descr or "unknown"

  validate_args(val_descr, { descr, spec, on_try, on_catch }, { "string", "table", "function", { "function", "nil" } })

  local inner_catch = function(params)
    return function(err)
      print("Issue at [" .. descr .. "]: " .. err)

      if type(on_catch) == "function" then
        return on_catch(err, params)
      end
    end
  end

  return function(...)
    local params = {...}
    local u = unpack

    validate_args(descr, params, spec)

    local _, result = xpcall(on_try, inner_catch(params), u(params))

    return result;
  end
end

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
