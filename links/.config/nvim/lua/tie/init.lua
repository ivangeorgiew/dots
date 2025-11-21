_G.tied = {}

-- All functions which are wrapped with `tie()`
-- Keep weak references in order to be able to garbage collect
tied.functions = setmetatable({}, { __mode = "k" })

-- Indicates to rethow the error if returned in `on_catch`
tied.RETHROW = "<rethrow error>"

-- When no meaningful description can be provided
tied.NO_DESC = "<no desc>"

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

-- No need to rename pcall and xpcall
-- they are automatically called with the local versions in
-- all the code throughout this file
local pcall = pcall
_G.pcall = wrap_prot_call(pcall)
local xpcall = xpcall
_G.xpcall = wrap_prot_call(xpcall)

local notifs = {} --- @type table<string,boolean>

--- @param err_msg string
--- @param hash string
local print_err = function(err_msg, hash)
  vim.validate("err_msg", err_msg, "string")

  -- Different hash and logic from vim.notify_once
  -- Remove after timeout and use desc+err for hash
  if not notifs[hash] then
    local seconds = 60 * 1e3

    vim.notify(err_msg, vim.log.levels.ERROR)
    notifs[hash] = true
    vim.defer_fn(function() notifs[hash] = nil end, seconds)
  end
end

---@param err string
local print_inner_err = function(err)
  vim.validate("err", err, "string")

  local desc = "inner error-handling"

  print_err(("Error in %s:%s\n\n"):format(desc, err), desc .. err)
end

--- Stringify anything
--- @param arg any
--- @return string
local stringify = function(arg)
  local str = ""
  local arg_type = type(arg)

  if arg_type == "table" then
    -- options from https://github.com/kikito/inspect.lua
    str = vim.inspect(arg, { newline = " ", indent = "", depth = 3 })
  elseif arg_type == "string" then
    str = ('"%s"'):format(arg):gsub("\n", "\\n")
  else
    str = tostring(arg)
  end

  if str:len() > 1000 then
    str = ("<large %s>"):format(arg_type)
  end

  return str
end

--- Create a pretty error string and log it
--- @param desc string
--- @param err string
--- @param args table
--- @param n_args number
local log_error = function(desc, err, args, n_args)
  vim.validate("desc", desc, "string")
  vim.validate("err", err, "string")
  vim.validate("args", args, "table")
  vim.validate("n_args", n_args, "number")

  local ok, inner_err = true, nil
  local ind = "  "
  local args_string = ""
  local stacktrace = ""

  -- Stringify args
  ---@type boolean, unknown
  ok, inner_err = pcall(function()
    if n_args > 0 then
      local lines = {}

      for idx = 1, n_args do
        lines[#lines + 1] = ("%s%d) %s"):format(ind, idx, stringify(args[idx]))
      end

      args_string = table.concat(lines, "\n")
    else
      args_string = ind .. "<no args>"
    end
  end)
  if not ok then
    print_inner_err(inner_err)
  end

  -- Gather stacktrace
  ---@type boolean, unknown
  ok, inner_err = pcall(function()
    local level = 7
    local lines = {}

    while #lines < 10 do
      local info = debug.getinfo(level, "Sln")

      if not info then
        break
      end

      if info and info.what == "Lua" then
        local source = vim.fn.fnamemodify(info.source:sub(2), ":p:~")
        local line = ("%s- %s:%d"):format(ind, source, info.currentline)

        if info.name and info.namewhat then
          line = ("%s _in_ **%s** %s"):format(line, info.namewhat, info.name)
        end

        lines[#lines + 1] = line
      end

      level = level + 1
    end

    stacktrace = table.concat(lines, "\n")
  end)
  if not ok then
    print_inner_err(inner_err)
  end

  -- Print error message
  ---@type boolean, unknown
  ok, inner_err = pcall(function()
    local l = {
      "Error at:",
      ("%s<%s>"):format(ind, desc),
    }

    if args_string ~= "" then
      l[#l + 1] = "Function args:"
      l[#l + 1] = args_string
    end

    l[#l + 1] = "Message:"
    l[#l + 1] = ind .. err

    if stacktrace ~= "" then
      l[#l + 1] = "Stacktrace:"
      l[#l + 1] = stacktrace
    end

    l[#l + 1] = "\n"

    print_err(table.concat(l, "\n"), desc .. err)
  end)
  if not ok then
    print_inner_err(inner_err)
  end
end

--- @alias tie.on_catch fun(props: { desc: string, err: string, args: table }): any

--- Error-handle a function
--- @generic F : function
--- @param desc string
--- @param on_try F
--- @param on_catch tie.on_catch
--- @return F
_G.tie = function(desc, on_try, on_catch)
  vim.validate("desc", desc, "string")
  vim.validate("on_try", on_try, "function")
  vim.validate("on_catch", on_catch, "function")

  if tied.functions[on_try] then
    return on_try
  end

  local inner_catch = function(...)
    local args = { ... }
    local n_args = select("#", ...) -- num of args must be gathered here

    return function(err)
      local should_rethrow, results = false, {}
      local ok, inner_err = true, nil

      -- Actual on_catch call and error logging
      ---@type boolean, unknown
      ok, inner_err = pcall(function()
        log_error(desc, err, args, n_args)

        local on_catch_results =
          { pcall(on_catch, { desc = desc, err = err, args = args }) }
        local on_catch_was_valid = table.remove(on_catch_results, 1)

        if on_catch_results[1] == tied.RETHROW then
          on_catch_results = { ("error while calling: <%s>"):format(desc) }
          should_rethrow = true
        elseif not on_catch_was_valid then
          on_catch_results = { ("error in `on_catch` for: <%s>"):format(desc) }
          should_rethrow = true
        end

        results = on_catch_results
      end)

      if not ok then
        print_inner_err(inner_err)
        should_rethrow = true

        return { should_rethrow, inner_err }
      end

      return { should_rethrow, unpack(results) }
    end
  end

  local inner_fn = function(...)
    -- Do nothing extra when the function
    -- was called from pcall/xpcall and it rethrows the error
    if tied.is_pcalled and on_catch == tied.do_rethrow then
      return on_try(...)
    end

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
    on_catch = on_catch,
  }

  return inner_fn
end

require("tie.builtins") -- replace some global builtins
require("tie.utils") -- add global utils
