local M = {}

M.config = {
  to_delete = {
    { "n", { "ZZ", "<C-f>", "<C-b>" } },
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

    -- Better up/down movement
    { { "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true } },
    { { "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true } },

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

    -- Move lines up or down
    { "n", "<Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" } },
    { "n", "<Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" } },

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
    { "n", "<leader>qa", "<cmd>qa<cr>",       { desc = "Quit all" } },
    { "n", "<leader>qt", "<cmd>tabclose<cr>", { desc = "Quit tab" } },
    { "n", "<leader>qw", "<cmd>close<cr>",    { desc = "Quit window" } },

    -- Toggle things
    { "n", "<leader>tb", "<cmd>buffers<cr>", { desc = "Toggle buffers" } },
    { "n", "<leader>td", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle diff mode" } },
    { "n", "<leader>te", function() local h = vim.diagnostic.open_float; h();h(); end, { desc = "Toggle errors on current line" } },
    { "n", "<leader>tE", vim.diagnostic.setloclist, { desc = "Toggle errors list" } },
    { "n", "<leader>tl", "<cmd>Lazy<cr>", { desc = "Toggle Lazy" } },
    { "n", "<leader>tm", "<cmd>Mason<cr>", { desc = "Toggle Mason" } },
    { "n", "<leader>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle Wrapping of lines" } },
    {
      "n", "<leader>th",
      "getreg('/') == '' ? ':let @/=g:last_hls | let g:last_hls=\"\"<cr>' : ':let g:last_hls=@/ | let @/=\"\"<cr>'",
      { desc = "Toggle search highlighting", expr = true }
    },
    {
      "n", "<leader>tq",
      "empty(filter(getwininfo(), 'v:val.tabnr == tabpagenr() && v:val.loclist')) ? ':lopen<cr>' : ':windo lclose<cr>'",
      { desc = "Toggle location list", expr = true }
    },

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
    { "n", "Q", "q", { desc = "Start/end macro" } },
    { "n", "q", "reg_recording() == 'e' ? 'q' : 'qe'", { desc = "Start/end default macro", expr = true } },
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

    -- Search in file (delete the \c to match case)
    { "n", "/", "/\\c", { desc = "Search for text in buffer", silent = false } },
    { "v", "/", "\"ay/\\V<C-r>a<cr>", { desc = "Search for the selection", } },
    { "n", "<leader>/", "/\\<<C-r><C-w>\\><cr><C-o>", { desc = "Search for word under cursor in buffer" } },
    { "v", "<leader>/", "<esc>/\\%V\\c", { desc = "Search in visual selection", silent = false } },

    -- Find text in all files
    { "n", ")", ":Find ", { desc = "Find in all files", silent = false } },
    { "n", "<leader>)", ":Find -w <C-r><C-w><cr>", { desc = "Find word under cursor in all files" } },
    { "v", ")", "\"ay:let @a = escape(@a,'\"')<cr>:Find \"<C-r>a\"<cr>", { desc = "Find the selection in all files" } },

    -- Search and replace
    { "n", "<leader>s", [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], { desc = "Search and replace word under cursor",   silent = false } },
    { "v", "<leader>s", [["ay:%s/<C-r>a//gc<Left><Left><Left>]],      { desc = "Search and replace visual selection",    silent = false } },
    { "v", "<leader>S", [[:s/\%V/gc<Left><Left><Left>]],              { desc = "Search and replace in visual selection", silent = false } },

    -- Motion expecting operations
    { { "v", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] } },
    { { "v", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] } },
    { { "v", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] } },

    -- Operate on whole file
    { "n", "<leader>%=", "msgg=Gg`s", { desc = "Indent whole file" } },
    { "n", "<leader>%y", "msggyGg`s", { desc = "Yank whole file" } },
    { "n", "<leader>%r", "ggVGpgg",   { desc = "Replace whole file" } },

    -- Unrelated mappings
    { "n", "X", "<C-a>", { desc = "Increment number under cursor" } },
    { "t", "<C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" } },
    { "n", "<leader>o", "<cmd>only<cr>",  { desc = "Leave only the current window" } },
    { "n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" } },
    { "n", "J", "mzJ`z", { desc = "Join lines" } },
    { "n", "K", function() local h = vim.lsp.buf.hover; h(); h(); end, { desc = "Enter symbol information popup" } },
    { "n", "gd", function() vim.lsp.buf.definition({ loclist = true }) end, { desc = "Go to definition" } },
    { "n", "i", "len(getline('.')) == 0 && empty(&buftype) ? '\"_cc' : 'i'", { desc = "Enter insert mode", expr = true } },
    { "n", "<leader><tab>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" } },

    -- Command mode abbreviations
    { "ca", "te", "tabe", {} },
    { "ca", "vs", "vsplit", {} },

    -- Insert mode abbreviations
    { "ia", "teh", "the", {} },
    { "ia", "cosnt", "const", {} },
    { "ia", "prosp", "props", {} },
  },
  quickfix = {
    { "n", "<C-r>", "<cmd>Replace<cr>", { desc = "Replace text in files" } },
    { "n", "<C-t>", "<C-w><CR><C-w>T", { desc = "Open quickfix file in new tab" } },
    { "n", "<C-s>", "<C-w><CR>", { desc = "Open quickfix file in hor. split" } },
    { "n", "<C-v>", "<C-w><CR><C-w>L<C-w>2w<C-w>J<C-w>2w", { desc = "Open quickfix file in vert. split" } },
  },
}

M.setup = tie(
  "setup keymaps",
  function()
    tied.apply_maps(M.config.to_create, M.config.to_delete)
  end,
  tied.do_nothing
)

return M
