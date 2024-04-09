-- see `:h vim.g` for more
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- see `:h vim.opt` for more
local o = vim.opt

o.tabstop = 2 -- amount of spaces on tab
o.shiftwidth = 2 -- amount of spaces on shifting
o.expandtab = true -- change tab to use spaces

o.autoindent = true -- copy indent level from previous line
o.autowriteall = true -- smart auto-save on some commands
o.backup = false -- toggle backup file
o.breakindent = true -- wrapped line continues on the same indent level
o.clipboard = "unnamedplus,unnamed" -- combine OS and Neovim clipboard
o.cmdheight = 0 -- if set to 0, hides the command line, when not typing a command
o.complete = ".,t" -- where to get completions from
o.completeopt = "menu,menuone,noselect,longest" -- completion options
o.confirm = true -- popup to save file after some commands
o.diffopt = "vertical,iwhite,filler" -- vimdiff split direction and ignore whitespace
o.foldlevel = 0 -- close all folds by default
o.foldmethod = "marker" -- default fold method
o.grepformat = "%f:%l:%c:%m" -- format for grep command
o.grepprg = "rg --vimgrep" -- use silver_searcher for grep
o.hlsearch = true -- highlighting search results
o.ignorecase = true -- see smartcase option
o.inccommand = "split" -- include partial off-screen matches for search and replace
o.incsearch = true -- show where the pattern is as you search for it
o.laststatus = 3 -- when to show statusline
o.list = true -- show hidden chars (tabs, trailing space, etc)
o.listchars="tab:»·,trail:·" -- chars to use for hidden symbols
o.mouse = "" -- disable mouse
o.number = false -- line numbers
o.pumheight = 10 -- max entries in a popup
o.redrawtime = 5000 -- increase redraw time for syntax handling
o.relativenumber = true -- relative line numbers
o.scrolloff = 10 -- min lines below and above
o.shortmess = "aoOsScCtTWI" -- skip some unnecessary messages
o.showbreak = " ⤷ " -- arrow for wrapped text
o.showcmd = false -- whether to show partial command on last line
o.showmode = false -- don't show vim typing mode
o.signcolumn = "yes" -- whether to always show the signcolumn
o.smartcase = true -- ignore case when only small letters are used
o.smartindent = false -- C-like indenting (not needed)
o.splitbelow = true -- new windows are below
o.splitkeep = "cursor" -- don't change cursor position when splits change
o.splitright = true -- new windows are to the right
o.swapfile = false -- toggle swapfile
o.tagstack = false -- don't add tags manually
o.termguicolors = true -- enables 24-bit RGB colors
o.textwidth = 0 -- max line char length
o.timeoutlen = 500 -- time in ms to wait for mapped sequence
o.undofile = true -- whether to use undo file
o.updatetime = 500 -- used for CursorHold and swap file
o.virtualedit = "block" -- be able to place the cursor anywhere during vis block mode
o.wildignore:append({"*/node_modules/*"}) -- ignore node_modules folders for completion stuff
o.wildmode = "longest:full,full" -- command line completion
o.winminwidth = 5 -- min width of a window
o.wrap = false -- line wrap
