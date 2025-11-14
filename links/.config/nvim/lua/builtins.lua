-- NOTE: Add global functions one by one as needed

local tie_deep_table = tie(
  "Tie functions nested deep in a table",
  --- @param tbl_name string
  --- @param tbl table
  --- @param on_catch tie.on_catch
  function(tbl_name, tbl, on_catch)
    vim.validate("tbl_name", tbl_name, "string")
    vim.validate("tbl", tbl, "table")
    vim.validate("on_catch", on_catch, "function")

    local queue = { { tbl, tbl_name } }
    local seen = {} -- filled with traversed tables

    while #queue > 0 do
      local item = table.remove(queue, 1)
      local curr_tbl = item[1]
      local curr_path = item[2]

      -- ignore global vim
      local is_vim_table = curr_path == "vim" or vim.startswith(curr_path, "vim.")

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

    return tbl
  end,
  tied.do_nothing
)

local tie_import_func = tie(
  "Tie an import function",
  --- @param fn_name string
  --- @param orig_fn function
  function(fn_name, orig_fn)
    vim.validate("fn_name", fn_name, "string")
    vim.validate("orig_fn", orig_fn, "function")

    return tie(
      "Tied "..fn_name,
      --- @param path string
      function(path)
        vim.validate("path", path, "string")

        local results = { orig_fn(path) }

        for idx, val in ipairs(results) do
          local desc = path

          if #results > 1 then
            desc = ("%s[%d]"):format(path, idx)
          end

          if type(val) == "function" then
            results[idx] = tie(desc, val, tied.do_rethrow)
          elseif type(val) == "table" then
            results[idx] = tie_deep_table(desc, val, tied.do_rethrow)
          end
        end

        return unpack(results)
      end,
      tied.do_rethrow
    )
  end,
  tied.do_rethrow
)

-- NOTE: Don't wrap the import functions,
-- there are almost no benefits besides somewhat
-- better desc and seeing the function args
-- Can be uncommented in rare debugging cases

-- local require = require
-- _G.require = tie_import_func("require", require)
-- local dofile = dofile
-- _G.dofile = tie_import_func("dofile", dofile)

local overwrite_tied_catch = tie(
  "Overwrite on_catch of tied function",
  ---@param desc string
  ---@param extra_desc string
  ---@param on_try function
  ---@param on_catch tie.on_catch
  function(desc, extra_desc, on_try, on_catch)
    vim.validate("desc", desc, "string")
    vim.validate("extra_desc", extra_desc, "string")
    vim.validate("on_try", on_try, "function")
    vim.validate("on_catch", on_catch, "function")

    local sep = " -> "
    local full_on_catch = on_catch
    local tied_opts = tied.functions[on_try]

    -- Execute on_catch without rethrowing, but still doing cleanup
    if tied_opts and not vim.startswith(tied_opts.desc, desc..sep) then
      extra_desc = tied_opts.desc
      on_try = tied_opts.on_try
      full_on_catch = function(props)
        tied_opts.on_catch(props)
        return on_catch(props)
      end
    end

    if extra_desc == "" then
      extra_desc = tied.NO_DESC
    end

    local full_desc = ("%s%s%s"):format(desc, sep, extra_desc)

    return tie(full_desc, on_try, full_on_catch)
  end,
  tied.do_rethrow
)

local schedule = vim.schedule
_G.vim.schedule = tie(
  "Tied vim.schedule",
  ---@param fn function
  function(fn)
    vim.validate("fn", fn, "function")

    schedule(overwrite_tied_catch("Scheduled", "", fn, tied.do_nothing))
  end,
  tied.do_nothing
)

local defer_fn = vim.defer_fn
_G.vim.defer_fn = tie(
  "Tied vim.defer_fn",
  ---@param fn function
  ---@param timeout number
  function(fn, timeout)
    vim.validate("fn", fn, "function")
    vim.validate("timeout", timeout, "number")

    return defer_fn(overwrite_tied_catch("Deferred", "", fn, tied.do_nothing), timeout)
  end,
  tied.do_rethrow
)

