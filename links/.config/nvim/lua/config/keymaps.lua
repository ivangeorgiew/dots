local map = function(modes, lhs, rhs, opts)
  if opts.silent == nil then
    opts.silent = true
  end

  vim.keymap.set(modes, lhs, rhs, opts)
end

local toggle_diff = function()
  if vim.o.diff then
    vim.cmd("windo diffoff")
  else
    vim.cmd("windo diffthis")
  end
end

map("i", "jk",    "<esc>", { desc = "Exit insert mode" })
map("i", "<C-c>", "<esc>", { desc = "Exit insert mode" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window",  remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n",          "n", "'Nn'[v:searchforward].'zv'",     { desc = "Next search result", expr = true })
map("n",          "N", "'nN'[v:searchforward].'zv'",     { desc = "Prev search result", expr = true })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]",          { desc = "Next search result", expr = true })
map({ "x", "o" }, "N", "'nN'[v:searchforward]",          { desc = "Prev search result", expr = true })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

map("n", "<leader>q",  "<cmd>qa<cr>",       { desc = "Quit" })
map("n", "<leader>d",  "<cmd>close<cr>",    { desc = "Close window" })
map("n", "<leader>t",  "<cmd>tabclose<cr>", { desc = "Close tab" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Open Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open Quickfix list" })
map("n", "[q",         "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
map("n", "]q",         "<cmd>cnext<cr>", { desc = "Next quickfix item" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Open Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous error/warning" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next error/warning" })

map("n", "<leader>I", "gg=G", { desc = "Reindent whole file" })
map("n", "<leader>Y", "ggyG", { desc = "Copy whole file" })

map("n", "z;", "zA", { desc = "Open fold recursively" })

map("n", "X", "<C-a>", { desc = "Increment number under cursor" })

map({ "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] })
map({ "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] })
map({ "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] })

map("n", "<leader>l", function() vim.o.hls = not vim.o.hls end, { desc = "Toggle highlight search" })
map("n", "<leader>h", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle line wrap" })

map("c", "<C-a>", "<Home>",    { desc = "Go to the beginning" })
map("c", "<C-j>", "<S-Left>",  { desc = "Go a word to the left" })
map("c", "<C-k>", "<S-Right>", { desc = "Go a word to the right" })
map("c", "<C-h>", "<Left>",    { desc = "Go left" })
map("c", "<C-l>", "<Right>",   { desc = "Go right" })

map("n", "<leader>1", toggle_diff, { desc = "Toggle diff mode" })
map("n", "du",  "<cmd>diffupdate<cr>", { desc = "Update diff" })

map("i", "<C-e>",  "<C-r>*", { desc = "Paste in insert mode" })

map("n", "m", "*", { desc = "Go to next occurance of the word" })

map({ "n", "v" }, "<cr>", "empty(&buftype) ? ':normal @e<cr>' : '<cr>'", { desc = "Apply macro", expr = true })

map("v", "$", "g_", { desc = "Go until end of line" })

map("n", "Q", "q", { desc = "Start/end macro" }) -- for buffers where q is bound to something

map("n", "<S-h>", "gT", { desc = "Switch to left tab" })
map("n", "<S-l>", "gt", { desc = "Switch to right tab" })
map("n", "<leader><S-h>", "<cmd>tabm -1<cr>", { desc = "Move tab to the left" })
map("n", "<leader><S-l>", "<cmd>tabm +1<cr>", { desc = "Move tab to the right" })

map("n", "<leader>o", "<cmd>only<cr>",  { desc = "Leave only the current window" })

map("n", "<leader>j", "o<esc>", { desc = "Make a new line below" })
map("n", "<leader>k", "O<esc>", { desc = "Make a new line above" })

vim.cmd("ca te tabe")
vim.cmd("ca vs vsplit")
vim.cmd("ab teh the")
vim.cmd("ab cosnt const")
vim.cmd("ab prosp props")
