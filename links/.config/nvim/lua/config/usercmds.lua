local create_cmd = require("utils").create_cmd

create_cmd(
  "Navigate",
  function(t)
    local dir = t.fargs[1]
    local dirs = { l = "h", r = "l", u = "k", d = "j" }
    local vim_dir = dirs[dir]

    if vim.fn.winnr(vim_dir) ~= vim.fn.winnr() then
      vim.cmd("wincmd " .. vim_dir)
    else
      --local dirs = { h = "left", j = "bottom", k = "top", l = "right" }
      --vim.fn.system({ "kitty", "@", "--to=$KITTY_LISTEN_ON", "kitten", "navigate_kitty.py", dirs[dir] })
      vim.fn.system({ "hyprctl", "dispatch", "movefocus", dir })
    end
  end,
  { desc = "Navigate between splits", nargs = 1 }
)

create_cmd(
  "Find",
  "execute 'silent grep! <args>' | copen",
  { desc = "Search inside all files", nargs = "+" }
)
