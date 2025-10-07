local M = {}
local delete_maps = tied.delete_maps
local create_map = tied.create_map

M.config = {
  -- TODO: change some of my keybinds to use a single char
  to_delete = {
    { "n", { "ZZ", "<C-f>", "<C-b>" } },
    { { "n", "v" }, {
      "~", -- use `gu`/`gU`
      "#", -- use `m` instead
      "*", -- use `M` instead
      "&",
      "(",
      ")", -- (reused)
      "_",
      "-",
      "+",
      "Q",
      "r",
      "R",
      -- "t",
      -- "T",
      -- "f",
      -- "F",
      "H", -- (reused)
      "L", -- (reused)
      "|",
      "\\", -- (reused) as localleader
      "Z",
      "M",
      -- "s", -- shorthand for cl
      -- "S", -- shorthand for cc
      -- "x", -- shorthand for dl
      -- "X", -- shorthand for dh
    } },
  },
  to_create = {
    -- Escape mappings
    { { "i", "n", "v" }, "<Esc>", "<cmd>lua vim.snippet.stop()<cr><cmd>let @/=''<cr><esc>", { desc = "Escape" } },
    { { "i", "n", "v" }, "<C-c>", "<esc>", { desc = "Escape", remap = true } },
    { { "i", "n", "v" }, "<C-s>", "<cmd>w<bar>diffupdate<bar>normal! <C-l><cr><esc>", { desc = "Save file", remap = true } },

    -- TODO: add mapping for cut and for replace
    -- TODO: remove the below mappings when/if plugin is added
    -- Don't copy to buffer on certain commands
    { "v", "p", "P", { desc = "Replace" } },
    { "o", "D", "d", { desc = "Cut line" } },
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
    { "n", "<Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" } },
    { "n", "<Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" } },

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
    { "n", "<leader>qa", "<cmd>qa<cr>",       { desc = "Quit All" } },
    { "n", "<leader>qt", "<cmd>tabclose<cr>", { desc = "Quit Tab" } },
    { "n", "<leader>qw", "<cmd>close<cr>",    { desc = "Quit Window" } },

    -- Toggle things
    { "n", "<leader>tb", "<cmd>buffers<cr>", { desc = "Toggle Buffers" } },
    { "n", "<leader>td", function() vim.cmd("windo " .. (vim.o.diff and "diffoff!" or "diffthis")) end , { desc = "Toggle Diff mode" } },
    { "n", "<leader>te", vim.diagnostic.setloclist, { desc = "Toggle errors list" } }, -- close with q
    { "n", "<leader>tl", "<cmd>Lazy<cr>", { desc = "Toggle Lazy" } }, -- close with q
    { "n", "<leader>tm", "<cmd>Mason<cr>", { desc = "Toggle Mason" } }, -- close with q
    { "n", "<leader>tq", "empty(filter(getwininfo(), 'v:val.loclist')) ? ':lopen<cr>' : ':lclose<cr>'", { desc = "Toggle location list", expr = true } },
    { "n", "<leader>tw", function() vim.o.wrap = not vim.o.wrap end, { desc = "Toggle Wrapping of lines" } },

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
    { "n", "gco", "ox<esc><cmd>normal gcc<cr>fxc$", { desc = "Make a new commented line below" } },
    { "n", "gcO", "Ox<esc><cmd>normal gcc<cr>fxc$", { desc = "Make a new commented line above" } },

    -- Folding
    { "n", "z;", "zA", { desc = "Open fold recursively" } },
    { "n", "zn", "zr", { desc = "Reduce fold level" } }, -- opposite of zm
    { "n", "zN", "zR", { desc = "Open all folds" } }, -- opposite of zM

    -- Search in file (delete the \c to match case)
    { "n", "/", "/\\c", { desc = "Search for text in buffer", silent = false } },
    { "n", "<leader>/", "/\\<<C-r><C-w>\\><cr>", { desc = "Search for word under cursor in buffer" } },
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
    { "n", "=%", "gg=G<C-o>", { desc = "Indent whole file" } },
    { "n", "y%", "ggyG<C-o>", { desc = "Yank whole file" } },
    { "n", "r%", "ggVGp",     { desc = "Replace whole file" } },

    -- Unrelated mappings
    { "n", "X", "<C-a>", { desc = "Increment number under cursor" } },
    { "t", "<C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" } },
    { "n", "<leader>o", "<cmd>only<cr>",  { desc = "Leave only the current window" } },
    { "n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" } },
    { "n", "J", "mzJ`z", { desc = "Join lines" } },
    { "n", "K", function() local h = vim.lsp.buf.hover; h(); h(); end, { desc = "Enter symbol information popup" } },
    { "n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" } },
    { "n", "i", "len(getline('.')) == 0 && empty(&buftype) ? '\"_cc' : 'i'", { desc = "Enter insert mode", expr = true } },
    { "n", "<leader><tab>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" } },

    -- Abbreviations
    { "ca", "te", "tabe", {} },
    { "ca", "vs", "vsplit", {} },

    -- Misspellings
    { "!a", "teh", "the", {} },
    { "!a", "cosnt", "const", {} },
    { "!a", "prosp", "props", {} },
  },
  quickfix = tie(
    "create keymaps for quickfix/location lists",
    function(e)
      local bn = e.buf -- buffer number

      create_map("n", "r", "<cmd>Replace<cr>", { buffer = bn, desc = "Replace text in files" })

      -- Open file mappings
      local cmd = ""
      cmd = "<C-w><CR><C-w>T"
      create_map("n", "<C-t>", cmd, { buffer = bn, desc = "Open quickfix file in new tab" })
      cmd = "<C-w><CR><C-w>L<C-w>2w<C-w>J<C-w>2w"
      create_map("n", "<C-v>", cmd, { buffer = bn, desc = "Open quickfix file in vert. split" })
      cmd = "<C-w><CR>"
      create_map("n", "<C-s>", cmd, { buffer = bn, desc = "Open quickfix file in hor. split" })
    end,
    do_nothing
  ),
  plugins = {
    todo_comments = tie(
      "create keymaps for plugin todo-comments.nvim",
      function()
        create_map("n", "<leader>kt", require("todo-comments").jump_prev, { desc = "Prev Todo (or other special) comment" })
        create_map("n", "<leader>jt", require("todo-comments").jump_next, { desc = "Next Todo (or other special) comment" })

        -- Always use location list instead of quickfix list
        local list_cmd = "TodoLocList keywords=TODO,FIX"

        create_map("n", "<leader>tc", "<cmd>"..list_cmd.."<cr>", { desc = "Toggle Comments (TODO,FIX,etc)" })
        create_map("ca", "TodoLocList", list_cmd, {})
        create_map("ca", "TodoQuickFix", list_cmd, {})

        -- TODO: integrate with Telescope.nvim (:TodoTelescope)
        -- TODO: integrate with Trouble.nvim (:TodoTrouble)
      end,
      do_nothing
    ),
  },
}

M.setup = tie(
  "setup keymaps",
  function()
    for k, v in ipairs(M.config.to_delete) do
      delete_maps(unpack(v))
    end

    for k, v in ipairs(M.config.to_create) do
      create_map(unpack(v))
    end
  end,
  do_nothing
)

return M
