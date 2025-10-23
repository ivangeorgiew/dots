-- All functions which are wrapped with `tie()`
_G.tied_functions = {}

-- Indicates to rethow the error if returned in `on_catch`
_G.RETHROW = "__tie_rethrow__"

-- Should be used for functions which must return a value
-- or you don't know how to handle an error (among other possible uses)
_G.do_rethrow = function() return RETHROW end

-- Should be used for functions which return nothing or you
-- don't care if they fail and there is no cleanup
_G.do_nothing = function() end

-- Check if function was called with pcall or xpcall
-- Used in `tie()` to not wrap protected calls
_G.is_pcalled = false
local wrap_prot_call = function(orig_fn)
  return function(...)
    _G.is_pcalled = true
    local results = { orig_fn(...) }
    _G.is_pcalled = false
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

-- Stringify anything
--- @param arg any
--- @return string
_G.stringify = function(arg)
  if type(arg) == "table" then
    -- options from https://github.com/kikito/inspect.lua
    local str = vim.inspect(arg, { newline = " ", indent = "", depth = 3 })

    if str:len() > 1000 then
      return "{...}"
    else
      return str
    end
  else
    return type(arg) == "string" and '"'..arg..'"' or tostring(arg)
  end
end

-- Error handle a function
--- @generic F : function
--- @param desc string
--- @param on_try F
--- @param on_catch fun(props: { desc: string, err: string, args: table }): any
--- @return F
_G.tie = function(desc, on_try, on_catch)
  if tied_functions[on_try] then return on_try end

  local inner_catch = function(...)
    local args = {...}
    local n_args = select("#", ...) -- num of args must be gathered here

    return function(err)
      local should_rethrow = false
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

      pcall(vim.notify_once, err_msg, vim.log.levels.ERROR)

      ---@type any[]
      local results = { pcall(on_catch, { desc = desc, err = err, args = args }) }
      local catch_was_valid = table.remove(results, 1)

      if results[1] == RETHROW then
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
    if _G.is_pcalled then return on_try(...) end

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

  tied_functions[inner_fn] = { desc, on_try, on_catch }

  return inner_fn
end

local tie_table_deep = tie(
  "tie_table_deep",
  --- @param tbl_name string
  --- @param tbl table
  --- @param on_catch function
  function(tbl_name, tbl, on_catch)
    local queue = { { tbl, tbl_name } }
    local seen = {} -- filled with traversed tables

    while #queue > 0 do
      local item = table.remove(queue, 1)
      local curr_tbl = item[1]
      local curr_path = item[2]

      -- ignore global vim
      local is_vim_table = curr_path == "vim" or curr_path:match("^vim%.")

      if not seen[curr_tbl] and not is_vim_table then
        seen[curr_tbl] = true

        for key, val in pairs(curr_tbl) do
          local val_type = type(val)
          local full_path = curr_path .. "." .. tostring(key)

          if val_type == "function" then
            curr_tbl[key] = tie(full_path, val, on_catch)
          elseif val_type == "table" then
            queue[#queue + 1] = { val, full_path }
          end
        end
      end
    end
  end,
  do_nothing
)

local tie_import_func = tie(
  "tie_import_func",
  --- @param fn_name string
  --- @param orig_fn function
  function(fn_name, orig_fn)
    return tie(
      "tied "..fn_name,
      --- @param path string
      --- @param on_catch function?
      function(path, on_catch)
        on_catch = on_catch or do_rethrow

        local module = tie(
          "require "..path,
          function() return orig_fn(path) end,
          on_catch
        )()

        if type(module) == "function" then
          module = tie(path, module, do_rethrow)
        elseif type(module) == "table" then
          tie_table_deep(path, module, do_rethrow)
        end

        return module
      end,
      do_rethrow
    )
  end,
  do_rethrow
)

-- Setup global import functions
-- 1. The required code itself is error-handled and
-- 2. Modules from external code have their deeply nested functions tied
local require = require
_G.require = tie_import_func("require", require)
local dofile = dofile
_G.dofile = tie_import_func("dofile", dofile)
