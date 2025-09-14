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
  "execute 'silent grep! <args>' | copen",
  { desc = "Search inside all files", nargs = "+" }
)
