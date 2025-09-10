-- see `:h vim.g` for more
local g = vim.g

g.colorscheme = "kanagawa" -- one of those in plugins/colorsheme.lua

g.mapleader = " "
g.maplocalleader = " "

-- provider related settings
-- for plugins created by different languages
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
-- g.loaded_python3_provider = 0
-- g.loaded_node_provider = 0
g.node_host_prog = "~/.npm-global/node_modules/.bin/neovim-node-host"

-- see `:h vim.filetype.add`
vim.filetype.add({
  extensions = {
    -- foo = 'fooscript',
  },
  filename = {
    -- ['.foorc'] = 'toml',
  }
})

-- see `:h vim.opt` for more
local o = vim.opt

o.tabstop = 2 -- amount of spaces on tab
o.shiftwidth = 2 -- amount of spaces on shifting
o.expandtab = true -- change tab to use spaces

o.autoindent = true -- copy indent level from previous line
o.autowrite = true -- smart auto-save on some commands
o.autowriteall = true -- smart auto-save on some commands
o.background = "dark" -- default to dark background
o.backup = false -- toggle backup file
o.breakindent = true -- wrapped line continues on the same indent level
o.clipboard = "unnamedplus" -- combine OS and Neovim clipboard
o.cmdheight = 1 -- if set to 0, hides the command line, when not typing a command NOTE: Experimental
o.complete = ".,t" -- where to get completions from
o.completeopt = "menu,menuone,noselect,longest" -- completion options
o.confirm = true -- popup to save file after some commands
o.diffopt = "vertical,iwhite,filler" -- vimdiff split direction and ignore whitespace
o.fillchars:append({ eob = " " }) -- hide ~ symbols at the end of files
o.foldlevel = 1 -- default fold default
o.foldmethod = "marker" -- default fold method
o.foldnestmax = 4 -- max nested fold levels
o.grepformat = "%f:%l:%m" -- format for grep command
o.grepprg = "rg --no-heading -. -n -S -F" -- faster alternative to grep
o.hlsearch = false -- highlighting search results
o.hidden = false -- ask to save before closing buffers
o.ignorecase = false -- see smartcase option
o.inccommand = "nosplit" -- include partial off-screen matches for search and replace
o.incsearch = true -- show where the pattern is as you search for it
o.laststatus = 3 -- when to show statusline
o.linebreak = true -- better break of long lines
o.list = true -- show hidden chars (tabs, trailing space, etc)
o.listchars = { tab = '»·', trail = '·', nbsp = '␣' } -- chars to use for hidden symbols
o.mouse = "" -- disable mouse
o.number = true -- line numbers
o.pumblend = 10 -- transparency for popups
o.pumheight = 10 -- max entries in a popup
o.redrawtime = 5000 -- increase redraw time for syntax handling
o.relativenumber = false -- relative line numbers
o.scrolloff = 10 -- min lines below and above
o.shiftround = true -- round indent
o.shortmess:append({ W = true, I = true, c = true, C = true, s = true }) -- skip some unnecessary messages
o.showbreak = " ⤷ " -- arrow for wrapped text
o.showcmd = false -- whether to show partial command on last line
o.showmode = false -- don't show vim typing mode
o.sidescrolloff = 8 -- columns of context
o.signcolumn = "yes" -- whether to always show the signcolumn
o.smartcase = true -- (requires ignorecase on) ignore case when only small letters are used
o.smartindent = false -- c-like indenting when 'indentexpr' is not used
o.splitbelow = true -- new windows are below
o.splitkeep = "cursor" -- don't change cursor position when splits change
o.splitright = true -- new windows are to the right
o.swapfile = false -- toggle swapfile
o.tagstack = false -- don't add tags manually
o.termguicolors = true -- enables 24-bit RGB colors
o.textwidth = 0 -- max line char length
o.timeoutlen = 5000 -- time in ms to wait for mapped sequence
o.undofile = true -- whether to use undo file
o.updatetime = 250 -- used for CursorHold and swap file
o.virtualedit = "block" -- be able to place the cursor anywhere during vis block mode
o.wildignore:append({ "*/node_modules/*" }) -- ignore node_modules folders for completion stuff
o.wildmode = "longest:full,full" -- command line completion
o.winminwidth = 5 -- min width of a window
o.wrap = false -- line wrap
