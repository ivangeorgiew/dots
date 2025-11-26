local M = { rhs = {} }

M.rhs.toggle_bool = function()
  local word = vim.fn.expand("<cword>")
  ---@type [string, string][]
  local bools = {
    { "true", "false" },
    { "TRUE", "FALSE" },
    { "True", "False" },
    { "yes", "no" },
    { "1", "0" },
  }

  tied.each_i("Toggle bool-like under cursor", bools, function(_, pair)
    local contra_idx

    if word == pair[1] then
      contra_idx = 2
    elseif word == pair[2] then
      contra_idx = 1
    end

    if contra_idx ~= nil then
      vim.cmd("normal! ms")
      vim.cmd("silent noautocmd normal! ciw" .. pair[contra_idx])
      vim.cmd("normal! g`s")
    end
  end)
end

M.config = {
  ---@type [string, string[]|string] []
  to_delete = {
    { "#", { "n", "x" } }, -- use `m` instead
    { "&", { "n", "x" } },
    { "(", { "n", "x" } },
    { ")", { "n", "x" } },
    { "*", { "n", "x" } }, -- use `M` instead
    { "+", { "n", "x" } },
    { "-", { "n", "x" } },
    { "<C-b>", "n" },
    { "<C-e>", "n" },
    { "<C-f>", "n" },
    { "<C-z>", "n" },
    { "<Down>", { "n", "x" } },
    { "<Left>", { "n", "x" } },
    { "<Right>", { "n", "x" } },
    { "<Up>", { "n", "x" } },
    { "_", { "n", "x" } },
    { "H", { "n", "x" } },
    { "K", { "n", "x" } },
    { "L", { "n", "x" } },
    { "M", { "n", "x" } },
    { "q", { "n", "x" } }, -- use `#` instead
    { "R", { "n", "x" } },
    { "r", { "n", "x" } },
    { "S", { "n", "x" } }, -- shorthand for cc
    { "s", { "n", "x" } }, -- shorthand for cl
    { "X", { "n", "x" } }, -- shorthand for dh
    { "x", { "n", "x" } }, -- shorthand for dl
    { "Z", { "n", "x" } },
    { "ZZ", "n" },
    { "|", { "n", "x" } },
  },
  ---@type KeymapSetArgs[]
  -- stylua: ignore
  to_create = {
    -- Escape mappings
    { { "i", "n", "x" }, "<Esc>", "<cmd>lua vim.snippet.stop()<cr><esc>", { desc = "Escape" } },
    { { "i", "n", "x" }, "<C-c>", "<esc>", { desc = "Escape", remap = true } },
    { { "i", "n", "x" }, "<C-s>", "<cmd>w<bar>diffupdate<bar>normal! <C-l><cr><esc>", { desc = "Save file", remap = true } },

    -- Don't copy to buffer on certain commands
    { "x", "p", "P", { desc = "Paste" } },
    { "n", "DD", "dd", { desc = "Cut Line" } },
    { { "n", "x" }, "D", "d", { desc = "Cut" } },
    { { "n", "x" }, "d", [["_d]],  { desc = "Delete" } },
    { { "n", "x" }, "c", [["_c]],  { desc = "Change" } },

    -- Handle wrapped lines
    { { "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move up", expr = true } },
    { { "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move down", expr = true } },

    -- Cursor movement in insert mode
    { "i", "<C-h>", "<Left>",  { desc = "Move left" } },
    { "i", "<C-l>", "<Right>", { desc = "Move right" } },

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
    { "n",          "n", "'Nn'[v:searchforward].'zv'", { desc = "Next search result", expr = true } },
    { "n",          "N", "'nN'[v:searchforward].'zv'", { desc = "Prev search result", expr = true } },
    { { "x", "o" }, "n", "'Nn'[v:searchforward]",      { desc = "Next search result", expr = true } },
    { { "x", "o" }, "N", "'nN'[v:searchforward]",      { desc = "Prev search result", expr = true } },

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
    { "n", "<leader>tD", function() vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0 }), { bufnr = 0 }) end , { desc = "Toggle diagnostics on/off" } },
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
    { { "n", "x" }, "<cr>", "empty(&buftype) ? ':normal! @e<cr>' : '<cr>'", { desc = "Apply default macro", expr = true } },

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
    { "x", "/", "\"ay/\\V<C-r>a<cr>", { desc = "Search for the selection", } },
    { "x", "<leader>/", "<esc>/\\%V\\c", { desc = "Search in visual selection", silent = false } },

    -- Find text in all files
    { "n", ")", ":Find ", { desc = "Find in all files", silent = false } },
    { "n", "<leader>)", ":Find -s -w <C-r><C-w><cr>", { desc = "Find word under cursor in all files" } },
    { "x", ")", "\"ay:let @a = escape(@a,'\"')<cr>:Find -s \"<C-r>a\"<cr>", { desc = "Find the selection in all files" } },

    -- Search and replace
    { "n", "<leader>s", [[:%s/\(\<<C-r><C-w>\>\)/\1/gc<Left><Left><Left>]], { desc = "Search and replace word under cursor",   silent = false } },
    { "x", "<leader>s", [["ay:%s/\(<C-r>a\)/\1/gc<Left><Left><Left>]],      { desc = "Search and replace visual selection",    silent = false } },
    { "x", "<leader>S", [[:s/\%V/g<Left><Left>]],                           { desc = "Search and replace in visual selection", silent = false } },

    -- Motion expecting operations
    { { "x", "o" }, [[a"]], [[2i"]], { desc = [[Select all in ""]] } },
    { { "x", "o" }, [[a']], [[2i']], { desc = [[Select all in '']] } },
    { { "x", "o" }, [[a`]], [[2i`]], { desc = [[Select all in ``]] } },

    -- Operate on whole file
    { "n", "<leader>%=", "msgg=Gg`s", { desc = "Indent whole file" } },
    { "n", "<leader>%y", "msggyGg`s", { desc = "Yank whole file" } },
    { "n", "<leader>%r", "ggVGpgg",   { desc = "Replace whole file" } },

    -- Change number under cursor
    { "n", "+", "<C-a>", { desc = "Increment number" } },
    { "n", "?", "<C-x>", { desc = "Decrement number" } },

    -- Unrelated mappings
    { "n", "J", "mzJg`z", { desc = "Join lines" } },
    { "n", "i", "len(getline('.')) == 0 && empty(&buftype) ? '\"_cc' : 'i'", { desc = "Enter insert mode", expr = true } },
    { "n", "<leader><tab>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" } },
    { "n", "<F5>", function() tied.manage_session(true) end, { desc = "Load session" } },
    { "n", "<BS>", "dh", { desc = "Delete prev letter" } },
    { "n", "<C-x>", M.rhs.toggle_bool, { desc = "Toggle boolean under cursor" } },
    -- { "n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" } },

    -- Command mode abbreviations
    { "ca", "te", "tabe", {} },
    { "ca", "vs", "vsplit", {} },
    { "ca", "sort", "sort i", {} },

    -- Insert mode abbreviations
    { "ia", "teh", "the", {} },
    { "ia", "cosnt", "const", {} },
    { "ia", "prosp", "props", {} },
  },
  ---@type KeymapSetArgs[]
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
    "Delete keymap",
    M.config.to_delete,
    function(_, map) tied.delete_map(map[2], map[1]) end
  )
  tied.each_i(
    "Create keymap",
    M.config.to_create,
    function(_, map) tied.create_map(unpack(map)) end
  )
end, tied.do_nothing)

return M
