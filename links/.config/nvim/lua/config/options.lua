local M = {}

M.setup = tie(
  "setup options",
  function()
    -- See `:h vim.g` for more
    local g = vim.g

    -- defined in the plugins/colorschemes folder
    local colorschemes = { "kanagawa", "tokyonight", "monokai-pro", }

    g.colorscheme = colorschemes[1]
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
    vim.filetype.add({
      extensions = {
        -- foo = 'fooscript',
      },
      filename = {
        -- ['.foorc'] = 'toml',
      }
    })

    -- Track last pressed keys
    -- g.last_keys = {}
    -- g.last_keys_id = vim.on_key(tie(
    --   "save last pressed keys",
    --   function(_raw, key)
    --     if not key or #key <= 0 then return end
    --
    --     key = vim.fn.keytrans(key)
    --
    --     local last_keys = g.last_keys
    --
    --     table.insert(last_keys, key)
    --
    --     if #last_keys > 5 then
    --       table.remove(last_keys, 1)
    --     end
    --
    --     -- must save in vim.g.table in the end
    --     g.last_keys = last_keys
    --   end,
    --   function() g.last_keys = {} end
    -- ), vim.api.nvim_create_namespace("key_tracker"))

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
    o.diffopt = "vertical,iwhite,filler" -- vimdiff split direction and ignore whitespace
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
    o.ignorecase = false -- see smartcase option (affects search and replace too)
    o.inccommand = "nosplit" -- include partial off-screen matches for search and replace
    o.incsearch = true -- show where the pattern is as you search for it
    o.iskeyword:append("-") -- consider dash as part of a word
    o.laststatus = 3 -- when to show statusline
    o.linebreak = true -- better break of long lines
    o.list = true -- show hidden chars (tabs, trailing space, etc)
    o.listchars = { tab = '»·', trail = '·', nbsp = '␣' } -- chars to use for hidden symbols
    o.maxmempattern = 20000 -- increase max memory for pattern matching
    o.mouse = "" -- disable mouse
    o.number = true -- line numbers
    o.path:append("**") -- include subdirectories in search
    o.pumblend = 10 -- transparency for popups
    o.pumheight = 10 -- max entries in a popup
    o.redrawtime = 10000 -- increase redraw time for syntax handling
    o.relativenumber = false -- relative line numbers
    o.scroll = 20 -- lines to move on <C-d>/<C-u>
    o.scrolloff = 10 -- min lines below and above
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
    o.smartindent = false -- c-like indenting when 'indentexpr' is not used
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
  do_nothing
)

return M
