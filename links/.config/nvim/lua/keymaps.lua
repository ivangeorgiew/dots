local function map(modes, lhs, rhs, opts)
  if opts.silent == nil then
    opts.silent = true
  end

  vim.keymap.set(modes, lhs, rhs, opts)
end

map("i", "jk",    "<esc>", { desc = "Exit insert mode" })
map("i", "<C-c>", "<esc>", { desc = "Exit insert mode" })

map({ "n", "x" }, "j",      "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
map({ "n", "x" }, "k",      "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })
map({ "n", "x" }, "<Up>",   "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window",  remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n", "<S-h>",      "<cmd>bprevious<cr>",   { desc = "Prev buffer" })
map("n", "<S-l>",      "<cmd>bnext<cr>",       { desc = "Next buffer" })
map("n", "<leader>`",  "<cmd>b#<cr>",          { desc = "Switch to other buffer" })
map("n", "<leader>d",  "<cmd>bd<cr>",          { desc = "Close current buffer" })
map("n", "<leader>oo", "<cmd>%bd|e#|bd#<cr>",  { desc = "Close all other buffers" })
map("n", "<leader>l",  "<cmd>ls<cr>:b<space>", { desc = "List buffers and open", silent = false })
map("n", "<leader>L",  "<cmd>ls<cr>:bd<space>", { desc = "List buffers and open", silent = false })
map("n", "<leader>e",  ":n<space>",            { desc = "Create/Open files", silent = false })

map("n",          "n", "'Nn'[v:searchforward].'zv'",     { desc = "Next search result", expr = true })
map("n",          "N", "'nN'[v:searchforward].'zv'",     { desc = "Prev search result", expr = true })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]",          { desc = "Next search result", expr = true })
map({ "x", "o" }, "N", "'nN'[v:searchforward]",          { desc = "Prev search result", expr = true })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<C-q>", "<cmd>qa<cr>", { desc = "Quit" })

map("n", "<leader>oj", "o<esc>", { desc = "Make a new line below" })
map("n", "<leader>ok", "O<esc>", { desc = "Make a new line above" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Open Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open Quickfix list" })
map("n", "[q",         "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
map("n", "]q",         "<cmd>cnext<cr>", { desc = "Next quickfix item" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Open Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous error/warning" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next error/warning" })

map("n", "+", "<C-w>5+", { desc = "Increase window size" })
map("n", "_", "<C-w>5-", { desc = "Decrease window size" })

map("n", "<leader>I", "gg=G", { desc = "Reindent whole file" })
map("n", "<leader>Y", "ggyG", { desc = "Copy whole file" })

map("n", "z;", "zA", { desc = "Open fold recursively" })

map("n", "X", "<C-a>", { desc = "Increment number under cursor" })

map({ "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] })
map({ "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] })
map({ "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] })

map("n", "<leader>h", function() vim.o.hls = not vim.o.hls end, { desc = "Toggle highlight search" })
