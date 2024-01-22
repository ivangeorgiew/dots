-- see `:h vim.g` for more
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- see `:h vim.o` for more
local o = vim.opt

o.tabstop = 2 -- amount of spaces on tab
o.shiftwidth = 2 -- amount of spaces on shifting
o.expandtab = true -- change tab to use spaces

o.autowriteall = true -- smart auto-save on some commands
o.backup = false -- toggle backup file
o.breakindent = true -- wrapped line continues on the same indent level
o.clipboard = "unnamedplus,unnamed" -- combine OS and Neovim clipboard
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
o.laststatus = 3 -- when to show statusline
o.list = true -- show hidden chars (tabs, trailing space, etc)
o.listchars="tab:»·,trail:·" -- chars to use for hidden symbols
o.mouse = "" -- disable mouse
o.number = false -- line numbers
o.ph = 10 -- max entries in a popup
o.redrawtime = 5000 -- increase redraw time for syntax handling
o.relativenumber = true -- relative line numbers
o.scrolloff = 10 -- min lines below and above
o.shortmess:append({ W = true, I = true, c = true, C = true }) -- skip some unnecessary messages
o.showcmd = false -- whether to show partial command on last line
o.showmode = false -- don't show vim typing mode
o.signcolumn = "yes" -- whether to always show the signcolumn
o.smartcase = true -- ignore case when only small letters are used
o.splitbelow = true -- new windows are below
o.splitkeep = "screen" -- keep text on the same screen line when resizing
o.splitright = true -- new windows are to the right
o.swapfile = false -- toggle swapfile
o.tagstack = false -- don't add tags manually
o.termguicolors = true -- enables 24-bit RGB colors
o.textwidth = 0 -- max line char length
o.timeoutlen = 500 -- time in ms to wait for mapped sequence
o.undofile = true -- whether to use undo file
o.updatetime = 500 -- writes swap file to disk every X ms
o.virtualedit = "block" -- be able to place the cursor anywhere during vis block mode
o.wildmode = "longest:full,full" -- command line completion
o.winminwidth = 5 -- min width of a window
o.wrap = false -- line wrap
o.showbreak = " ⤷ " -- arrow for wrapped text
