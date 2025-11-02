-- NOTE: I haven't error-handled all async functions

-- 1. The imported code itself is error-handled
-- 2. Modules from external code have their deeply nested functions tied
local tie_import_func = tie(
  "tie import function",
  --- @param fn_name string
  --- @param orig_fn function
  function(fn_name, orig_fn)
    vim.validate("fn_name", fn_name, "string")
    vim.validate("orig_fn", orig_fn, "function")

    return tie(
      fn_name,
      --- @param path string
      function(path)
        vim.validate("path", path, "string")

        local results = { orig_fn(path) }

        -- NOTE: Don't handle functions nested into module table
        -- or functions passed as arguments to other functions

        for idx, val in ipairs(results) do
          if type(val) == "function" then
            results[idx] = tie(path, val, tied.do_rethrow)
          end
        end

        return unpack(results)
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
    vim.validate("desc", desc, "string")
    vim.validate("on_try", on_try, "function")
    vim.validate("on_catch", on_catch, "function")

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
    vim.validate("fn", fn, "function")

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
    vim.validate("fn", fn, "function")
    vim.validate("timeout", timeout, "number")

    return defer_fn(modify_tied_fn("deferred fn", fn, tied.do_nothing), timeout)
  end,
  tied.do_rethrow
)

local create_autocmd = vim.api.nvim_create_autocmd
_G.vim.api.nvim_create_autocmd = tie(
  "vim.api.nvim_create_autocmd",
  --- @param events any
  --- @param opts vim.api.keyset.create_autocmd
  function(events, opts)
    vim.validate("opts", opts, "table")

    if type(opts.group) == "string" then
      -- Create the augroup if it doesn't exist yet
      ---@diagnostic disable-next-line: param-type-mismatch
      vim.api.nvim_create_augroup(opts.group, { clear = false })
    end

    if type(opts.callback) == "function" then
      local desc = "autocmd callback"

      if opts.group then
        desc = "callback for augroup: " .. tostring(opts.group)
      end

      ---@diagnostic disable-next-line: param-type-mismatch
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
  --- @param command string|fun(args: vim.api.keyset.create_user_command.command_args)
  --- @param opts vim.api.keyset.user_command
  function(name, command, opts)
    vim.validate("name", name, "string")
    vim.validate("command", command, { "string", "function" })
    vim.validate("opts", opts, "table")

    if type(command) == "function" then
      local desc = type(opts.desc) == "string" and opts.desc or name

      command = tie(desc, command, tied.do_nothing)
    end

    create_usercmd(name, command, opts)
  end,
  tied.do_nothing
)

local create_map = vim.keymap.set
_G.vim.keymap.set = tie(
  "vim.keymap.set",
  --- @param modes string|string[]
  --- @param lhs string
  --- @param rhs string|function
  --- @param opts vim.keymap.set.Opts?
  function(modes, lhs, rhs, opts)
    vim.validate("modes", modes, { "string", "table" })
    vim.validate("lhs", lhs, "string")
    vim.validate("rhs", rhs, { "string", "function" })
    vim.validate("opts", opts, "table", true)

    opts = opts or {}

    if type(rhs) == "function" then
      local desc = opts.desc and "keymap -> "..opts.desc or "rhs of keymap"
      rhs = tie(desc, rhs, tied.do_nothing)
    end

    create_map(modes, lhs, rhs, opts)
  end,
  tied.do_nothing
)

local ui_input = vim.ui.input
_G.vim.ui.input = tie(
  "create ui for input",
  --- @param opts table?
  --- @param on_confirm function
  function(opts, on_confirm)
    vim.validate('opts', opts, 'table', true)
    vim.validate('on_confirm', on_confirm, 'function')

    local desc = "after UI input with prompt: "

    if opts and type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "none"
    end

    ui_input(opts, vim.schedule_wrap(tie(desc, on_confirm, tied.do_nothing)))
  end,
  tied.do_nothing
)

local ui_select = vim.ui.select
_G.vim.ui.select = tie(
  "create ui for selection",
  --- @generic T
  --- @param items T[]
  --- @param opts table?
  --- @param on_choice fun(item: T?, idx: integer?)
  function(items, opts, on_choice)
    vim.validate('items', items, 'table')
    vim.validate('on_choice', on_choice, 'function')

    local desc = "after UI selection with prompt: "

    if opts and type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "none"
    end

    ui_select(items, opts, vim.schedule_wrap(tie(desc, on_choice, tied.do_nothing)))
  end,
  tied.do_nothing
)

