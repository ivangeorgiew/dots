-- Docs: https://neovim.io/doc/user/lua.html
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

-- Aliases for tied global builtins
tied.create_autocmd = vim.api.nvim_create_autocmd
tied.create_usercmd = vim.api.nvim_create_user_command
tied.ui_input = vim.ui.input
tied.ui_select = vim.ui.select

tied.create_map = tie(
  "create vim keymap",
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

    local isnt_abbrev = type(modes) == "table" or (modes ~= "ca" and modes ~= "!a")

    if opts.silent == nil and isnt_abbrev then
      opts.silent = true
    end

    -- rhs is tied in builtins if function
    vim.keymap.set(modes, lhs, rhs, opts)
  end,
  tied.do_nothing
)

tied.delete_maps = tie(
  "delete vim keymaps",
  --- @param modes string|table
  --- @param commands table
  function(modes, commands)
    vim.validate("modes", modes, { "string", "table", })
    vim.validate("commands", commands, "table")

    for _, lhs in ipairs(commands) do
      -- vim.keymap.del() can fail if the mapping doesn't exist
      -- so use create_map instead
      tied.create_map(modes, lhs, "<nop>", { desc = "Nothing" })
    end
  end,
  tied.do_nothing
)

tied.apply_maps = tie(
  "apply vim keymaps",
  --- @param to_create table?
  --- @param to_delete table?
  function(to_create, to_delete)
    vim.validate("to_create", to_create, "table", true)
    vim.validate("to_delete", to_delete, "table", true)

    -- Order matters, first delete and then create
    if to_delete then
      for _, v in ipairs(to_delete) do
        tied.delete_maps(unpack(v))
      end
    end
    if to_create then
      for _, v in ipairs(to_create) do
        tied.create_map(unpack(v))
      end
    end
  end,
  tied.do_nothing
)

tied.get_files = tie(
  "get files from a folder",
  --- @param opts { path: string, ext: string?, map: function? }
  function(opts)
    vim.validate("opts", opts, "table")
    vim.validate("opts.path", opts.path, "string")
    vim.validate("opts.ext", opts.ext, "string", true)
    vim.validate("opts.map", opts.map, "function", true)

    local entries = {}
    local map = function(file) return file end

    if opts.map then
      map = tie(
        "map file in path: "..opts.path,
        function(file) return opts.map(file) end,
        function(props) return props.args[1] end
      )
    end

    for name, type in vim.fs.dir(opts.path, { depth = math.huge }) do
      if (
        type == "file" and
        (not opts.ext or vim.endswith(name, "."..opts.ext))
      ) then
        table.insert(entries, opts.map and map(name) or name)
      end
    end

    return entries
  end,
  function() return {} end
)

tied.colorscheme_config = tie(
  "configure colorscheme plugin",
  --- @param opts table
  function(_, opts)
    vim.validate("opts", opts, "table")

    require(vim.g.colorscheme).setup(opts)
    vim.cmd("colorscheme "..vim.g.colorscheme)
  end,
  tied.do_nothing
)

tied.get_fold_text = tie(
  "get folded text",
  function()
    local start_line_nr = vim.v.foldstart
    local end_line_nr = vim.v.foldend
    local first_line = vim.fn.getline(start_line_nr)
    local fold_lines_nr = end_line_nr - start_line_nr + 1
    local text = string.format("%s ⮞ [%d lines]", first_line, fold_lines_nr)

    return text
  end,
  function()
    return vim.fn.getline(vim.v.foldstart)
  end
)

-- from LazyVim
tied.on_plugin_load = tie(
  "after a plugin is loaded",
  --- @param plugin_name string
  --- @param on_load function
  function(plugin_name, on_load)
    vim.validate("plugin_name", plugin_name, "string")
    vim.validate("on_load", on_load, "function")

    local lazy_config = require("lazy.core.config")

    if not lazy_config.plugins[plugin_name] then return end

    local is_loaded = lazy_config.plugins[plugin_name]._.loaded
    local on_load_desc = "after loading plugin "..plugin_name

    on_load = tie(on_load_desc, on_load, tied.do_nothing)

    if is_loaded then
      vim.schedule(on_load)
      return
    end

    tied.create_autocmd(
      "User",
      {
        group = on_load_desc,
        pattern = "LazyLoad",
        callback = function(event)
          if event.data == plugin_name then
            vim.schedule(on_load)
            return true -- clear autocmd
          end
        end,
      }
    )
  end,
  tied.do_nothing
)
