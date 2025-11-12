local M = {}

M.setup = tie(
  "Setup options",
  function()
    -- See `:h vim.g` for more
    local g = vim.g

    -- Defined in the plugins/colorschemes folder
    local colorschemes = { "kanagawa", "tokyonight", "monokai-pro", }

    g.colorscheme = colorschemes[2]
    g.mapleader = " "
    g.maplocalleader = "\\" -- must be different than mapleader

    -- Provider related settings for plugins created by different languages
    g.loaded_ruby_provider = 0
    g.loaded_perl_provider = 0
    -- g.loaded_python3_provider = 0
    -- g.loaded_node_provider = 0
    g.node_host_prog = "~/.npm-global/node_modules/.bin/neovim-node-host"

    -- Add custom file types
    -- see `:h vim.filetype.add`
    -- vim.filetype.add({
    --   extensions = {
    --     -- foo = 'fooscript',
    --   },
    --   filename = {
    --     -- ['.foorc'] = 'toml',
    --   }
    -- })

    -- See `:h vim.opt` for more
    local o = vim.opt

    o.autoindent = true -- copy indent level from previous line
    o.autowrite = true -- smart auto-save on some commands
    o.autowriteall = true -- smart auto-save on some commands
    o.background = "dark" -- default to dark background
    o.backup = false -- toggle backup file
    o.breakindent = true -- wrapped line continues on the same indent level
    o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- combine OS and Neovim clipboard
    o.cmdheight = 1 -- if set to 0, hides the command line, when not typing a command NOTE: Experimental
    o.complete = ".,t" -- where to get completions from
    o.completeopt = "fuzzy,menuone,noselect,popup" -- completion options (fuzzy only works on populated results)
    o.confirm = true -- popup to save file after some commands
    o.cursorline = true -- highlight the current cursor line
    o.diffopt:append({ "vertical", "iwhite", "algorithm:patience", "context:10", "indent-heuristic", "followwrap" }) -- https://vimways.org/2018/the-power-of-diff/
    o.expandtab = true -- change tab to use spaces
    o.fillchars:append({ foldopen = "", foldclose = "", fold = " ", foldsep = " ", eob = " ", }) -- special characters
    o.foldlevelstart = 99 -- default fold level
    o.foldmarker="region,endregion" -- markers for folding
    o.foldmethod = "marker" -- default fold method
    o.foldtext = "v:lua.tied.get_fold_text()" -- text for closed folds
    o.foldnestmax = 4 -- max nested fold levels
    o.grepformat = "%f:%l:%m" -- format for grep command
    o.grepprg = "rg --no-heading -n -uu -S -F" -- faster alternative to grep
    o.hidden = false -- ask to save before closing buffers
    o.hlsearch = true -- highlighting search results
    o.ignorecase = false -- see smartcase option (affects :s too)
    o.inccommand = "nosplit" -- include partial off-screen matches for search and replace
    o.incsearch = true -- show where the pattern is as you search for it
    o.iskeyword:append("-") -- consider dash as part of a word
    o.laststatus = 3 -- when to show statusline
    o.linebreak = true -- better break of long lines
    o.list = true -- show hidden chars (tabs, trailing space, etc)
    o.listchars = { tab = '»·', trail = '·', nbsp = '␣' } -- chars to use for hidden symbols
    o.mouse = "" -- disable mouse
    o.number = true -- line numbers
    o.path:append("**") -- include subdirectories in search
    o.pumblend = 10 -- transparency for popups
    o.pumheight = 0 -- max entries in a popup
    o.relativenumber = true -- relative line numbers
    o.ruler = false -- toggle statusline info at the end
    o.scrolloff = 999 -- center cursor line when scrolling
    o.selection = "old" -- don't go past line end in visual mode
    o.shiftround = true -- round indent
    o.shiftwidth = 2 -- amount of spaces on shifting
    o.shortmess:append({ W = true, I = true, c = true, C = true, s = true }) -- skip some unnecessary messages
    o.showbreak = " ⤷ " -- arrow for wrapped text
    o.showcmd = true -- whether to show partial command on last line
    o.showmode = false -- don't show vim typing mode
    o.sidescrolloff = 8 -- columns of context
    o.signcolumn = "yes" -- whether to always show the signcolumn
    o.smartcase = true -- (requires ignorecase on) ignore case when only small letters are used
    o.smartindent = true -- c-like indenting when 'indentexpr' is not used
    o.splitbelow = true -- new windows are below
    o.splitkeep = "cursor" -- don't change cursor position when splits change
    o.splitright = true -- new windows are to the right
    o.swapfile = false -- toggle swapfile
    o.tabstop = 2 -- amount of spaces on tab
    o.tagstack = false -- don't add tags manually
    o.termguicolors = true -- enables 24-bit RGB colors
    o.timeoutlen = 5000 -- time in ms to wait for mapped sequence
    o.undofile = true -- whether to use undo file
    o.undolevels = 10000 -- max number of undo changes
    o.updatetime = 250 -- used for CursorHold and swap file
    o.virtualedit = "block" -- be able to place the cursor anywhere during vis block mode
    o.wildignore:append({ "*/node_modules/*" }) -- ignore node_modules folders for completion stuff
    o.wildmode = "longest:full,full" -- command line completion
    o.winborder = "rounded" -- border around floating windows
    o.winminwidth = 5 -- min width of a window
    o.wrap = false -- line wrap
  end,
  tied.do_nothing
)

return M
