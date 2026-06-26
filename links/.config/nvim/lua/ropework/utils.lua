-- NOTE: Coding guide for nvim development -> :h dev
-- NOTE: Docs: https://neovim.io/doc/user/lua.html https://neovim.io/doc/user/lua-guide
-- NOTE: Useful API:
-- vim.g - set or get global variable
-- vim.o or vim.opt - set option
-- vim.notify() - better print
-- vim.cmd() - execute command
-- vim.tbl_contains() - check if lua table contains a value
-- vim.tbl_deep_extend() - extend lua table
-- vim.schedule(some_func) - execute function async
-- vim.fn.some_func() - call any builtin vim function

-- NOTE: Enter keys as if the user typed them (useful for partial commands):
-- local ctrlc = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
-- vim.api.nvim_feedkeys(ctrlc .. ":'<,'>", "n", false)

-- Aliases for tied global builtins
tied.create_usercmd = vim.api.nvim_create_user_command
tied.ui_input = vim.ui.input
tied.ui_select = vim.ui.select
tied.set_hl = vim.api.nvim_set_hl

local foreach = tie(
  "Create for-each wrapper",
  ---@param is_list boolean
  function(is_list)
    vim.validate("is_list", is_list, "boolean")

    return tie(
      is_list and "For-each in list" or "For-each in table",
      --- Use this function when one iteration shouldn't
      --- prevent other iterations from trying to execute
      ---@generic T
      ---@param desc string
      ---@param iter T[]|table|function
      ---@param on_try fun(key: any, val: T)
      function(desc, iter, on_try)
        vim.validate("desc", desc, "string")
        vim.validate("iter", iter, { "table", "function" })
        vim.validate("on_try", on_try, "function")

        local fn = tie(
          ("For-each in %s -> %s"):format(is_list and "list" or "table", desc),
          on_try,
          tied.do_nothing
        )

        if type(iter) == "table" then
          local create = is_list and ipairs or pairs

          for key, val in create(iter) do
            fn(key, val)
          end
        else
          for key, val in iter do
            fn(key, val)
          end
        end
      end,
      tied.do_nothing
    )
  end,
  tied.do_rethrow
)
tied.for_list = foreach(true)
tied.for_table = foreach(false)

tied.do_block = tie(
  "Execute tied code block",
  --- Useful when a block of code is a separate logic,
  --- but there is no point in moving it to a function
  --- @param desc string
  --- @param on_try function
  --- @param on_catch tie.on_catch?
  function(desc, on_try, on_catch)
    vim.validate("desc", desc, "string")
    vim.validate("on_try", on_try, "function")
    vim.validate("on_catch", on_catch, "function", true)

    tie(desc, on_try, on_catch or tied.do_nothing)()
  end,
  tied.do_nothing
)

tied.create_map = tie(
  "Create vim keymap",
  --- @param modes string|string[]
  --- @param lhs string
  --- @param rhs string|function
  --- @param opts vim.keymap.set.Opts?
  function(modes, lhs, rhs, opts)
    vim.validate("modes", modes, { "string", "table" })
    vim.validate("lhs", lhs, "string")
    vim.validate("rhs", rhs, { "string", "function" })
    vim.validate("opts", opts, "table")

    opts = opts or {}

    local isnt_abbrev = (
      type(modes) == "table" or (modes ~= "ca" and modes ~= "!a")
    )

    if opts.silent == nil and isnt_abbrev then
      opts.silent = true
    end

    -- rhs is tied in builtins if function
    vim.keymap.set(modes, lhs, rhs, opts)
  end,
  tied.do_nothing
)

tied.delete_map = tie(
  "Delete vim keymap",
  --- @param lhs string
  --- @param modes string|string[]
  --- @param opts table?
  function(modes, lhs, opts)
    vim.validate("lhs", lhs, "string")
    vim.validate("modes", modes, { "string", "table" })
    vim.validate("opts", opts, "table", true)

    opts = opts or {}

    local ok = pcall(vim.keymap.del, modes, lhs, opts)

    if not ok then
      opts.desc = "Nothing"

      tied.create_map(modes, lhs, "<nop>", opts)
    end
  end,
  tied.do_nothing
)

