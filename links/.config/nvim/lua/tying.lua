-- Should be used for functions which must return a value
-- or you don't know how to handle an error (among other possible uses)
_G.RETHROW = "__tie_rethrow__"
_G.do_rethrow = function() return RETHROW end

-- Should be used for functions which return nothing or you
-- don't care if they fail and there is no cleanup
_G.NOTHING = "__tie_nothing__"
_G.do_nothing = function() return NOTHING end

-- Stringify anything
--- @param arg any
--- @return string
_G.stringify = function(arg)
  if type(arg) == "table" then
    -- options from https://github.com/kikito/inspect.lua
    local str = vim.inspect(arg, { newline = " ", indent = "", depth = 3 })

    if string.len(str) > 1000 then
      return "{...}"
    else
      return str
    end
  else
    return type(arg) == "string" and '"'..arg..'"' or tostring(arg)
  end
end

-- Error handle a function
--- @param desc string
--- @param on_try fun(...: any): any
--- @param on_catch fun(props: { desc: string, err: string, args: table }): any
--- @return fun(...: any): any
_G.tie = function(desc, on_try, on_catch)
  local inner_catch = function(...)
    local args = {...}
    local n_args = select("#", ...) -- num of args must be gathered here

    return function(err)
      local is_error = false
      local ind = "  " -- indent for err_msg
      local args_string = ""

      if n_args > 0 then
        for idx = 1, n_args do
          args_string = args_string .. string.format(ind.."%d) %s\n", idx, stringify(args[idx]))
        end
      else
        args_string = ind.."[no args]\n"
      end

      local err_msg = string.format(
        "Error at:\n"..
        ind.."[%s]\n"..
        "Function args:\n"..
        "%s"..
        "Message:\n"..
        ind.."%s\n\n",
        desc, args_string, err
      )

      pcall(vim.notify, err_msg, vim.log.levels.ERROR)

      local catch_was_valid, value = pcall(on_catch, { desc = desc, err = err, args = args })

      if value == RETHROW then
        value = "error while calling: ["..desc.."]"
        is_error = true
      elseif not catch_was_valid then
        value = "error in `on_catch` for: ["..desc.."]"
        is_error = true
      end

      return { value = value, is_error = is_error }
    end
  end

  return function(...)
    local was_valid, result = xpcall(on_try, inner_catch(...), ...)

    if not was_valid then -- on_try failed
      if result.is_error then -- rethrow or on_catch failed
        error(result.value, 2)
      else -- value from on_catch call
        return result.value
      end
    end

    return result
  end
end
