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
      local all_types = ""

      for _, possible_type in ipairs(t) do
        if arg_type == possible_type or possible_type == "any" then
          arg_is_valid = true
          break
        end

        all_types = string.format([[%s%s|]], all_types, possible_type)
      end

      if not arg_is_valid then
        all_types = all_types:gsub("|$", "")

        err_msg = string.format("args[%d] must be %s, instead got %s", k, all_types, arg_type)
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

_G.RETHROW = RETHROW
_G.tie = tie
