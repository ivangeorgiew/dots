create_cmd(
  "Navigate",
  function(t)
    local dir = t.fargs[1]

    -- differing lines for hyprwm implementation
    -- local dirs = { l = "h", r = "l", u = "k", d = "j" }
    -- local vim_dir = dirs[dir]
    -- vim.system({ "hyprctl", "dispatch", "movefocus", dir })

    if vim.fn.winnr(dir) ~= vim.fn.winnr() then
      vim.cmd("wincmd " .. dir)
    else
      local dirs = { h = "left", j = "bottom", k = "top", l = "right" }

      vim.system({ "kitty", "@", "focus-window", "--match", "neighbor:" .. dirs[dir] })
    end
  end,
  { desc = "Navigate between splits", nargs = 1 }
)

create_cmd(
  "Find",
  "execute 'silent grep! <args>' | copen",
  { desc = "Search inside all files", nargs = "+" }
)
