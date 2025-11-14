local M = {}

M.config = {
  to_delete = {
    { "n", { "ZZ", "<C-z>", "<C-f>", "<C-b>" } },
    { { "n", "v" }, {
      "#", -- use `m` instead
      "&",
      "(",
      ")",
      "*", -- use `M` instead
      "+",
      "-",
      "H",
      "L",
      "M",
      "R",
      "S", -- shorthand for cc
      "X", -- shorthand for dh
      "Z",
      "_",
      "r",
      "s", -- shorthand for cl
      "x", -- shorthand for dl
      "q", -- use `#` instead
      "|",
      "~", -- use `gu`/`gU`
    } },
  },
  to_create = {
    -- Escape mappings
    { { "i", "n", "v" }, "<Esc>", "<cmd>lua vim.snippet.stop()<cr><esc>", { desc = "Escape" } },
    { { "i", "n", "v" }, "<C-c>", "<esc>", { desc = "Escape", remap = true } },
    { { "i", "n", "v" }, "<C-s>", "<cmd>w<bar>diffupdate<bar>normal! <C-l><cr><esc>", { desc = "Save file", remap = true } },

    -- Don't copy to buffer on certain commands
    { "v", "p", "P", { desc = "Paste" } },
    { "n", "DD", "dd", { desc = "Cut Line" } },
    { { "n", "v" }, "D", "d", { desc = "Cut" } },
    { { "n", "v" }, "d", [["_d]],  { desc = "Delete" } },
    { { "n", "v" }, "c", [["_c]],  { desc = "Change" } },

    -- Handle wrapped lines
    { { "n", "x" }, "k", function() return vim.v.count == 0 and "gk" or "k" end, { desc = "Move up", expr = true } },
    { { "n", "x" }, "j", function() return vim.v.count == 0 and "gj" or "j" end, { desc = "Move down", expr = true } },

    -- Cursor movement in insert mode
    { "i", "<C-h>", "<Left>",  { desc = "Move left" } },
    { "i", "<C-l>", "<Right>", { desc = "Move right" } },
    { "i", "<C-k>", "<Up>",    { desc = "Move up" } },
    { "i", "<C-j>", "<Down>",  { desc = "Move down" } },

    -- Split navigation
    { "n", "<C-h>", "<cmd>Navigate h<cr>", { desc = "Go to left split"  } },
    { "n", "<C-l>", "<cmd>Navigate l<cr>", { desc = "Go to right split" } },
    { "n", "<C-k>", "<cmd>Navigate k<cr>", { desc = "Go to upper split" } },
    { "n", "<C-j>", "<cmd>Navigate j<cr>", { desc = "Go to lower split" } },

    -- Tabs
    { "n", "<S-h>", "gT", { desc = "Switch to left tab" } },
    { "n", "<S-l>", "gt", { desc = "Switch to right tab" } },
    { "n", "<leader><S-h>", "<cmd>tabm -1<cr>", { desc = "Move tab to the left" } },
    { "n", "<leader><S-l>", "<cmd>tabm +1<cr>", { desc = "Move tab to the right" } },

    -- Resize window
    { "n", "<Up>",    "<cmd> resize +2<cr>",         { desc = "Increase window height" } },
    { "n", "<Down>",  "<cmd> resize -2<cr>",         { desc = "Decrease window height" } },
    { "n", "<Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" } },
    { "n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" } },

    -- Change window size
    { "n", "<S-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" } },
    { "n", "<S-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" } },
    { "n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" } },
    { "n", "<S-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" } },

    -- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
    { "n",          "n", "'Nn'[v:searchforward].'zv'",     { desc = "Next search result", expr = true } },
    { "n",          "N", "'nN'[v:searchforward].'zv'",     { desc = "Prev search result", expr = true } },
    { { "x", "o" }, "n", "'Nn'[v:searchforward]",          { desc = "Next search result", expr = true } },
    { { "x", "o" }, "N", "'nN'[v:searchforward]",          { desc = "Prev search result", expr = true } },

    -- Go to next/prev thing
    { "n", "<leader>k", "]", { desc = "Next thing", remap = true } },
    { "n", "<leader>j", "[", { desc = "Prev thing", remap = true } },
    { "n", "]e", function() vim.diagnostic.jump({ count =  1, float = true }) end, { desc = "Next error" } },
    { "n", "[e", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev error" } },

    -- Quit things
    { "n", "qa", "<cmd>qa<cr>", { desc = "Quit all" } },
    { "n", "qt", "<cmd>tabclose<cr>", { desc = "Quit tab" } },
    { "n", "qw", "<cmd>close<cr>", { desc = "Quit window", } },

    -- Toggle things
    { "n", "<leader>tb", "<cmd>buffers<cr>", { desc = "Toggle buffers" } },
    { "n", "<leader>td", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle diff mode" } },
    { "n", "<leader>te", vim.diagnostic.setloclist, { desc = "Toggle errors list" } },
    { "n", "<leader>ti", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 }) end, { desc = "Toggle inlay hints" } },
    { "n", "<leader>tl", "<cmd>Lazy<cr>", { desc = "Toggle Lazy" } },
    { "n", "<leader>tm", "<cmd>Mason<cr>", { desc = "Toggle Mason" } },
    { "n", "<leader>tq", "empty(filter(getwininfo(), 'v:val.tabnr == tabpagenr() && v:val.loclist')) ? ':lopen<cr>' : ':windo lclose<cr>'", { desc = "Toggle location list", expr = true } },
    { "n", "<leader>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle wrapping of lines" } },

    -- Command mode movement
    { "c", "<C-a>", "<Home>",    { desc = "Go to the beginning", silent = false } },
    { "c", "<C-b>", "<S-Left>",  { desc = "Go a word to the left", silent = false } },
    { "c", "<C-f>", "<S-Right>", { desc = "Go a word to the right", silent = false } },
    { "c", "<C-h>", "<Left>",    { desc = "Go left", silent = false } },
    { "c", "<C-l>", "<Right>",   { desc = "Go right", silent = false } },

    -- Go to next occurance
    { "n", "m", "*", { desc = "Go to next occurance of the word" } },
    { "n", "M", "#", { desc = "Go to prev occurance of the word" } },

    -- Macros
    { "n", "#", "reg_recording() == 'e' ? 'q' : 'qe'", { desc = "Start/end default macro", expr = true } },
    { { "n", "x" },  "Q", "q", { desc = "Start/end macro" } },
    { { "n", "v" }, "<cr>", "empty(&buftype) ? ':normal! @e<cr>' : '<cr>'", { desc = "Apply default macro", expr = true } },

    -- Make new line
    { "n", "zj", "o<esc>k", { desc = "Make a new line below" } },
    { "n", "zk", "O<esc>j", { desc = "Make a new line above" } },
    { "n", "gco", "ox<esc><cmd>normal gcc<cr>A<bs>", { desc = "Make a new commented line below" } },
    { "n", "gcO", "Ox<esc><cmd>normal gcc<cr>A<bs>", { desc = "Make a new commented line above" } },

    -- Folding
    { "n", "z;", "zA", { desc = "Open fold recursively" } },
    { "n", "zn", "zr", { desc = "Reduce fold level" } }, -- opposite of zm
    { "n", "zN", "zR", { desc = "Open all folds" } }, -- opposite of zM

    -- Search in file
    { "n", "/", "/\\c", { desc = "Case-insensitive search", silent = false } },
    { "n", "<leader>/", "/", { desc = "Case-sensitive search", silent = false } },
    { "v", "/", "\"ay/\\V<C-r>a<cr>", { desc = "Search for the selection", } },
    { "v", "<leader>/", "<esc>/\\%V\\c", { desc = "Search in visual selection", silent = false } },

    -- Find text in all files
    { "n", ")", ":Find ", { desc = "Find in all files", silent = false } },
    { "n", "<leader>)", ":Find -s -w <C-r><C-w><cr>", { desc = "Find word under cursor in all files" } },
    { "v", ")", "\"ay:let @a = escape(@a,'\"')<cr>:Find -s \"<C-r>a\"<cr>", { desc = "Find the selection in all files" } },

    -- Search and replace
    { "n", "<leader>s", [[:%s/\(\<<C-r><C-w>\>\)/\1/gc<Left><Left><Left>]], { desc = "Search and replace word under cursor",   silent = false } },
    { "v", "<leader>s", [["ay:%s/\(<C-r>a\)/\1/gc<Left><Left><Left>]],      { desc = "Search and replace visual selection",    silent = false } },
    { "v", "<leader>S", [[:s/\%V/g<Left><Left>]],                           { desc = "Search and replace in visual selection", silent = false } },

    -- Motion expecting operations
    { { "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] } },
    { { "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] } },
    { { "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] } },

    -- Operate on whole file
    { "n", "<leader>%=", "msgg=Gg`s", { desc = "Indent whole file" } },
    { "n", "<leader>%y", "msggyGg`s", { desc = "Yank whole file" } },
    { "n", "<leader>%r", "ggVGpgg",   { desc = "Replace whole file" } },

    -- Hover popups
    { "n", "K", function() local h = vim.lsp.buf.hover; h(); h(); end, { desc = "Show symbol information" } },
    { "n", "E", function() local h = vim.diagnostic.open_float; h();h(); end, { desc = "Show errors on current line" } },

    -- Unrelated mappings
    { "n", "X", "<C-a>", { desc = "Increment number under cursor" } },
    { "t", "<C-x>", "<C-\\><C-n>", { desc = "Exit terminal mode" } },
    { "n", "<leader>o", "<cmd>only<cr>",  { desc = "Leave only the current window" } },
    { "n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" } },
    { "n", "J", "mzJ`z", { desc = "Join lines" } },
    { "n", "gd", function() vim.lsp.buf.definition({ loclist = true }) end, { desc = "Go to definition" } },
    { "n", "i", "len(getline('.')) == 0 && empty(&buftype) ? '\"_cc' : 'i'", { desc = "Enter insert mode", expr = true } },
    { "n", "<leader><tab>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" } },

    -- Command mode abbreviations
    { "ca", "te", "tabe", {} },
    { "ca", "vs", "vsplit", {} },
    { "ca", "sort", "sort i", {} },

    -- Insert mode abbreviations
    { "ia", "teh", "the", {} },
    { "ia", "cosnt", "const", {} },
    { "ia", "prosp", "props", {} },
  },
  quickfix = {
    { "n", "<C-r>", "<cmd>Replace<cr>", { desc = "Replace text in files" } },
    { "n", "<C-t>", "<C-w><CR><C-w>T", { desc = "Open list item in new tab" } },
    { "n", "<C-s>", "<C-w><CR>", { desc = "Open list item in hor. split" } },
    { "n", "<C-v>", "<C-w><CR>:windo lclose<cr><C-w>L:lopen<cr><cr>", { desc = "Open list item in vert. split" } },
  },
}

M.setup = tie(
  "Setup keymaps",
  function()
    tied.apply_maps(M.config.to_create, M.config.to_delete)
  end,
  tied.do_nothing
)

return M
