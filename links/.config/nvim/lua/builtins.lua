-- NOTE: I haven't error-handled all async functions

local tie_table_deep = tie(
  "tie functions nested deep in a table",
  --- @param tbl_name string
  --- @param tbl table
  --- @param on_catch on_catch_func
  function(tbl_name, tbl, on_catch)
    local queue = { { tbl, tbl_name } }
    local seen = {} -- filled with traversed tables

    while #queue > 0 do
      local item = table.remove(queue, 1)
      local curr_tbl = item[1]
      local curr_path = item[2]

      -- ignore global vim
      local is_vim_table = curr_path == "vim" or curr_path:find("^vim%.")

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
      --- @param on_catch on_catch_func
      function(path, on_catch)
        on_catch = on_catch or tied.do_rethrow

        local module = tie(
          fn_name.." "..path,
          function() return orig_fn(path) end,
          on_catch
        )()

        if type(module) == "function" then
          module = tie(path, module, tied.do_rethrow)
        -- NOTE: Add on a case by case basis instead
        -- elseif type(module) == "table" then
        --   tie_table_deep(path, module, tied.do_rethrow)
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

local modify_tied_fn = tie(
  "modify tied function if needed",
  ---@param desc string
  ---@param on_try function
  ---@param on_catch on_catch_func
  function(desc, on_try, on_catch)
    local tied_opts = tied.functions[on_try]

    -- Execute on_catch without rethrowing, but still doing cleanup
    if tied_opts and not vim.startswith(tied_opts.desc, desc) then
      return tie(
        desc .. " -> " .. tied_opts.desc,
        tied_opts.on_try, --- @type function
        function(props)
          tied_opts.on_catch(props)
          return on_catch(props)
        end
      )
    end

    return tie(desc, on_try, on_catch)
  end,
  tied.do_rethrow
)

local schedule = vim.schedule
_G.vim.schedule = tie(
  "vim.schedule",
  ---@param fn function
  function(fn)
    schedule(modify_tied_fn("scheduled fn", fn, tied.do_nothing))
  end,
  tied.do_nothing
)

local defer_fn = vim.defer_fn
_G.vim.defer_fn = tie(
  "vim.defer_fn",
  ---@param fn function
  ---@param timeout number
  function(fn, timeout)
    return defer_fn(modify_tied_fn("deferred fn", fn, tied.do_nothing), timeout)
  end,
  tied.do_rethrow
)

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
      local desc = "autocmd callback"

      if opts.group then
        desc = "callback for augroup: " .. tostring(opts.group)
      end

      opts.callback = modify_tied_fn(desc, opts.callback, function() return true end)
    end

    return create_autocmd(events, opts)
  end,
  tied.do_rethrow
)

local create_usercmd = vim.api.nvim_create_user_command
_G.vim.api.nvim_create_user_command = tie(
  "vim.api.nvim_create_user_command",
  --- @param name string
  --- @param command string|fun(t: table)
  --- @param opts table
  function(name, command, opts)
    if type(command) == "function" then
      local desc = type(opts.desc) == "string" and opts.desc or name

      command = tie(desc, command, tied.do_nothing)
    end

   create_usercmd(name, command, opts)
  end,
  tied.do_nothing
)
