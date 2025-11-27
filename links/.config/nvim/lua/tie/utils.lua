-- NOTE: Coding guide for nvim development -> :h dev
-- NOTE: Docs:
-- https://neovim.io/doc/user/lua.html
-- https://neovim.io/doc/user/lua-guide
-- NOTE: Useful API:
-- vim.g - set or get global variable
-- vim.o or vim.opt - set option
-- vim.notify() - better print
-- vim.cmd() - execute command
-- vim.tbl_contains() - check if lua table contains a value
-- vim.tbl_deep_extend() - extend lua table
-- vim.schedule(some_func) - execute function async
-- vim.defer_fn(some_func, 500) - execute function after specified time
-- vim.fn.some_func() - call any builtin vim function

-- NOTE: Enter keys as if the user typed them (useful for partial commands):
-- local ctrlc = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
-- vim.api.nvim_feedkeys(ctrlc .. ":'<,'>", "n", false)

tied.LazyEvent = { "User FilePost", "VeryLazy" }

-- Aliases for tied global builtins
tied.create_usercmd = vim.api.nvim_create_user_command
tied.ui_input = vim.ui.input
tied.ui_select = vim.ui.select
tied.set_hl = vim.api.nvim_set_hl

local foreach = tie(
  "For-each wrapper",
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
tied.each_i = foreach(true)
tied.each = foreach(false)

tied.do_block = tie(
  "Execute tied code block",
  --- Useful when a block of code is a separate logic,
  --- but there is no point in moving it to a function
  ---@param desc string
  ---@param on_try function
  function(desc, on_try)
    vim.validate("desc", desc, "string")
    vim.validate("on_try", on_try, "function")

    tie(desc, on_try, tied.do_nothing)()
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
  --- @param opts TiedDirOpts
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
      local matches_ext = not opts.ext or vim.endswith(name, "." .. opts.ext)

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
  function(_, opts)
    vim.validate("opts", opts, "table")

    require(vim.g.colorscheme).setup(opts)
    vim.cmd("colorscheme " .. vim.g.colorscheme)
    vim.cmd("syntax off") -- use treesitter instead
  end,
  tied.do_nothing
)

tied.foldtext = tie("Tied vim.o.foldtext", function()
  local start_line_nr = vim.v.foldstart
  local end_line_nr = vim.v.foldend
  local first_line = vim.fn.getline(start_line_nr)
  local fold_lines_nr = end_line_nr - start_line_nr + 1
  local text = string.format("%s ⮞ [%d lines]", first_line, fold_lines_nr)

  return text
end, function() return vim.fn.getline(vim.v.foldstart) end)

tied.has_plugin = tie(
  "Check if a plugin exists",
  ---@param required string
  ---@return boolean
  ---@return LazyPlugin?
  function(required)
    vim.validate("required", required, "string")

    local plugin = require("lazy.core.config").plugins[required]

    if plugin then
      return true, plugin
    else
      return false
    end
  end,
  function() return false end
)

-- From LazyVim
tied.on_plugin_load = tie(
  "Run code if a plugin is loaded",
  --- @param required string|string[]
  --- @param desc string
  --- @param on_load fun(plugins: table)
  function(required, desc, on_load)
    vim.validate("required", required, { "string", "table" })
    vim.validate("desc", desc, "string")
    vim.validate("on_load", on_load, "function")

    on_load = vim.schedule_wrap(tie(desc, on_load, tied.do_nothing))

    local lazy_plugins = require("lazy.core.config").plugins
    local plugins_loaded = {}
    local plugin_names = type(required) == "string" and { required } or required --[[@as string[] ]]

    for _, name in ipairs(plugin_names) do
      plugins_loaded[name] = false

      if lazy_plugins[name] and lazy_plugins[name]._.loaded then
        plugins_loaded[name] = true
      end
    end

    if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
      on_load(lazy_plugins)
    else
      tied.create_autocmd({
        desc = "On plugin load -> " .. desc,
        event = "User",
        -- Don't clear autocmds for the group
        group = tied.create_augroup("my.on_plugin_load", false),
        pattern = "LazyLoad",
        callback = function(e)
          if vim.list_contains(vim.tbl_keys(plugins_loaded), e.data) then
            plugins_loaded[e.data] = true
          end

          if not vim.list_contains(vim.tbl_values(plugins_loaded), false) then
            on_load(lazy_plugins)
            return true -- clear autocmd
          end
        end,
      })
    end
  end,
  tied.do_nothing
)

tied.create_augroup = tie(
  "Create augroup",
  --- @param name string
  --- @param clear boolean
  --- @return integer
  function(name, clear)
    vim.validate("name", name, "string")
    vim.validate("clear", clear, "boolean")

    return vim.api.nvim_create_augroup(name, { clear = clear })
  end,
  tied.do_rethrow
)

---@class MyAutocmdOpts : vim.api.keyset.create_autocmd
---@field desc string
---@field event string|string[]

tied.create_autocmd = tie(
  "Create autocmd",
  --- @param opts MyAutocmdOpts
  --- @return integer
  function(opts)
    vim.validate("opts", opts, "table")
    vim.validate("opts.desc", opts.desc, "string")
    vim.validate("opts.event", opts.event, { "string", "table" })

    local event = opts.event

    opts.event = nil

    return vim.api.nvim_create_autocmd(event, opts)
  end,
  tied.do_rethrow
)

tied.check_if_buf_is_file = tie(
  "Check if a buffer is an opened file",
  ---@param bufnr number
  ---@return boolean
  function(bufnr)
    vim.validate("bufnr", bufnr, "number")

    if not vim.api.nvim_buf_is_loaded(bufnr) then
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
      tied.each_i(
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
      tied.each_i(
        "Close non-file window before session save",
        vim.api.nvim_list_wins(),
        function(_, winnr)
          local bufnr = vim.api.nvim_win_get_buf(winnr)

          if not tied.check_if_buf_is_file(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
          end
        end
      )

      vim.cmd("mks! " .. ses_file)
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

    local feed_keys = function()
      keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
      vim.cmd("normal! " .. keys)
    end

    if not vim.api.nvim_win_is_valid(winnr) then
      if fallback then
        keys = type(fallback) == "string" and fallback or keys
        feed_keys()
      end

      return false
    end

    vim.api.nvim_win_call(winnr, feed_keys)

    return true
  end,
  function() return false end
)

-- Can be used as lazy_plugin.init
tied.add_module = tie(
  "Add lazy plugin as lua_ls library",
  function(plugin) require("lsp.lua_ls").extra.add_library(plugin.name) end,
  tied.do_nothing
)
