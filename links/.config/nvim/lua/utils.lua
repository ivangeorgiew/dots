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
      local result, catch_was_valid
      local is_res_err = false

      if type(on_catch) == "function" then
        catch_was_valid, result = pcall(on_catch, err, args)
      end

      if result == RETHROW then
        result = "\nWhile calling [" .. descr .. "]:\n  " .. err
        is_res_err = true
      else
        vim.notify("Error at [" .. descr .. "]:\n  " .. err, vim.log.levels.ERROR)

        if not catch_was_valid then
          result = "\nWhile catching error for [" .. descr .. "]:\n  " .. result
          is_res_err = true
        end
      end

      return { value = result, is_res_err = is_res_err }
    end
  end

  return function(...)
    local args = {...}

    -- will throw error if args are invalid
    validate_args(descr, args, spec)

    local was_valid, result = xpcall(on_try, inner_catch(args), unpack(args))

    if not was_valid then
      if result.is_res_err then
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
  function(e, args)
    _print(unpack(args))
  end
)

local table_extend = tie(
  "extend table",
  { "table", "table" },
  function(a, b) return vim.tbl_deep_extend("force", a, b) end,
  function() return RETHROW end
)

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

    if opts.should_tie ~= nil then opts.should_tie = nil end

    vim.keymap.set(modes, lhs, rhs, opts)
  end
)

local create_au = tie(
  "create augroup",
  { "string", { "string", "table" }, "table"},
  function(group_name, events, opts)
    opts.group = vim.api.nvim_create_augroup(group_name, { clear = true })

    if type(opts.callback) == "function" and opts.should_tie ~= false then
      -- type `:h nvim_create_autocmd` to see all the args for `callback`
      opts.callback = tie(group_name, { "table" }, opts.callback)
    end

    if opts.should_tie ~= nil then opts.should_tie = nil end

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

      command = tie(desc, { "table" }, command)
    end

    if opts.should_tie ~= nil then opts.should_tie = nil end

    vim.api.nvim_create_user_command(name, command, opts)
  end
)

_G._print = _G.print
_G.print = local_print
_G.table_extend = table_extend
_G.RETHROW = RETHROW

local M = {}

M.tie = tie
M.map = map
M.create_au = create_au
M.create_cmd = create_cmd
M.uv = vim.uv or vim.loop

return M
