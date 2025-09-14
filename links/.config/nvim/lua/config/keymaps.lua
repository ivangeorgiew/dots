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

delete_maps("n", { "ZZ", "<C-f>", "<C-b>" })

-- TODO: change some of my keybinds to use a single char

-- free unneeded single chars
delete_maps({ "n", "v" }, {
  "~", -- use `gu`/`gU`
  "#", -- use `m` instead
  "&",
  "*", -- use `M` instead
  "(",
  ")",
  "_",
  "-",
  "+",
  "Q",
  "r",
  "R",
  --"t",
  --"T",
  -- "f",
  -- "F",
  -- "s", -- shorthand for cl
  -- "S", -- shorthand for cc
  "H", -- (reused)
  "L", -- (reused)
  "|",
  "\\",
  "Z",
  -- "x", -- shorthand for dl
  -- "X", -- shorthand for dh
  "M",
})

-- mappings

-- TODO: add mappings for cut and for replace

-- TODO: remove the below mappings when plugin is added
create_map("v", "p", "P", { desc = "Replace" })
create_map("n", "DD", "dd", { desc = "Cut line" })
create_map("n", "dd", [["_dd]],  { desc = "Delete line" })
create_map({ "n", "v" }, "D", "d", { desc = "Cut" })
create_map({ "n", "v" }, "d", [["_d]],  { desc = "Delete" })
create_map({ "n", "v" }, "c", [["_c]],  { desc = "Change" })

create_map({ "i", "n", "v" }, "<C-c>", "<esc>", { desc = "Escape" })
create_map({ "i", "n", "v" }, "<C-s>", "<cmd>w<bar>noh<bar>diffupdate<bar>normal! <C-l><cr><esc>", { desc = "Save file" })

create_map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true })
create_map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true })

create_map("i", "<C-h>", "<Left>",  { desc = "Move left" })
create_map("i", "<C-l>", "<Right>", { desc = "Move right" })
create_map("i", "<C-k>", "<Up>",    { desc = "Move up" })
create_map("i", "<C-j>", "<Down>",  { desc = "Move down" })

create_map("n", "<C-h>", "<cmd>Navigate h<cr>", { desc = "Go to left split"  })
create_map("n", "<C-l>", "<cmd>Navigate l<cr>", { desc = "Go to right split" })
create_map("n", "<C-k>", "<cmd>Navigate k<cr>", { desc = "Go to upper split" })
create_map("n", "<C-j>", "<cmd>Navigate j<cr>", { desc = "Go to lower split" })

create_map("n", "<S-h>", "gT", { desc = "Switch to left tab" })
create_map("n", "<S-l>", "gt", { desc = "Switch to right tab" })
create_map("n", "<leader><S-h>", ":tabm -1<cr>", { desc = "Move tab to the left" })
create_map("n", "<leader><S-l>", ":tabm +1<cr>", { desc = "Move tab to the right" })

create_map("n", "<C-d>", "20jzz", { desc = "Move screen down" })
create_map("n", "<C-u>", "20kzz", { desc = "Move screen up" })

create_map("n", "<S-Up>",    ":resize +2<cr>",          { desc = "Increase window height" })
create_map("n", "<S-Down>",  ":resize -2<cr>",          { desc = "Decrease window height" })
create_map("n", "<S-Left>",  ":vertical resize -2<cr>", { desc = "Decrease window width" })
create_map("n", "<S-Right>", ":vertical resize +2<cr>", { desc = "Increase window width" })

create_map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selected lines up"   })
create_map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
create_map("n",          "n", "'Nn'[v:searchforward].'zv'",     { desc = "Next search result", expr = true })
create_map("n",          "N", "'nN'[v:searchforward].'zv'",     { desc = "Prev search result", expr = true })
create_map({ "x", "o" }, "n", "'Nn'[v:searchforward]",          { desc = "Next search result", expr = true })
create_map({ "x", "o" }, "N", "'nN'[v:searchforward]",          { desc = "Prev search result", expr = true })

create_map("n", "<leader>kq", ":cprev<cr>", { desc = "Prev Quickfix item" })
create_map("n", "<leader>jq", ":cnext<cr>", { desc = "Next Quickfix item" })
create_map("n", "<leader>kl", ":lprev<cr>", { desc = "Prev Loclist item" })
create_map("n", "<leader>jl", ":lnext<cr>", { desc = "Next Loclist item" })
create_map("n", "<leader>kd", vim.diagnostic.goto_prev, { desc = "Prev diagnostics item" })
create_map("n", "<leader>jd", vim.diagnostic.goto_next, { desc = "Next diagnostics item" })

create_map("n", "<leader>qa", ":qa<cr>",       { desc = "Quit All" })
create_map("n", "<leader>qw", ":close<cr>",    { desc = "Quit Window" })
create_map("n", "<leader>qt", ":tabclose<cr>", { desc = "Quit Tab" })

create_map("n", "<leader>th", function() vim.o.hls = not vim.o.hls end, { desc = "Toggle highlight search" })
create_map("n", "<leader>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle wrapping of lines" })
create_map("n", "<leader>td", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle diff mode" })
create_map("n", "<leader>te", vim.diagnostic.open_float, { desc = "Toggle errors" }) -- close with hjkl movement
create_map("n", "<leader>tq", "empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<cr>' : ':cclose<cr>'", { desc = "Toggle Quickfix list", expr = true })
create_map("n", "<leader>tl", "empty(filter(getwininfo(), 'v:val.loclist'))  ? ':lopen<cr>' : ':lclose<cr>'", { desc = "Toggle Location list", expr = true })

create_map("c", "<C-a>", "<Home>",    { desc = "Go to the beginning", silent = false })
create_map("c", "<C-b>", "<S-Left>",  { desc = "Go a word to the left", silent = false })
create_map("c", "<C-f>", "<S-Right>", { desc = "Go a word to the right", silent = false })
create_map("c", "<C-h>", "<Left>",    { desc = "Go left", silent = false })
create_map("c", "<C-l>", "<Right>",   { desc = "Go right", silent = false })

create_map("n", "m", "*", { desc = "Go to next occurance of the word" })
create_map("n", "M", "#", { desc = "Go to prev occurance of the word" })

create_map("n", "Q", "q", { desc = "Start/end macro" })
create_map("n", "q", "reg_recording() == 'e' ? 'q' : 'qe'", { desc = "Start/end default macro", expr = true })
create_map({ "n", "v" }, "<cr>", "empty(&buftype) ? ':normal @e<cr>' : '<cr>'", { desc = "Apply default macro", expr = true })

create_map("n", "zj", "o<esc>k", { desc = "Make a new line below" })
create_map("n", "zk", "O<esc>j", { desc = "Make a new line above" })

create_map("n", "z;", "zA", { desc = "Open fold recursively" })
create_map("n", "zn", "zr", { desc = "Reduce fold level" }) -- opposite of zm
create_map("n", "zN", "zR", { desc = "Open all folds" }) -- opposite of zM

create_map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace word under cursor",   silent = false })
create_map("v", "<leader>s", [["ay:%s/<C-r>a/<C-r>a/gI<Left><Left><Left>]],          { desc = "Search and replace visual selection",    silent = false })
create_map("v", "<leader>S", [[:s/\%V/gI<Left><Left><Left>]],                        { desc = "Search and replace in visual selection", silent = false })

create_map({ "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] })
create_map({ "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] })
create_map({ "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] })

-- unrelated single mappings

create_map("n", "<leader>/", "/\\C", { desc = "Search with case matching", silent = false })

create_map("n", "X", "<C-a>", { desc = "Increment number under cursor" })

create_map("t", "<C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

create_map("n", "<leader>o", ":silent! only<cr>",  { desc = "Leave only the current window" })

create_map("v", "$", "g_", { desc = "Go until end of line" })

create_map({ "i", "c" }, "<C-v>",  [[<C-r>"]], { desc = "Paste in insert mode" })

create_map("n", "<leader>x", ":!chmod +x %<CR>", { desc = "Make file executable" })

create_map("n", "J", "mzJ`z", { desc = "Join lines" })

-- abbreviations

create_map("ca", "te", "tabe", {})
create_map("ca", "vs", "vsplit", {})
create_map("ca", "rg", "Find", {})
create_map("ca", "grep", "Find", {})

create_map("!a", "teh", "the", {})
create_map("!a", "cosnt", "const", {})
create_map("!a", "prosp", "props", {})