local create_autocmd = vim.api.nvim_create_autocmd
_G.vim.api.nvim_create_autocmd = tie(
  "Tied vim.api.nvim_create_autocmd",
  --- @param event string|string[]
  --- @param opts vim.api.keyset.create_autocmd
  --- @return integer
  function(event, opts)
    vim.validate("event", event, { "string", "table" })
    vim.validate("opts", opts, "table")

    if type(opts.callback) == "function" then
      local desc = "Autocmd"
      local extra_desc = ""

      if opts.desc then
        extra_desc = opts.desc ---@type string
      elseif type(event) == "string" then
        extra_desc = "for events: " .. event
      elseif type(event) == "table" then
        extra_desc = "for events: " .. table.concat(event, ", ")
      end

      opts.callback = overwrite_tied_catch(
        desc,
        extra_desc,
        opts.callback --[[@as function]],
        function(props)
          local autocmd_id = props.args[1].id
          vim.api.nvim_del_autocmd(autocmd_id)
        end
      )
    end

    return create_autocmd(event, opts)
  end,
  tied.do_rethrow
)

local create_usercmd = vim.api.nvim_create_user_command
_G.vim.api.nvim_create_user_command = tie(
  "Tied vim.api.nvim_create_user_command",
  --- @param name string
  --- @param command string|fun(args: vim.api.keyset.create_user_command.command_args)
  --- @param opts vim.api.keyset.user_command
  function(name, command, opts)
    vim.validate("name", name, "string")
    vim.validate("command", command, { "string", "function" })
    vim.validate("opts", opts, "table")

    if type(command) == "function" then
      command = overwrite_tied_catch(
        "Usercmd",
        opts.desc or name,
        command,
        function() vim.api.nvim_del_user_command(name) end
      )
    end

    create_usercmd(name, command, opts)
  end,
  tied.do_nothing
)

local create_map = vim.keymap.set
_G.vim.keymap.set = tie(
  "Tied vim.keymap.set",
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
      local desc = "Keymap -> " .. (opts.desc or tied.NO_DESC)
      rhs = tie(desc, rhs, tied.do_nothing)
    end

    create_map(modes, lhs, rhs, opts)
  end,
  tied.do_nothing
)

local ui_input = vim.ui.input
_G.vim.ui.input = tie(
  "Tied vim.ui.input",
  --- @param opts table?
  --- @param on_confirm function
  function(opts, on_confirm)
    vim.validate('opts', opts, 'table', true)
    vim.validate('on_confirm', on_confirm, 'function')

    local desc = "After UI input with prompt: "

    if opts and type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "_none_"
    end

    ui_input(opts, vim.schedule_wrap(tie(desc, on_confirm, tied.do_nothing)))
  end,
  tied.do_nothing
)

local ui_select = vim.ui.select
_G.vim.ui.select = tie(
  "Tied vim.ui.select",
  --- @generic T
  --- @param items T[]
  --- @param opts table?
  --- @param on_choice fun(item: T?, idx: integer?)
  function(items, opts, on_choice)
    vim.validate('items', items, 'table')
    vim.validate('on_choice', on_choice, 'function')

    local desc = "After UI selection with prompt: "

    if opts and type(opts.prompt) == "string" then
      desc = desc .. opts.prompt
    else
      desc = desc .. "_none_"
    end

    ui_select(items, opts, vim.schedule_wrap(tie(desc, on_choice, tied.do_nothing)))
  end,
  tied.do_nothing
)

local set_hl = vim.api.nvim_set_hl
_G.vim.api.nvim_set_hl = tie(
  "Tied vim.api.nvim_set_hl",
  --- @param ns_id integer
  --- @param name string
  --- @param val vim.api.keyset.highlight
  function(ns_id, name, val)
    vim.validate("ns_id", ns_id, "number")
    vim.validate("name", name, "string")
    vim.validate("val", val, "table")

    set_hl(ns_id, name, val)
  end,
  tied.do_nothing
)
