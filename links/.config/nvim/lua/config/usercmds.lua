local M = {}

M.setup = tie(
  "setup usercmds",
  function()
    tied.create_usercmd(
      "Navigate",
      function(opts)
        local vim_dir = opts.fargs[1]
        local kitty_dirs = { h = "left", l = "right", j = "bottom", k = "top" }

        if vim.fn.winnr(vim_dir) ~= vim.fn.winnr() then
          vim.cmd("wincmd " .. vim_dir)
        else
          vim.system({ "kitty", "@", "focus-window", "--match", "neighbor:" .. kitty_dirs[vim_dir] })
        end
      end,
      { desc = "Navigate between splits", nargs = 1 }
    )

    tied.create_usercmd(
      "Find",
      "execute('silent lgrep! ' .. <q-args>) | lopen",
      { desc = "Find in all files", nargs = "+" }
    )

    tied.create_usercmd(
      "Replace",
      function()
        local is_loclist = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 1

        if not is_loclist then
          vim.notify("This command needs to be executed in a loclist!", vim.log.levels.WARN)
          return
        end

        tied.ui_input({ prompt = "Search for: " }, function(search)
          if type(search) ~= "string" then return end

          tied.ui_input({ prompt = "Replace with: " }, function(replace)
            if type(replace) ~= "string" then return end

            tied.ui_select(
              { "Yes, but only full words", "Yes, any occurance", "No" },
              { prompt = "Replace `"..search.."` with `"..replace.."` ?" },
              function(choice)
                if type(choice) ~= "string" then return end

                if choice:find("full words") then
                  search = "\\<"..search.."\\>"
                end

                if choice:find("Yes") then
                  -- Commands are executed in each list item (buffer)
                  -- Prevent warnings/issues with the subcommands
                  -- :h cdo
                  local multicmd = "silent noautocmd keepjumps keepalt lfdo"

                  vim.cmd(multicmd.." %sno@"..search .."@"..replace.."@gIe | update | bdelete")
                  vim.cmd("llast | lclose")
                end
              end
            )
          end)
        end)
      end,
      { desc = "Replace text in files", nargs = 0 }
    )
  end,
  tied.do_nothing
)

return M
