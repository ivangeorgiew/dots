local tie = require("utils").tie
local map = require("utils").map

-- no need to use tie(), map() already does it
local toggle_search_high = function()
  local curr_search = vim.fn.getreg("/")

  if type(vim.g.prev_search) ~= "string" then
    vim.g.prev_search = ""
  end

  if curr_search == "" then
    vim.fn.setreg("/", vim.g.prev_search)
  else
    vim.fn.setreg("/", "")
  end

  vim.g.prev_search = curr_search
end

-- delete mappings

map("n", "Z", "<nop>", { desc = "Nothing" })
map("n", "ZZ", "<nop>", { desc = "Nothing" })

-- mappings

map("i", "<C-c>", "<esc>", { desc = "Exit insert mode" })

-- TODO: add keymap for restarting neovim with current session

-- TODO: remove the below mappings when plugin is added

map("n", "DD", "dd", { desc = "Cut line" })
map("n", "dd", [["_dd]],  { desc = "Delete line" })
map({ "n", "v" }, "D", "d", { desc = "Cut" })
map({ "n", "v" }, "d", [["_d]],  { desc = "Delete" })
map({ "n", "v" }, "s", [["_s]],  { desc = "Substitute" })
map({ "n", "v" }, "c", [["_c]],  { desc = "Change" })
map({ "n", "v" }, "x", [["_x]],  { desc = "Delete character" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to left split"  })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })

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

map("n", "<leader>pq", "<cmd>cprev<cr>", { desc = "Prev Quickfix item" })
map("n", "<leader>nq", "<cmd>cnext<cr>", { desc = "Next Quickfix item" })
map("n", "<leader>pl", "<cmd>lprev<cr>", { desc = "Prev Loclist item" })
map("n", "<leader>nl", "<cmd>lnext<cr>", { desc = "Next Loclist item" })
map("n", "<leader>pd", vim.diagnostic.goto_prev, { desc = "Prev diagnostics item" })
map("n", "<leader>nd", vim.diagnostic.goto_next, { desc = "Next diagnostics item" })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

map("n", "<leader>qa",  "<cmd>qa<cr>",       { desc = "Quit All" })
map("n", "<leader>qw",  "<cmd>close<cr>",    { desc = "Quit Window" })
map("n", "<leader>qt",  "<cmd>tabclose<cr>", { desc = "Quit Tab" })

map("n", "<leader>ts", toggle_search_high, { desc = "Toggle Search highlight" })
map("n", "<leader>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle Wrapping of lines" })
map("n", "<leader>td", vim.diagnostic.open_float, { desc = "Toggle diagnostics" }) -- close with hjkl movement
map("n", "<leader>tq", "empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<cr>' : ':cclose<cr>'", { desc = "Toggle Quickfix list", expr = true })
map("n", "<leader>tl", "empty(filter(getwininfo(), 'v:val.loclist'))  ? ':lopen<cr>' : ':lclose<cr>'", { desc = "Toggle Location list", expr = true })

map("n", "<leader>I", "gg=G<c-o>", { desc = "Indent whole file" })
map("n", "<leader>Y", "ggyG<c-o>", { desc = "Yank whole file" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "z;", "zA", { desc = "Open fold recursively" })

map("n", "X", "<C-a>", { desc = "Increment number under cursor" })

map({ "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] })
map({ "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] })
map({ "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] })

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
