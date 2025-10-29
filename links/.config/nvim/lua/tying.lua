_G.tied = {}

-- All functions which are wrapped with `tie()`
tied.functions = {}

-- Indicates to rethow the error if returned in `on_catch`
tied.RETHROW = "__tie_rethrow__"

-- Should be used for functions which must return a value
-- or you don't know how to handle an error (among other possible uses)
tied.do_rethrow = function() return tied.RETHROW end

-- Should be used for functions which return nothing or you
-- don't care if they fail and there is no cleanup
tied.do_nothing = function() end

-- Check if function was called with pcall or xpcall
-- Used in `tie()` to not wrap protected calls
local wrap_prot_call = function(orig_fn)
  return function(...)
    tied.is_pcalled = true
    local results = { orig_fn(...) }
    tied.is_pcalled = false
    return unpack(results)
  end
end
tied.is_pcalled = false
-- No need to rename pcall and xpcall
-- they are automatically called with the local versions in
-- all the code throughout this file
local pcall = pcall
_G.pcall = wrap_prot_call(pcall)
local xpcall = xpcall
_G.xpcall = wrap_prot_call(xpcall)

--- Stringify anything
--- @param arg any
--- @return string
tied.stringify = function(arg)
  local str = ""
  local arg_type = type(arg)

  if arg_type == "table" then
    -- options from https://github.com/kikito/inspect.lua
    str = vim.inspect(arg, { newline = " ", indent = "", depth = 3 })
  elseif arg_type == "string" then
    str = '"'..arg..'"'
  else
    str = tostring(arg)
  end

  if str:len() > 1000 then str = "[large "..arg_type.."]" end

  return str
end

--- @alias on_catch_func fun(props: { desc: string, err: string, args: table }): any

--- Error-handle a function
--- @generic F : function
--- @param desc string
--- @param on_try F
--- @param on_catch on_catch_func
--- @return F
_G.tie = function(desc, on_try, on_catch)
  if tied.functions[on_try] then return on_try end

  local inner_catch = function(...)
    local args = {...}
    local n_args = select("#", ...) -- num of args must be gathered here

    local get_stacktrace = function(ind)
      local stacktrace = ""
      local trace = {}
      local level = 3

      while true do
        local info = debug.getinfo(level, "Sln")

        if not info then break end

        -- Ignore C language functions
        if info.what == "Lua" then
          local source = vim.fn.fnamemodify(info.source:sub(2), ":p:~:.")
          local line = ind..source..":"..info.currentline

          table.insert(trace, line)
        end

        level = level + 1
      end

      if #trace > 0 then
        stacktrace = "Stacktrace:\n" .. table.concat(trace, "\n") .. "\n\n"
      else
        stacktrace = "\n"
      end

      return stacktrace
    end

    local get_args_string = function(ind)
      local args_string = ""

      if n_args > 0 then
        for idx = 1, n_args do
          args_string = args_string .. string.format(ind.."%d) %s\n", idx, tied.stringify(args[idx]))
        end
      else
        args_string = ind.."[no args]\n"
      end

      return args_string
    end

    local get_err_msg = function(err)
      local ind = "  " -- indent for err_msg

      return string.format(
        "Error at:\n"..
        ind.."[%s]\n"..
        "Function args:\n"..
        "%s"..
        "Message:\n"..
        ind.."%s\n"..
        get_stacktrace(ind),
        desc, get_args_string(ind), err
      )
    end

    return function(err)
      local should_rethrow = false
      local err_msg = get_err_msg(err)

      pcall(vim.notify_once, err_msg, vim.log.levels.ERROR)

      ---@type any[]
      local results = { pcall(on_catch, { desc = desc, err = err, args = args }) }
      local catch_was_valid = table.remove(results, 1)

      if results[1] == tied.RETHROW then
        results = { "error while calling: ["..desc.."]" }
        should_rethrow = true
      elseif not catch_was_valid then
        results = { "error in `on_catch` for: ["..desc.."]" }
        should_rethrow = true
      end

      return { should_rethrow, unpack(results) }
    end
  end

  local inner_fn = function(...)
    -- Don't notify or do anything at all when
    -- the function was called from pcall or xpcall
    if tied.is_pcalled then return on_try(...) end

    -- Catch all results, not just the first one
    local on_try_results = { xpcall(on_try, inner_catch(...), ...) } ---@type any[]
    local on_try_was_valid = table.remove(on_try_results, 1)

    if not on_try_was_valid then
      local inner_catch_results = on_try_results[1]
      local should_rethrow = table.remove(inner_catch_results, 1)

      if should_rethrow then
        local err_msg = inner_catch_results[1]

        error(err_msg, 2)
      else
        return unpack(inner_catch_results)
      end
    end

    return unpack(on_try_results)
  end

  tied.functions[inner_fn] = {
    desc = desc,
    on_try = on_try,
    on_catch = on_catch
  }

  return inner_fn
end
