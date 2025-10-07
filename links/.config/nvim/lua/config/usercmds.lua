local M = {}
local create_cmd = tied.create_cmd
local ui_input = tied.ui_input
local ui_select = tied.ui_select

M.setup = tie(
  "setup usercmds",
  function()
    create_cmd(
      "Navigate",
      function(t)
        local vim_dir = t.fargs[1]
        local kitty_dirs = { h = "left", l = "right", j = "bottom", k = "top" }

        if vim.fn.winnr(vim_dir) ~= vim.fn.winnr() then
          vim.cmd("wincmd " .. vim_dir)
        else
          vim.system({ "kitty", "@", "focus-window", "--match", "neighbor:" .. kitty_dirs[vim_dir] })
        end
      end,
      { desc = "Navigate between splits", nargs = 1 }
    )

    create_cmd(
      "Find",
      "execute 'silent lgrep! <args>' | lopen",
      { desc = "Find in all files", nargs = "+" }
    )

    create_cmd(
      "Replace",
      function(opts)
        ui_input({ prompt = "Search for: " }, function(search)
          ui_input({ prompt = "Replace with: " }, function(replace)
            if type(search) ~= "string" or type(replace) ~= "string" then return end

            ui_select(
              { "Yes, but only full words", "Yes, any occurance", "No" },
              { prompt = "Replace `"..search.."` with `"..replace.."` ?" },
              function(choice)
                if type(choice) ~= "string" then return end

                if choice:match("full words") then
                  search = "\\<"..search.."\\>"
                end

                if choice:match("Yes") then
                  -- case sensitive and ignore not found errors
                  vim.cmd("silent lfdo %sno@"..search .."@"..replace.."@gIe | update | lclose")
                end
              end
            )
          end)
        end)
      end,
      { desc = "Replace text in files", nargs = 0 }
    )
  end,
  do_nothing
)

return M
