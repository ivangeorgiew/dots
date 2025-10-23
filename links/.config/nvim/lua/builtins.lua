-- NOTE: I haven't error-handled all async functions

local tie_table_deep = tie(
  "tie functions nested deep in a table",
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
  tied.do_nothing
)

-- 1. The imported code itself is error-handled
-- 2. Modules from external code have their deeply nested functions tied
local tie_import_func = tie(
  "tie import function",
  --- @param fn_name string
  --- @param orig_fn function
  function(fn_name, orig_fn)
    return tie(
      "tied "..fn_name,
      --- @param path string
      --- @param on_catch function?
      function(path, on_catch)
        on_catch = on_catch or tied.do_rethrow

        local module = tie(
          fn_name.." "..path,
          function() return orig_fn(path) end,
          on_catch
        )()

        if type(module) == "function" then
          module = tie(path, module, tied.do_rethrow)
        elseif type(module) == "table" then
          tie_table_deep(path, module, tied.do_rethrow)
        end

        return module
      end,
      tied.do_rethrow
    )
  end,
  tied.do_rethrow
)
local require = require
_G.require = tie_import_func("require", require)
local dofile = dofile
_G.dofile = tie_import_func("dofile", dofile)

-- Prevents error rethrows
local schedule = vim.schedule
_G.vim.schedule = tie(
  "vim.schedule",
  ---@param fn function
  function(fn)
    local tied_opts = tied.functions[fn]

    if not tied_opts then
      fn = tie("scheduled fn", fn, tied.do_nothing)
    else
      fn = tie(
        tied_opts.desc,
        tied_opts.on_try,
        function(props) tied_opts.on_catch(props) end
      )
    end

    schedule(fn)
  end,
  tied.do_nothing
)

-- Prevents error rethrows
local defer_fn = vim.defer_fn
_G.vim.defer_fn = tie(
  "vim.defer_fn",
  ---@param fn function
  ---@param timeout number
  function(fn, timeout)
    local tied_opts = tied.functions[fn]

    if not tied_opts then
      fn = tie("deferred fn", fn, tied.do_nothing)
    else
      fn = tie(
        tied_opts.desc,
        tied_opts.on_try,
        function(props) tied_opts.on_catch(props) end
      )
    end

    return defer_fn(fn, timeout)
  end,
  tied.do_rethrow
)

-- Handle autocmds
local create_autocmd = vim.api.nvim_create_autocmd
_G.vim.api.nvim_create_autocmd = tie(
  "vim.api.nvim_create_autocmd",
  --- @param events string|table
  --- @param opts table
  function(events, opts)
    if type(opts.group) == "string" then
      -- Create the augroup if it doesn't exist yet
      vim.api.nvim_create_augroup(opts.group, { clear = false })
    end

    if type(opts.callback) == "function" then
      local desc = opts.group and "callback for augroup "..opts.group or "autocmd callback"
      local on_try = opts.callback ---@type function
      local on_catch = function() return true end
      local tied_opts = tied.functions[opts.callback]

      if tied_opts then
        desc = tied_opts.desc
        on_try = tied_opts.on_try
        on_catch = function(props)
          tied_opts.on_catch(props)
          return true
        end
      end

      opts.callback = tie(desc, on_try, on_catch)
    end

    return create_autocmd(events, opts)
  end,
  tied.do_rethrow
)

-- Handle usercmds
local create_usercmd = vim.api.nvim_create_user_command
_G.vim.api.nvim_create_user_command = tie(
  "vim.api.nvim_create_user_command",
  --- @param name string
  --- @param command string|fun(t: table)
  --- @param opts table
  function(name, command, opts)
    if type(command) == "function" then
      local desc = type(opts.desc) == "string" and opts.desc or name
      local on_try = command
      local on_catch = tied.do_nothing
      local tied_opts = tied.functions[command]

      if tied_opts then
        desc = tied_opts.desc
        on_try = tied_opts.on_try
        on_catch = function(props) tied_opts.on_catch(props) end
      end

      command = tie(desc, on_try, on_catch)
    end

   create_usercmd(name, command, opts)
  end,
  tied.do_nothing
)
