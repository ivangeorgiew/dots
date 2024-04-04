local tie = require("utils").tie
local map = require("utils").map

-- delete mappings

map("n", "Z", "<nop>", { desc = "Nothing" })
map("n", "ZZ", "<nop>", { desc = "Nothing" })

-- mappings

map("i", "<C-c>", "<esc>", { desc = "Exit insert mode" })

map({ "n" }, "DD", "dd", { desc = "Cut line" })
map({ "n" }, "dd", [["_dd]],  { desc = "Delete line" })
map({ "n", "v" }, "D", "d", { desc = "Cut" })
map({ "n", "v" }, "d", [["_d]],  { desc = "Delete" })
map({ "n", "v" }, "s", [["_s]],  { desc = "Substitute" })
map({ "n", "v" }, "c", [["_c]],  { desc = "Change" })
map({ "n", "v" }, "x", [["_x]],  { desc = "Delete character" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window",  remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

map("n", "<C-d>", "20jzz", { desc = "Move screen down" })
map("n", "<C-u>", "20kzz", { desc = "Move screen up" })

map("n", "<S-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<S-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<S-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n", "<C-Up>",   "<cmd>m -2<cr>==",      { desc = "Move selected lines up"   })
map("n", "<C-Down>", "<cmd>m +1<cr>==",      { desc = "Move selected lines down" })
map("v", "<C-Up>",   "<cmd>m '<-2<cr>gv=gv", { desc = "Move selected lines up"   })
map("v", "<C-Down>", "<cmd>m '>+1<cr>gv=gv", { desc = "Move selected lines down" })

map("n",          "n", "'Nn'[v:searchforward].'zv'",     { desc = "Next search result", expr = true })
map("n",          "N", "'nN'[v:searchforward].'zv'",     { desc = "Prev search result", expr = true })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]",          { desc = "Next search result", expr = true })
map({ "x", "o" }, "N", "'nN'[v:searchforward]",          { desc = "Prev search result", expr = true })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

map("n", "<leader>q",  "<cmd>qa<cr>",       { desc = "Quit" })
map("n", "<leader>d",  "<cmd>close<cr>",    { desc = "Close window" })
map("n", "<leader>t",  "<cmd>tabclose<cr>", { desc = "Close tab" })

map("n", "[q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "]q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
map("n", "[l", "<cmd>lnext<cr>", { desc = "Next location item" })
map("n", "]l", "<cmd>lprev<cr>", { desc = "Previous location item" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous error/warning" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next error/warning" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Open Diagnostics" })

map("n", "<leader>I", "gg=G", { desc = "Reindent whole file" })
map("n", "<leader>Y", "ggyG", { desc = "Copy whole file" })

map("n", "z;", "zA", { desc = "Open fold recursively" })

map("n", "X", "<C-a>", { desc = "Increment number under cursor" })

map({ "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] })
map({ "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] })
map({ "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] })

map("n", "<leader>l", "<cmd>let @/ = ''<cr>", { desc = "Clear last search" })
map("n", "<leader>h", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle line wrap" })

map("c", "<C-a>", "<Home>",    { desc = "Go to the beginning", silent = false })
map("c", "<C-b>", "<S-Left>",  { desc = "Go a word to the left", silent = false })
map("c", "<C-f>", "<S-Right>", { desc = "Go a word to the right", silent = false })
map("c", "<C-h>", "<Left>",    { desc = "Go left", silent = false })
map("c", "<C-l>", "<Right>",   { desc = "Go right", silent = false })

map("n", "<leader>1", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle diff mode" })
map("n", "du", "<cmd>diffupdate<cr>", { desc = "Update diff" })

map("i", "<C-e>",  "<C-r>*", { desc = "Paste in insert mode" })

map("n", "m", "<cmd>set hls<cr>*", { desc = "Go to next occurance of the word" })
map("n", "M", "<cmd>set hls<cr>#", { desc = "Go to prev occurance of the word" })

map({ "n", "v" }, "<cr>", "empty(&buftype) ? '<cmd>normal @e<cr>' : '<cr>'", { desc = "Apply macro", expr = true })

map("v", "$", "g_", { desc = "Go until end of line" })

map("n", "Q", "q", { desc = "Start/end macro" })

map("n", "<S-h>", "gT", { desc = "Switch to left tab" })
map("n", "<S-l>", "gt", { desc = "Switch to right tab" })
map("n", "<leader><S-h>", "<cmd>tabm -1<cr>", { desc = "Move tab to the left" })
map("n", "<leader><S-l>", "<cmd>tabm +1<cr>", { desc = "Move tab to the right" })

map("n", "<leader>o", "<cmd>only<cr>",  { desc = "Leave only the current window" })

map("n", "zj", "o<esc>k", { desc = "Make a new line below" })
map("n", "zk", "O<esc>j", { desc = "Make a new line above" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace word under cursor", silent = false })
map("v", "<leader>s", [["ay:%s/<C-r>a/<C-r>a/gI<Left><Left><Left>]],          { desc = "Search and replace visual selection",  silent = false })

-- abbreviations

map("ca", "te", "tabe", { silent = false })
map("ca", "vs", "vsplit", { silent = false })

map("!a", "teh", "the", { silent = false })
map("!a", "cosnt", "const", { silent = false })
map("!a", "prosp", "props", { silent = false })
