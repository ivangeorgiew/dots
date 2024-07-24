-- delete mappings

local delete_maps = tie(
  "delete default mappings",
  { { "string", "table" }, "table" },
  function(modes, commands)
    for _, lhs in ipairs(commands) do
      create_map(modes, lhs, "<nop>", { desc = "Nothing" })
    end
  end
)

delete_maps("n", { "Z", "ZZ" })

-- mappings

-- TODO: add mappings for cut and for replace

-- TODO: remove the below mappings when plugin is added
create_map("v", "p", "P", { desc = "Replace" })
create_map("n", "DD", "dd", { desc = "Cut line" })
create_map("n", "dd", [["_dd]],  { desc = "Delete line" })
create_map({ "n", "v" }, "D", "d", { desc = "Cut" })
create_map({ "n", "v" }, "d", [["_d]],  { desc = "Delete" })
create_map({ "n", "v" }, "s", [["_s]],  { desc = "Substitute" })
create_map({ "n", "v" }, "c", [["_c]],  { desc = "Change" })
create_map({ "n", "v" }, "x", [["_x]],  { desc = "Delete character" })

create_map({ "i", "n" }, "<C-c>", "<cmd>noh<bar>diffupdate<bar>normal! <C-l><cr><esc>", { desc = "Refresh screen and state" })
create_map({ "i", "n" }, "<Esc>", "<cmd>noh<bar>diffupdate<bar>normal! <C-l><cr><esc>", { desc = "Refresh screen and state" })
create_map({ "i", "n" }, "<C-s>", "<cmd>w<bar>noh<cr><esc>", { desc = "Save file" })

create_map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
create_map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })

create_map("n", "<C-h>", "<C-w>h", { desc = "Go to left split"  })
create_map("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })
create_map("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
create_map("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })

create_map("n", "<C-d>", "20jzz", { desc = "Move screen down" })
create_map("n", "<C-u>", "20kzz", { desc = "Move screen up" })

create_map("n", "<S-Up>",    ":resize +2<cr>",          { desc = "Increase window height" })
create_map("n", "<S-Down>",  ":resize -2<cr>",          { desc = "Decrease window height" })
create_map("n", "<S-Left>",  ":vertical resize -2<cr>", { desc = "Decrease window width" })
create_map("n", "<S-Right>", ":vertical resize +2<cr>", { desc = "Increase window width" })

create_map("n", "<C-Up>",   ":m -2<cr>==",      { desc = "Move selected lines up"   })
create_map("n", "<C-Down>", ":m +1<cr>==",      { desc = "Move selected lines down" })
create_map("v", "<C-Up>",   ":m '<-2<cr>gv=gv", { desc = "Move selected lines up"   })
create_map("v", "<C-Down>", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })

create_map("n",          "n", "'Nn'[v:searchforward].'zv'",     { desc = "Next search result", expr = true })
create_map("n",          "N", "'nN'[v:searchforward].'zv'",     { desc = "Prev search result", expr = true })
create_map({ "x", "o" }, "n", "'Nn'[v:searchforward]",          { desc = "Next search result", expr = true })
create_map({ "x", "o" }, "N", "'nN'[v:searchforward]",          { desc = "Prev search result", expr = true })

create_map("n", "<leader>k", "K", { desc = "Keywordprg" })

create_map("n", "<leader>l", ":Lazy<cr>", { desc = "Open lazy.nvim" })

create_map("n", "<leader>do", vim.diagnostic.open_float, { desc = "Show diagnostics in a window" })

create_map("n", "<leader>pq", ":cprev<cr>", { desc = "Prev Quickfix item" })
create_map("n", "<leader>nq", ":cnext<cr>", { desc = "Next Quickfix item" })
create_map("n", "<leader>pl", ":lprev<cr>", { desc = "Prev Loclist item" })
create_map("n", "<leader>nl", ":lnext<cr>", { desc = "Next Loclist item" })
create_map("n", "<leader>pd", vim.diagnostic.goto_prev, { desc = "Prev diagnostics item" })
create_map("n", "<leader>nd", vim.diagnostic.goto_next, { desc = "Next diagnostics item" })

create_map("n", "<leader>qa",  ":qa<cr>",       { desc = "Quit All" })
create_map("n", "<leader>qw",  ":close<cr>",    { desc = "Quit Window" })
create_map("n", "<leader>qt",  ":tabclose<cr>", { desc = "Quit Tab" })

create_map("n", "<leader>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle Wrapping of lines" })
create_map("n", "<leader>td", vim.diagnostic.open_float, { desc = "Toggle diagnostics" }) -- close with hjkl movement
create_map("n", "<leader>tq", "empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<cr>' : ':cclose<cr>'", { desc = "Toggle Quickfix list", expr = true })
create_map("n", "<leader>tl", "empty(filter(getwininfo(), 'v:val.loclist'))  ? ':lopen<cr>' : ':lclose<cr>'", { desc = "Toggle Location list", expr = true })

create_map("n", "<leader>I", "gg=G<c-o>", { desc = "Indent whole file" })
create_map("n", "<leader>Y", "ggyG<c-o>", { desc = "Yank whole file" })

create_map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

create_map("n", "z;", "zA", { desc = "Open fold recursively" })

create_map("n", "X", "<C-a>", { desc = "Increment number under cursor" })

create_map({ "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] })
create_map({ "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] })
create_map({ "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] })

create_map("c", "<C-a>", "<Home>",    { desc = "Go to the beginning", silent = false })
create_map("c", "<C-b>", "<S-Left>",  { desc = "Go a word to the left", silent = false })
create_map("c", "<C-f>", "<S-Right>", { desc = "Go a word to the right", silent = false })
create_map("c", "<C-h>", "<Left>",    { desc = "Go left", silent = false })
create_map("c", "<C-l>", "<Right>",   { desc = "Go right", silent = false })

create_map("n", "<leader>1", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle diff mode" })

create_map({ "i", "c" }, "<C-v>",  [[<C-r>+]], { desc = "Paste in insert mode", silent = false })

create_map("n", "m", "*", { desc = "Go to next occurance of the word" })
create_map("n", "M", "#", { desc = "Go to prev occurance of the word" })

create_map("v", "$", "g_", { desc = "Go until end of line" })

create_map("n", "q", "reg_recording() == 'e' ? 'q' : 'qe'", { desc = "Start/end macro", expr = true })
create_map("n", "Q", "reg_recording() == 'e' ? 'q' : 'qe'", { desc = "Start/end macro", expr = true })

create_map({ "n", "v" }, "<cr>", "empty(&buftype) ? ':normal @e<cr>' : '<cr>'", { desc = "Apply macro", expr = true })

create_map("n", "<S-h>", "gT", { desc = "Switch to left tab" })
create_map("n", "<S-l>", "gt", { desc = "Switch to right tab" })
create_map("n", "<leader><S-h>", ":tabm -1<cr>", { desc = "Move tab to the left" })
create_map("n", "<leader><S-l>", ":tabm +1<cr>", { desc = "Move tab to the right" })

create_map("n", "<leader>o", ":only<cr>",  { desc = "Leave only the current window" })

create_map("n", "zj", "o<esc>k", { desc = "Make a new line below" })
create_map("n", "zk", "O<esc>j", { desc = "Make a new line above" })

create_map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace word under cursor", silent = false })
create_map("v", "<leader>s", [["ay:%s/<C-r>a/<C-r>a/gI<Left><Left><Left>]],          { desc = "Search and replace visual selection",  silent = false })

-- abbreviations

create_map("ca", "te", "tabe", {})
create_map("ca", "vs", "vsplit", {})

create_map("!a", "teh", "the", {})
create_map("!a", "cosnt", "const", {})
create_map("!a", "prosp", "props", {})
