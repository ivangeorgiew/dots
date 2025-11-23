local M = {}

M.setup = tie("Setup usercmds", function()
  tied.each_i(
    M.config,
    "Queue usercmd to create",
    function(_, usercmd) tied.create_usercmd(unpack(usercmd)) end
  )
end, tied.do_nothing)

---@class UserCmdParams
---@field [1] string
---@field [2] string|fun(args: vim.api.keyset.create_user_command.command_args)
---@field [3] vim.api.keyset.user_command

---@type UserCmdParams[]
M.config = {
  {
    "Navigate",
    function(opts)
      local vim_dir = opts.fargs[1]
      local kitty_dirs = { h = "left", l = "right", j = "bottom", k = "top" }

      if vim.fn.winnr(vim_dir) ~= vim.fn.winnr() then
        vim.cmd("wincmd " .. vim_dir)
      else
        vim.system({
          "kitty",
          "@",
          "focus-window",
          "--match",
          "neighbor:" .. kitty_dirs[vim_dir],
        })
      end
    end,
    { desc = "Navigate between splits", nargs = 1 },
  },
  {
    "Find",
    "execute('silent lgrep! ' .. <q-args>) | lopen",
    { desc = "Find in all files", nargs = "+" },
  },
  {
    "Replace",
    function()
      local is_loclist = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist
        == 1

      if not is_loclist then
        vim.notify(
          "This command needs to be executed in a loclist!",
          vim.log.levels.WARN
        )
        return
      end

      tied.ui_input({ prompt = "Search for: " }, function(search)
        if type(search) ~= "string" then
          return
        end

        tied.ui_input({ prompt = "Replace with: " }, function(replace)
          if type(replace) ~= "string" then
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
                -- Commands are executed in each list item (buffer)
                -- Prevent warnings/issues with the subcommands
                -- :h cdo
                vim.cmd(
                  ("%s %%sno@%s@%s@gIe | update | bdelete"):format(
                    "silent noautocmd keepjumps keepalt lfdo",
                    search,
                    replace
                  )
                )
                vim.cmd("llast | lclose")
              end
            end
          )
        end)
      end)
    end,
    { desc = "Replace text in files", nargs = 0 },
  },
}

return M
