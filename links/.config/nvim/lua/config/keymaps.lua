local M = {}

M.config = {
  to_delete = {
    { "#", { "n", "v" } }, -- use `m` instead
    { "&", { "n", "v" } },
    { "(", { "n", "v" } },
    { ")", { "n", "v" } },
    { "*", { "n", "v" } }, -- use `M` instead
    { "+", { "n", "v" } },
    { "-", { "n", "v" } },
    { "<C-b>", "n" },
    { "<C-e>", "n" },
    { "<C-f>", "n" },
    { "<C-z>", "n" },
    { "<Down>", { "n", "v" } },
    { "<Left>", { "n", "v" } },
    { "<Right>", { "n", "v" } },
    { "<Up>", { "n", "v" } },
    { "_", { "n", "v" } },
    { "H", { "n", "v" } },
    { "K", { "n", "v" } },
    { "L", { "n", "v" } },
    { "M", { "n", "v" } },
    { "q", { "n", "v" } }, -- use `#` instead
    { "R", { "n", "v" } },
    { "r", { "n", "v" } },
    { "S", { "n", "v" } }, -- shorthand for cc
    { "s", { "n", "v" } }, -- shorthand for cl
    { "X", { "n", "v" } }, -- shorthand for dh
    { "x", { "n", "v" } }, -- shorthand for dl
    { "Z", { "n", "v" } },
    { "ZZ", "n" },
    { "|", { "n", "v" } },
  },
  -- stylua: ignore
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
    { { "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true } },
    { { "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true } },

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
    { "n", "]e", function() vim.diagnostic.jump({ count =  1 }) end, { desc = "Next error" } },
    { "n", "[e", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev error" } },

    -- Quit things
    { "n", "qa", "<cmd>qa<cr>", { desc = "Quit all" } },
    { "n", "qr", "<cmd>cq<cr>", { desc = "Quit and reload neovim" } },
    { "n", "qt", "<cmd>tabclose<cr>", { desc = "Quit tab" } },
    { "n", "qw", "<cmd>close<cr>", { desc = "Quit window", } },
    { "n", "qo", "<cmd>only<cr>",  { desc = "Quit other windows" } },
    { "t", "<C-x>", "<C-\\><C-n>", { desc = "Exit terminal mode" } },
    { "n", "<C-e>", "<cmd>fclose<cr>", { desc = "Close floating window" } },

    -- Toggle things
    { "n", "<leader>td", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle diff mode" } },
    { "n", "<leader>te", vim.diagnostic.setloclist, { desc = "Toggle errors list" } },
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

    -- Unrelated mappings
    { "n", "X", "<C-a>", { desc = "Increment number under cursor" } },
    { "n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" } },
    { "n", "J", "mzJg`z", { desc = "Join lines" } },
    { "n", "i", "len(getline('.')) == 0 && empty(&buftype) ? '\"_cc' : 'i'", { desc = "Enter insert mode", expr = true } },
    { "n", "<leader><tab>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" } },
    { "n", "<F5>", function() tied.manage_session(true) end, { desc = "Load session" } },

    -- Command mode abbreviations
    { "ca", "te", "tabe", {} },
    { "ca", "vs", "vsplit", {} },
    { "ca", "sort", "sort i", {} },

    -- Insert mode abbreviations
    { "ia", "teh", "the", {} },
    { "ia", "cosnt", "const", {} },
    { "ia", "prosp", "props", {} },
  },
  -- stylua: ignore
  quickfix = {
    { "n", "<C-r>", "<cmd>Replace<cr>", { desc = "Replace text in files" } },
    { "n", "<C-t>", "<C-w><CR><C-w>T", { desc = "Open list item in new tab" } },
    { "n", "<C-s>", "<C-w><CR>", { desc = "Open list item in hor. split" } },
    { "n", "<C-v>", "<C-w><CR>:windo lclose<cr><C-w>L:lopen<cr><cr>", { desc = "Open list item in vert. split" } },
  },
}

M.setup = tie("Setup keymaps", function()
  -- First delete, then create
  tied.each_i(
    M.config.to_delete,
    "Delete keymap",
    function(_, map) tied.delete_map(map[2], map[1]) end
  )
  tied.each_i(
    M.config.to_create,
    "Create keymap",
    function(_, map) tied.create_map(unpack(map)) end
  )
end, tied.do_nothing)

return M