tied.dir = tie(
  "Traverse a directory and return item names",
  --- @param opts tied.dir.opts
  function(opts)
    vim.validate("opts", opts, "table")
    vim.validate("opts.path", opts.path, "string")
    vim.validate("opts.type", opts.type, "string")
    vim.validate("opts.ext", opts.ext, "string", true)
    vim.validate("opts.depth", opts.depth, "number", true)
    vim.validate("opts.map", opts.map, "function", true)

    local entries = {}
    local item_type = opts.type ---@type string

    if opts.type == "dir" then
      item_type = "directory"
    end

    local map = tie(
      ("Traverse a dir -> Map %s name"):format(item_type),
      function(name)
        if opts.map then
          return opts.map(name)
        else
          return name
        end
      end,
      tied.do_nothing
    )

    for name, type in vim.fs.dir(opts.path, { depth = opts.depth or math.huge }) do
      local matches_ext = not opts.ext or vim.endswith(name, opts.ext)

      if type == item_type and matches_ext then
        local entry = map(name)

        if entry ~= nil then
          table.insert(entries, entry)
        end
      end
    end

    return entries
  end,
  function() return {} end
)

tied.colorscheme_config = tie(
  "Configure colorscheme plugin",
  --- @param opts table
  function(opts)
    vim.validate("opts", opts, "table")

    require(vim.g.colorscheme).setup(opts)
    vim.cmd("colorscheme " .. vim.g.colorscheme)
  end,
  tied.do_nothing
)

tied.foldtext = tie("Tied vim.o.foldtext", function()
  local start_line_nr = vim.v.foldstart
  local first_line = vim.fn.getline(start_line_nr)
  -- local end_line_nr = vim.v.foldend
  -- local fold_lines_nr = end_line_nr - start_line_nr + 1

  return first_line:gsub("^(%s*)", "%1⮞ ")
  -- return string.format(" ⮞  %s [%d lines]", first_line, fold_lines_nr)
end, function() return vim.fn.getline(vim.v.foldstart) end)

tied.create_augroup = tie(
  "Create augroup",
  --- @param name string
  --- @param clear boolean
  --- @return integer?
  function(name, clear)
    vim.validate("name", name, "string")
    vim.validate("clear", clear, "boolean")

    return vim.api.nvim_create_augroup(name, { clear = clear })
  end,
  tied.do_nothing
)

tied.create_autocmd = tie(
  "Create autocmd",
  --- @param opts tied.create_autocmd.opts
  --- @return integer?
  function(opts)
    vim.validate("opts", opts, "table")
    vim.validate("opts.desc", opts.desc, "string")
    vim.validate("opts.event", opts.event, { "string", "table" })

    local event = opts.event

    opts.event = nil

    return vim.api.nvim_create_autocmd(event, opts)
  end,
  tied.do_nothing
)

tied.check_if_buf_is_file = tie(
  "Check if a buffer is a file",
  ---@param bufnr number
  ---@return boolean
  function(bufnr)
    vim.validate("bufnr", bufnr, "number")

    if not vim.api.nvim_buf_is_valid(bufnr) then
      return false
    end

    local buf_name = vim.api.nvim_buf_get_name(bufnr)

    return vim.bo[bufnr].buftype == "" and buf_name ~= ""
  end,
  tied.do_rethrow
)

