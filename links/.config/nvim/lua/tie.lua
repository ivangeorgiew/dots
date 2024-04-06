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
      error(err_msg, 4)
    end
  end
end

local tie = function (descr, spec, on_try, on_catch)
  local val_descr = type(descr) == "string" and descr or "unknown"

  validate_args(val_descr, { descr, spec, on_try, on_catch }, { "string", "table", "function", { "function", "nil" } })

  local catch = function(valid_args, params)
    return function(err)
      local err_msg_start = valid_args and "Error in" or "Spec Error for"

      print(err_msg_start .. " [" .. descr .. "]: " .. err)

      if type(on_catch) == "function" then
        return on_catch(err, valid_args, params)
      end
    end
  end

  return function(...)
    local params = {...}
    local u = unpack

    local is_valid = xpcall(validate_args, catch(false, u(params)), descr, params, spec)

    if is_valid then
      local _, result = xpcall(on_try, catch(true, u(params)), u(params))

      return result;
    end
  end
end

return tie