tied.manage_session = tie(
  "Load or save a vim session",
  --- @param should_load boolean
  function(should_load)
    vim.validate("should_load", should_load, "boolean")

    -- TODO: handle git repos like in
    -- https://github.com/ruicsh/nvim-config/blob/main/plugin/custom/sessions.lua
    local cwd = (
      vim.fn.fnamemodify(vim.fn.getcwd(), ":p:~"):gsub("[:\\/%s.]", "_")
    )
    local ses_dir = vim.fn.stdpath("data") .. "/sessions"
    local ses_file = vim.fn.fnameescape(("%s/%s.vim"):format(ses_dir, cwd))

    if not vim.uv.fs_stat(ses_dir) then
      vim.fn.mkdir(ses_dir, "p")
    end

    if should_load and vim.fn.filereadable(ses_file) == 1 then
      tied.for_list(
        "Close floating window",
        vim.api.nvim_list_wins(),
        function(_, winnr)
          local config = vim.api.nvim_win_get_config(winnr)

          if config.relative ~= "" then
            vim.api.nvim_win_close(winnr, true)
          end
        end
      )

      vim.cmd("source " .. ses_file)
    end

    if not should_load then
      local has_opened_files = false

      tied.for_list(
        "Close non-file window before session save",
        vim.api.nvim_list_wins(),
        function(_, winnr)
          local bufnr = vim.api.nvim_win_get_buf(winnr)

          if not tied.check_if_buf_is_file(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
          else
            has_opened_files = true
          end
        end
      )

      if has_opened_files then
        vim.cmd("mks! " .. ses_file)
      end
    end
  end,
  tied.do_nothing
)

tied.do_keys_in_win = tie(
  "Feed normal mode keys in a vim window",
  ---@param winnr number
  ---@param keys string
  ---@param fallback boolean|string|nil
  ---@return boolean
  function(winnr, keys, fallback)
    vim.validate("winnr", winnr, "number")
    vim.validate("keys", keys, "string")
    vim.validate("fallback", fallback, { "boolean", "string" }, true)

    local feed_keys = tie("Feed normal mode keys", function()
      keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
      vim.cmd("normal! " .. keys)
    end, tied.do_nothing)

    if not vim.api.nvim_win_is_valid(winnr) then
      if fallback then
        keys = type(fallback) == "string" and fallback or keys
        feed_keys()
      end

      return false
    else
      vim.api.nvim_win_call(winnr, feed_keys)

      return true
    end
  end,
  function() return false end
)

tied.switch_bool = tie("Switch boolean under cursor", function()
  local word = vim.fn.expand("<cword>")
  ---@type [string, string][]
  local bools = {
    { "true", "false" },
    { "TRUE", "FALSE" },
    { "True", "False" },
    { "yes", "no" },
    { "on", "off" },
    { "1", "0" },
  }

  for _, pair in ipairs(bools) do
    local pair_idx

    if word == pair[1] then
      pair_idx = 1
    elseif word == pair[2] then
      pair_idx = 2
    end

    if pair_idx ~= nil then
      vim.cmd("normal! mslb")

      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local search = pair[pair_idx]
      local replace = pair[2 * (1 / pair_idx)]

      vim.cmd(("silent! s/\\%%%dc%s/%s/"):format(col, search, replace))
      vim.cmd("normal! g`s")
      vim.cmd("nohls")

      return
    end
  end
end, tied.do_nothing)

tied.paste_word_list = tie("Paste word list", function()
  tied.ui_select(
    { "With commas", "On new lines" },
    { prompt = "How to paste?" },
    function(_, choice_idx)
      if not choice_idx then
        return
      end

      vim.cmd([[normal! "cp]])

      local on_new_lines = choice_idx == 2

      if on_new_lines then
        vim.cmd([[normal! ^ms]])
        vim.cmd([[silent s/, /\r/g | nohls]])
        vim.cmd([[normal! Vg`s=]])
      else
      end
    end
  )
end, tied.do_nothing)

-- Use this when you want to create a fn that is called after a timeout,
-- but to stops all other fn calls if they were done during the same time
tied.debounce_wrap = tie(
  "Create a function which is debounced",
  --- @param desc string
  --- @param ms number
  --- @param callback function
  --- @return function
  function(desc, ms, callback)
    vim.validate("desc", desc, "string")
    vim.validate("ms", ms, "number")
    vim.validate("callback", callback, "function")

    local timer = assert(vim.uv.new_timer())
    local tied_fn = vim.schedule_wrap(tie(desc, callback, tied.do_nothing))

    return tie("Start debounce timer", function(...)
      local args = vim.F.pack_len(...)
      local after = tie("After debounce", function()
        timer:stop()
        tied_fn(vim.F.unpack_len(args))
      end, tied.do_nothing)

      -- Return nil on purpose
      timer:start(ms, 0, after)
    end, tied.do_nothing)
  end,
  tied.do_rethrow
)

-- Use this if you want to call a fn after a timeout once.
-- Multiple calls aren't blocked like in the debounce variant
tied.set_timeout = tie(
  "Call a function after timeout",
  --- @param desc string
  --- @param ms number
  --- @param callback function
  --- @return uv.uv_timer_t?
  function(desc, ms, callback)
    vim.validate("desc", desc, "string")
    vim.validate("ms", ms, "number")
    vim.validate("callback", callback, "function")

    -- It uses vim.uv.new_timer() and vim.schedule()
    return vim.defer_fn(tie(desc, callback, tied.do_nothing), ms)
  end,
  tied.do_nothing
)

tied.set_interval = tie(
  "Call a function after each interval",
  --- @param desc string
  --- @param ms number
  --- @param callback function
  --- @return uv.uv_timer_t?
  function(desc, ms, callback)
    vim.validate("desc", desc, "string")
    vim.validate("ms", ms, "number")
    vim.validate("callback", callback, "function")

    local timer = assert(vim.uv.new_timer())
    local tied_fn = vim.schedule_wrap(tie(desc, callback, tied.do_nothing))

    timer:start(ms, ms, tied_fn)

    return timer
  end,
  tied.do_nothing
)

tied.clear_interval = tie(
  "Stop a function that is called on interval",
  --- @param timer uv.uv_timer_t
  function(timer)
    vim.validate("timer", timer, "table")

    timer:stop()

    if not timer:is_closing() then
      timer:close()
    end
  end,
  tied.do_nothing
)

tied.set_exec_time = tie(
  "Set execution time",
  ---@param name string
  ---@param should_init boolean?
  function(name, should_init)
    vim.validate("name", name, "string")
    vim.validate("should_init", should_init, "boolean", true)

    local time = vim.g.time_table

    if should_init or not time[name] then
      time[name] = vim.uv.hrtime()
    elseif type(time[name]) == "number" then
      time[name] = 1e-6 * (vim.uv.hrtime() - time[name])
    end

    vim.g.time_table = time
  end,
  tied.do_nothing
)

tied.show_exec_times = tie("Show execution times", function()
  local times = {}

  tied.for_table(
    "Convert time to string",
    vim.g.time_table,
    function(name, time)
      table.insert(times, ("%s time: %.2f ms"):format(name, time))
    end
  )

  vim.notify(
    table.concat(times, "\n"),
    vim.log.levels.INFO,
    { title = "Execution Time" }
  )
end, tied.do_nothing)

tied.set_lsp_features = tie(
  "Set LSP features",
  ---@param client_id number?
  ---@param features lsp_features
  function(client_id, features)
    vim.validate("client_id", client_id, "number", true)
    vim.validate("features", features, "table")

    tied.for_table("Set LSP feature", features, function(feature, should_enable)
      if feature == "formatting" then
        if client_id and not should_enable then
          local client = vim.lsp.get_client_by_id(client_id)

          if client then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
        end
      else
        local enable = vim.tbl_get(vim.lsp, feature, "enable")

        assert(type(enable) == "function", "No such LSP feature")
        enable(should_enable, { client_id = client_id })
      end
    end)
  end,
  tied.do_nothing
)

tied.replace_text = tie("Replace text in files", function()
  assert(vim.bo.filetype == "qf", "Must be ran in quckfix/loclist")

  tied.ui_input({ prompt = "Search for: " }, function(search)
    if not search then
      return
    end

    tied.ui_input({ prompt = "Replace with: " }, function(replace)
      if not replace then
        return
      end

      tied.ui_select(
        { "Yes, but only full words", "Yes, any occurance", "No" },
        { prompt = ("Replace `%s` with `%s` ?"):format(search, replace) },
        function(choice)
          if type(choice) ~= "string" then
            return
          end

          if choice:match("full words") then
            search = ("\\<%s\\>"):format(search)
          end

          if choice:match("Yes") then
            vim.cmd(
              ("%s %%sno@%s@%s@gIe | update"):format(
                "silent noautocmd keepjumps keepalt cfdo",
                search,
                replace
              )
            )
            vim.cmd("cfirst | cclose")
          end
        end
      )
    end)
  end)
end, tied.do_nothing)

tied.lsp_on_list = tie(
  "Implement vim.lsp.ListOpts on_list",
  ---@param opts vim.lsp.LocationOpts.OnList
  function(opts)
    -- Don't bother with vim.ui.input on single result
    -- Instead always open quickfix
    vim.fn.setqflist({}, " ", { title = opts.title, items = opts.items })
    vim.cmd("botright copen")
  end,
  tied.do_nothing
)

tied.run_codeaction = tie(
  "Run LSP codeaction",
  ---@param opts tied.run_codeaction.opts
  function(opts)
    vim.validate("opts", opts, "table", true)

    vim.lsp.buf.code_action({
      apply = opts.apply,
      filter = tie(
        "Filter codeactions",
        ---@param x lsp.CodeAction|lsp.Command
        ---@param client_id integer
        function(x, client_id)
          local client = vim.lsp.get_client_by_id(client_id) or {}

          -- stylua: ignore start
          local is_correct_client = not opts.client_name or opts.client_name == client.name
          local is_correct_command = not opts.command or x.command == opts.command
          local is_correct_title = not opts.title or (x.title or ""):match(opts.title)
          -- stylua: ignore end

          local is_correct = 1
            and is_correct_client
            and is_correct_command
            and is_correct_title

          if opts.debug and is_correct then
            vim.print(x)
            return false
          end

          return is_correct
        end,
        function() return false end
      ),
    })
  end,
  tied.do_nothing
)
