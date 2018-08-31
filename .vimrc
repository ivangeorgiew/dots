"COMMENTS {{{
" AG rare options:
" -v something(inverse searching)
" --ignore file/dir(ignore those files/dirs)
"
" Execute this for profiling what slows down vim
" :profile start profile.log | profile func * | profile file *
" " At this point do slow actions
" :profile pause | noautocmd qall!

" Move between empty lines - '{', '}'

" (?!(?:badword|second|\*)) search for not one of these words/characters
" ; to repeat f/t (, to reverse it)
" C-g/C-t to go to next match while / searching

" Macro
" qe...q (e can be any letter)
" qE...q to append (E can be any letter)
" :let @e='<c-r><c-r>e then edit and append '<CR>

"Gstatus (vim-fugitive) commands in vim
" [ ] - move between files
" - - adds/removes file to commit
" U - removes file changes
" dp - show changes to uncommited files
" D - open file with Gdiff
" p - stash -p

" commentary.vim
" gcc - comment line (takes number as well)

"Increment and Decrement numbers commands
"X to increment, <C-x> to decrement

" Mappings for vim-surround (* = [',",{,tag,...])
" ys* - add surrounds for word
" S* - add surrounds motion
" cs* - change surrounds
" ds* - delete surrounds
" S* - add surrounds in visual mode

" Go back to previous location <C-o>
" Go to next location<C-i>

" :e! to reload file
" <C-w> in command line deletes word backwards

"<leader>o - close all buffers except the one you're in

"Vimdiff
"<leader>1 - toggle vimdiff for vertsplit
"du - re-scan the files for differences
"do - diff obtain (2 windows)
"dp - diff put (2 windows)
"dh - get code from left (3 windows)
"dl - get code from right (3 windows)
"<leader>[ - next difference
"<leader>] - previous difference

"Completion
"<C-x><C-l> line completion
"<C-x><C-f> filename completion
"<C-x><C-o> omnicompletion
"<C-n> normal completion
"<C-y> selected value and close completion
"<C-e> initial value and close completion

"Ctrl-p shortcuts
"<C-f> cycle between modes
"<C-d> search by filename only
"<C-z> mark mutliple files to be opened

"Tab close direction by default is to the right
"this is confusing since you open tabs to the right
"use TabClose() function instad of tabclose to solve this

" YouCompleteMe
" <C-space> - semantic completion
" <C-w> - remove word
" <C-y> - accept completion

" EasyClip - Built-in fixes for incorrect actions
" Automatically indents - if not correct use <leader>ff
" r(motion) - replace with * buffer
" "ar(motion) - replace with 'a' buffer
" C-b/C-f - after paste choose previous or next yank

" Convert words
" snake_case (crs),
" MixedCase (crm),
" camelCase (crc),
" snake_case (crs),
" UPPER_CASE (cru),
" dash-case (cr-),
" dot.case (cr.),
" space case (cr<space>),
" Title Case (crt)

" Subvert words
" :%S/old_word{,s}/new_word{,s}/gc

" auto-pairs
" There are alot more settings in the github page
" deleting the first character of a pair deletes the whole pair
" space and enter adds niceness
" pressing twice the symbol doest add two pairs (YAY)
" don't add closing pair when needed

" Folding
" custom markers for compatibility with WebStorm
" z; - fold/unfold
" zl - fold/unfold deeply
" Z - toggle fold || create fold(vis selection)
" zj/zk - move between folds
"COMMENTS }}}

"OLDCODE {{{
" function! TabClose()
"   if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
"     tabclose | tabprev
"   else
"     q
"   endif
" endfunction
"
" Go to definitions using the silver searcher (no need when using tags)
" Search for js variable
" let g:jsConstRegex = '^(export) (?:var|let|const|function|class)(?:\*| \* | \*| )('
" nnoremap <silent><expr> gj 'lbve"by:tabe<CR>:AgNoLoc "' . g:jsConstRegex . '<C-r>b[ (])"<CR>zz:if (line("$") == 1)<CR>call TabClose()<CR>endif<CR>'
" nnoremap <silent><expr> gJ 'lbve"by:vnew<CR>:AgNoLoc "' . g:jsConstRegex . '<C-r>b[ (])"<CR>zz:if (line("$") == 1)<CR>bd<CR>endif<CR>'
" nnoremap <silent><expr> go 'lbve"by:AgNoLoc "' . g:jsConstRegex . '<C-r>b[ (])"<CR>zz'
"
" Fix register copy/pasting
" nnoremap DD "*dd
" nnoremap D "*d
" vnoremap D "*d
" nnoremap d "_d
" nnoremap dd "_dd
" vnoremap d "_d
" nnoremap s "_s
" vnoremap s "_s
" nnoremap c "_c
" vnoremap c "_c
" nnoremap x "_x
" vnoremap x "_x
" vnoremap p "_c<Esc>:set paste<cr>a<C-r>*<Esc>:set nopaste<cr>
"OLDCODE }}}

"MISC {{{
" Add pathogen execution on startup
execute pathogen#infect()
execute pathogen#helptags()

" Change between block and I-beam cursor
if system("uname -s") =~ "Linux"
    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[4 q"
    let &t_EI = "\<Esc>[2 q"
endif

" set Vim-specific sequences for RGB colors
" let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
" let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" set termguicolors
" set t_Co=256
set background=dark
colorscheme gruvbox

" Fix lag in vim
set shell=bash
set lazyredraw
set nocursorcolumn
set regexpengine=0
set synmaxcol=256 "fixes lag from long lines
" set colorcolumn=120  " slows alot
" set cursorline " slows and unnecessary
"MISC }}}

"SET {{{
" Common
set smartcase                              " Needed for correct work with CtrlP
set scroll=10                              " Set scroll lines
set nocompatible                           " Use Vim settings, rather then Vi settings
set nobackup                               " dont make backups
set nowritebackup                          " dont make backups
set noswapfile                             " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set swapsync=""                            " Don't write swap file to disk
set showcmd                                " display incomplete commands
set autowrite                              " Automatically :write before running commands
set clipboard=unnamedplus,unnamed          " Copy/paste to/from clipboard by default
set sessionoptions=curdir,tabpages,winsize " save only this information in session
set nojoinspaces                           " Only one space when joining lines
set list listchars=tab:»·,trail:·          " show trailing whitespace
set virtualedit=block                      " allow cursor to move where there is no text in v-block
set breakindent                            " wrapped line continues on the same indent level
set timeoutlen=500                         " waittime for second mapping
set hlsearch                               " hightlight search
set wrapscan                               " incsearch after end of file
set noshowmode                             " dont show vim mode
set updatetime=800                         " time after which the CursorHold events will fire
set wrap                                   " if on - wrap too long lines
set notagstack                             " don't add tags manually
set viminfo='20,s100,h,f0,n~/.vim/.viminfo " viminfo settings
set scrolloff=10                           " min lines below and above
set redrawtime=5000                        " increase redraw time for syntax handling

" Folding
set foldmethod=manual
set foldmarker=region,endregion            " markers for folding
" set foldlevelstart=0
set foldlevel=0
set foldtext=FoldText()

" Indentations
set tabstop=4
set shiftwidth=4
set expandtab

" Numbers
set number
set numberwidth=5

" Persistent undo
set undodir=~/.vim/undo/
set undofile
set undolevels=1000
set undoreload=10000

" Complete on the bottom of vim (:tabe /bla/ for example)
set wildmenu
set wildmode=longest:full,full

" insert completion
set completeopt=menuone,longest,noselect
set complete=.,t

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

"Vimdiff options
set diffopt=vertical,iwhite,filler " vimdiff split direction and ignore whitespace

"Silver searcher
set grepprg=ag
"SET }}}

"AUGROUP {{{
if system("uname -s") =~ "Linux"
    augroup linuxAutoCommands
        au!
        " Affects lag
        au BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set relativenumber   | endif
        au BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set norelativenumber | endif

        " remain with clipboard after closing
        au VimLeave * call system("xclip -r -o -sel clipboard | xclip -r -sel clipboard")
    augroup END
endif

augroup syntax
    au!

    "Wrap character color
    au VimEnter,Colorscheme * hi! NonText term=bold ctermbg=236 guibg=#32302f ctermfg=245 guifg=#928374

    " Switch syntax for strange file endings
    au BufNewFile,BufRead *.ejs setl filetype=html
    au BufNewFile,BufRead *.babelrc setl filetype=json
    au BufNewFile,BufRead *.sass setl filetype sass
    au BufNewFile,BufRead *.eslintrc setl filetype=json

    "Fix some keywords in css and scss
    au FileType css setlocal iskeyword+=-
    au FileType scss setlocal iskeyword+=-
augroup END

augroup UltiSnips
    au!

    au! User UltiSnipsEnterFirstSnippet
    au User UltiSnipsEnterFirstSnippet call autocomplete#setup_mappings()
    au! User UltiSnipsExitLastSnippet
    au User UltiSnipsExitLastSnippet call autocomplete#teardown_mappings()
augroup END

augroup folding
    au!

    au FileType vim setl foldmarker={{{,}}} |
                \ setl foldmethod=marker

    au FileType javascript.jsx setl foldmethod=expr |
                \ setl foldexpr=FoldExprJS()

    au FileType cucumber setl foldmethod=expr |
                \ setl foldexpr=FoldExprCucumber()
augroup END

augroup highlights
    au!

    au BufEnter * hi! MyError ctermbg=Red guibg=#fb4934

    " au BufEnter * hi! link OverLength MyError

    " Ale highlights
    au BufEnter * hi! link ALEError MyError
    au BufEnter * hi! link ALEWarning MyError
    au BufEnter * hi! link ALEErrorSign MyError

    au BufEnter * hi! DiffAdd    term=bold cterm=reverse ctermbg=236 gui=reverse guibg=#32302f ctermfg=142 guifg=#b8bb26
    au BufEnter * hi! DiffChange term=bold cterm=reverse ctermbg=236 gui=reverse guibg=#32302f ctermfg=142 guifg=#b8bb26
    au BufEnter * hi! DiffDelete term=bold cterm=reverse ctermbg=236 gui=reverse guibg=#32302f ctermfg=167 guifg=#fb4934
    au BufEnter * hi! DiffText   term=reverse cterm=reverse  ctermbg=236 gui=reverse  guibg=#32302f ctermfg=208 guifg=#fe8019
augroup END

augroup vimrcEx
    au!

    "overwrite some vim-sensible options
    au BufRead,BufNewFile * setglobal tags=tags
    au BufRead,BufNewFile *.js setl textwidth=120
    au BufRead,BufNewFile *.md setl textwidth=80

    au BufEnter * set formatoptions=rjcl foldtext=FoldText()
    au BufEnter *.js setl synmaxcol=3000

    " Ask whether to save the session on exit
    au VimLeavePre * call SaveSession()
augroup END
" AUGROUP }}}

"SETTINGS {{{
"JSX for .js files as well
let g:jsx_ext_required = 0

" Disabled matching of paranteses for folding speed
let loaded_matchparen = 1

" Variables for FoldExprJS
let s:tabstop = 4
let s:prevBracketIndent = -1
let s:bracketIndent = -1
let s:inMarker = 0
let s:inImportFold = 0
let s:comment = '\s*\(\/\/\|\/\*\|\*\/\)'
let s:importString = '^' . s:comment . '*\s*\(import \)'
let s:fromString = "\\( from '.*'\\)"
let s:marker1 = '^' . s:comment . '.*\( region\)\s*'
let s:marker2 = '^' . s:comment . '.*\( endregion\)\s*'
let s:elseStatement = '\( else \)'
let s:startBracket = '\w.*\({\|(\|[\)\s*\(\/\/.*\)*$'
let s:endBracket = '^' . s:comment . '*\s*\(}\|)\|]\)'
let s:nonStarterFolds = '^' . s:comment . '*\s*\(||\|&&\|else\|case\|.*\s*class\s\|module\.exports\)\s*'

" variable for ToggleWrapscan function
let s:wrapscanVariable = 1

" Change NERDTree mappings
let g:NERDTreeMapOpenInTab='<C-t>'
let g:NERDTreeMapOpenInTabSilent='<C-r>'
let g:NERDTreeMapOpenVSplit='<C-v>'
let g:NERDTreeWinSize=30
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['node_modules', '.git', '.DS_Store']

"Mundo (undo history) settings
let g:mundo_width = 40
let g:mundo_preview_height = 25
let g:mundo_preview_bottom = 1
let g:mundo_close_on_revert = 1

" ALE configurations
let g:ale_enabled = 1
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1
let g:ale_linters = {
            \'javascript': ['eslint'],
            \'scss': ['scsslint'],
            \'json': ['jsonlint']
            \}
" eslint fixer removes last fold lines
" DONT fix with javascript with eslint, since it will make mistakes
let g:ale_fixers = {
            \'scss': ['prettier'],
            \'json': ['prettier']
            \}
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_on_insert_leave = 0
let g:ale_set_highlights = 1
let g:ale_set_signs = 0

"The Silver Searcher https://github.com/ggreer/the_silver_searcher
let g:grep_cmd_opts = '--line-numbers --noheading'
" Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
let g:ctrlp_cmd='CtrlP :pwd'
let g:ctrlp_user_command = 'ag --hidden %s -l -g ""'
let g:ctrlp_show_hidden = 1
" ag is fast enough that CtrlP doesn't need to cache
let g:ctrlp_use_caching = 0
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20'
" open file even if already opened
let g:ctrlp_switch_buffer = ''
" open multiple files in new tabs and jump to first one
let g:ctrlp_open_multiple_files = 'tj'
let g:ctrlp_reuse_window = 'GV'
let g:ag_prg = 'ag --hidden --column --nogroup --noheading -s'

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Arrow for wrapped text
if has('linebreak')
    let &showbreak='⤷ '
endif

" Rooter
let g:rooter_patterns = ['pom.xml']
let g:rooter_silent_chdir = 1

" Gutentags settings
let g:gutentags_project_root = ['package.json']
let g:gutentags_exclude_project_root = ['/usr/local']
let g:gutentags_generate_on_empty_buffer = 1
let g:gutentags_add_default_project_roots = 0
" let g:gutentags_file_list_command = 'find . -name "**.js*"'

" YouCompleteMe settings
" keys
let g:ycm_key_list_select_completion = ['<C-n>']
let g:ycm_key_list_previous_completion = ['<C-p>']
let g:ycm_key_list_stop_completion = ['<C-y>']
let g:ycm_key_invoke_completion = '<C-Space>'
" completions include
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
" enable ycm only in those filetypes
" let g:ycm_filetype_whitelist = { 'javascript.jsx': 1, 'css': 1, 'scss': 1, 'json': 1, 'cucumber': 1 }
" remove semantic competion in javascript
let g:ycm_filetype_specific_completion_to_disable = { 'javascript': 1, 'python': 1 }
" etc
let g:ycm_filepath_completion_use_working_dir = 0
" let g:ycm_semantic_triggers =  {
"   \   'c' : ['->', '.'],
"   \   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
"   \             're!\[.*\]\s'],
"   \ }
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_complete_in_comments = 1
let g:ycm_cache_omnifunc = 1
let g:ycm_use_ultisnips_completer = 1
let g:ycm_max_num_candidates = 10
let g:ycm_max_num_identifier_candidates = 10
" disable console logs
let g:ycm_show_diagnostics_ui = 1
" Start vim faster
" let g:ycm_start_autocmd = 'CursorHold,CursorHoldI'
if system("uname -s") =~ "Linux"
    let g:ycm_server_python_interpreter = '/usr/bin/python'
else
    let g:ycm_server_python_interpreter = '/usr/bin/python2.7'
endif

" UltiSnips
" keys
let g:UltiSnipsExpandTrigger = '<Tab>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
" directory
let g:UltiSnipsSnippetsDir = '~/.vim/ultisnips'
let g:UltiSnipsSnippetDirectories = ['ultisnips']
" Prevent UltiSnips from removing our carefully-crafted mappings.
let g:UltiSnipsMappingsToIgnore = ['autocomplete']

" EasyClip settings
let g:EasyClipAutoFormat = 1
let g:EasyClipPreserveCursorPositionAfterYank = 1
let g:EasyClipAlwaysMoveCursorToEndOfPaste = 0
let g:EasyClipUseSubstituteDefaults = 0
let g:EasyClipUseCutDefaults = 0
let g:EasyClipUsePasteToggleDefaults = 0

" auto-pairs settings
let g:AutoPairsShortcutToggle = 'F8'
let g:AutoPairsMapCh = 0
let g:AutoPairsMultilineClose = 0
let g:AutoPairsShortcutJump = ''
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutBackInsert = ''
let g:AutoPairsCenterLine = 0

" FastFold
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  []
let g:fastfold_fold_movement_commands = []

" Airline
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 1
let g:airline_extensions = [ 'ctrlp', 'ale', 'branch' ]
let g:airline_highlighting_cache = 0
let g:airline_theme = 'gruvbox'

" gruvbox
let g:gruvbox_bold = 0
let g:gruvbox_italic = 0
let g:gruvbox_contrast_dark = 'soft'
let g:gruvbox_contrast_light = 'soft'

"vim-lastplace
let g:lastplace_open_folds = 0
"SETTINGS }}}

"FUNCTIONS {{{
function! CloseBuffer()
    " when exiting the Git Status window
    if &ft == 'gitcommit'
        set nopreviewwindow
    endif

    if tabpagenr('$') > 1
        execute 'q'
    else
        execute 'bd'
    endif

    "add the fugitive commands for the buffer
    call fugitive#detect(getcwd())
endfunction

function GitStatus()
    exec "Gstatus"
    exec "normal \<C-W>k"

    if line('$') == 1 && getline(1) == ''
        exec 'bd'
    else
        exec "normal! \<C-W>j"
    endif
endfunction

function! MoveCurrentFile()
    let old_destination = expand('%:p:h')
    let filename = expand('%:t')
    call inputsave()
    let new_destination = input('New destination: ', expand('%:p:h'), 'file')
    call inputrestore()
    if new_destination != '' && new_destination != old_destination
        exec ':saveas ' . new_destination . '/' . filename
        exec ':silent !rm ' . old_destination . '/' . filename
        redraw!
    endif
endfunction

function! RenameCurrentFile()
    let old_name = expand('%')
    call inputsave()
    let new_name = input('New file name: ', expand('%:t:r'))
    call inputrestore()
    if new_name != '' && new_name != old_name
        if expand('%:e') != '' && new_name !~ '\.'
            exec ':saveas ' . expand('%:h'). '/' . new_name . '.' . expand('%:e')
        else
            exec ':saveas ' . expand('%:h'). '/' . new_name
        endif
        call delete(old_name)
        redraw!
        exec ':e!'
    endif
endfunction

function! SaveSession()
    let dirPath = fnamemodify('%', ':~:h:t')
    if expand('%:p') =~ "projects"
        let choice = confirm('Save Session ?',"&Yes\n&No", 1)
        if choice == 1
            execute 'mksession! ~/.vim/session/'.dirPath
        endif
    endif
endfunction

function! OpenSession()
    let dirPath = fnamemodify('%', ':~:h:t')
    let file = '~/.vim/session/'.dirPath
    if glob(file)!=#""
        execute 'source '.file
    endif
endfunction

function! FileReplaceIt(visual)
    let expression = @b
    if a:visual == 0
        call inputsave()
        let expression = input('Enter expression:')
        call inputrestore()
    endif
    call inputsave()
    let replacement = input('Enter replacement:')
    call inputrestore()
    if a:visual == 0
        execute '%sno@'.expression.'@'.replacement.'@gc'
    else
        execute '%sno@\<'.expression.'\>@'.replacement.'@gc'
    endif
endfunction

function! VisReplaceIt()
    call inputsave()
    let expression = input('Enter expression:')
    call inputrestore()
    call inputsave()
    let replacement = input('Enter replacement:')
    call inputrestore()
    execute "%sno@\\%V".expression."@".replacement."@gc"
endfunction

function! MassReplaceIt()
    call inputsave()
    let fullWord = confirm('Only full words ?',"&Yes\n&No", 1)
    call inputrestore()
    call inputsave()
    let expression = input('Enter expression:')
    call inputrestore()
    call inputsave()
    let replacement = input('Enter replacement:')
    call inputrestore()
    if fullWord == 1
        execute 'cfdo %sno@\<'.expression.'\>@'.replacement.'@g | update'
    else
        execute 'cfdo %sno@'.expression.'@'.replacement.'@g | update'
    endif
endfunction

function! PasteMultipleWords()
    call inputsave()
    let withCommas = confirm('With commas ?',"&Yes\n&No", 1)
    call inputrestore()
    normal! "cp
    if withCommas == 2
        execute "normal! mb^"
        execute "s/, /\r/g"
        execute "silent normal! V`b="
        execute "redraw!"
    endif
endfunction

function! ToggleDiff()
    if &diff
        execute "windo diffoff"
    else
        execute "windo diffthis"
    endif
endfunction

function! ToggleWrapscan()
    if s:wrapscanVariable == 0
        let s:wrapscanVariable = 1
        execute "set wrapscan"
        echo 'Wrapscan Enabled'
    else
        let s:wrapscanVariable = 0
        execute "set nowrapscan"
        echo 'Wrapscan Disabled'
    endif
endfunction

function! s:align()
    let p = '^\s*|\s.*\s|\s*$'
    if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
        let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
        let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
        Tabularize/|/l1
        normal! 0
        call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
    endif
endfunction

function! IndentWithI()
    if len(getline('.')) == 0 && empty(&buftype)
        return "\"_cc"
    else
        return "i"
    endif
endfunction

function! FoldText()
    return getline(v:foldstart)
endfunction

function! FoldExprCucumber()
    let l = getline(v:lnum)
    let nl = getline(v:lnum + 1)

    if l =~ '^\s*#*\s*\(Scenario\)'
        return '1>'
    endif

    if nl =~ '^\s*$'
        return '<1'
    endif

    return '='
endfunction

function! FoldExprJS()
    let pl = getline(v:lnum - 1)
    let l = getline(v:lnum)
    let nl = getline(v:lnum + 1)

    if !s:inImportFold && l =~ s:importString
        let s:inImportFold = 1
        return '>4'
    endif

    if s:inImportFold && l =~ s:fromString && nl !~ s:importString
        return '<4'
    endif

    if s:inImportFold && pl =~ s:fromString && l !~ s:importString
        let s:inImportFold = 0
        return '0'
    endif

    if l =~ s:marker1
        let s:inMarker = 1
        return 'a1'
    endif

    if l =~ s:marker2
        let s:inMarker = 0
        return 's1'
    endif

    if !s:inMarker && !s:inImportFold
        " gotta catch comments as well
        let lind = count(substitute(l, '\([^\/ ].*\)$', '', 'g'), ' ') / s:tabstop + 1

        " Keep the startBracket check last for performance
        if lind < 4 && l !~ s:nonStarterFolds && l =~ s:startBracket && l !~ s:endBracket
            let s:prevBracketIndent = s:bracketIndent
            let s:bracketIndent = lind
            return 'a1'
        endif

        " Keep the endBracket check last for performance
        if lind < 4 && lind == s:bracketIndent && l =~ s:endBracket && l !~ s:startBracket
            let s:bracketIndent = s:prevBracketIndent
            let s:prevBracketIndent = s:prevBracketIndent - 1
            return 's1'
        endif
    endif

    return '='
endfunction

function! GoToTag(type, word)
    if a:type == 'tab'
        if taglist(a:word) == []
            execute "normal! $h\<c-w>gf"
        else
            :tabe
            execute ':tjump ' . a:word
            :normal zz
            let l:tagFilename = expand('%:t')
            if l:tagFilename == ''
                :tabclose
                :tabprevious
            endif
        endif
    endif

    if a:type == 'vsplit'
        if taglist(a:word) == []
            normal! $h
            execute "vertical wincmd f"
        else
            :vnew
            execute ':tjump ' . a:word
            :normal zz
            let l:tagFilename = expand('%:t')
            if l:tagFilename == ''
                :bd
            endif
        endif
    endif

    if a:type == 'current'
        if taglist(a:word) == []
            execute "normal! $hgf"
        else
            execute ':tjump ' . a:word
            :normal zz
        endif
    endif
endfunction

function! JoinSpaceless()
    normal! $J

    let currCol = col('.')
    let centerChar = matchstr(getline('.'), '\%' . currCol . 'c.')
    let leftChar = matchstr(getline('.'), '\%' . (currCol - 1) . 'c.')
    let rightChar = matchstr(getline('.'), '\%' . (currCol + 1) . 'c.')

    if centerChar =~ '\s' && (leftChar =~ '[(>]' || rightChar =~ '[\.<]')
        normal! x
    endif
endfunction

function! FastGit(args)
    if a:args == 'lg' || a:args == 'log'
        execute 'silent! GV'
    elseif a:args == 'ss'
        call GitStatus()
    elseif a:args =~ '^ac '
        let message = substitute(a:args, '^ac ', '', '')
        execute 'silent! Gcommit -m ' . message
    elseif a:args =~ '^sch'
        execute 'GitFugitive ' . a:args
    else
        execute 'Dispatch! git ' . a:args
    endif
endfunction
"FUNCTIONS }}}

"MAPPINGS {{{
map <Space> <leader>
" Main leader Mappings
noremap <silent> <leader>q :qall<CR>
noremap <silent> <leader>w :update<CR>
noremap <silent> <leader>d :call CloseBuffer()<CR>
noremap <silent> <leader>t :tabclose<CR>

" indent everything
nnoremap <leader>I gg=G
" copy everything
nnoremap <leader>Y ggVGy
" replace everything
nmap <leader>R ggVGr

" Folding mappings
" fold less
nnoremap zn zr
" Unfold all
nnoremap zN zR
" unmap it
nnoremap Z <ESC>
" open/close fold recursively
nnoremap z; zA
" open/close fold
nnoremap zl za
" force fold update folds
nmap zuz <Plug>(FastFoldUpdate)

"NERDTree
noremap <F9> :NERDTreeFind<CR><C-W>=
noremap <F10> :NERDTreeToggle<CR><C-W>=

"C-X to decrement, X to increment
nnoremap X <C-a>

" Get off my lawn
nnoremap <Left>     :echoerr "Use h"<CR>
nnoremap <Right>    :echoerr "Use l"<CR>
nnoremap <Up>       :echoerr "Use k"<CR>
nnoremap <Down>     :echoerr "Use j"<CR>

" Cmd navigation
cnoremap <C-A> <Home>
cnoremap <C-J> <S-Left>
cnoremap <C-K> <S-Right>
cnoremap <C-H> <Left>
cnoremap <C-L> <Right>

"Vimdiff
"diff 2 buffers in vertical split
nnoremap <silent> <leader>1 :call ToggleDiff()<cr>
nnoremap <silent> <leader>o :only<CR>
nnoremap <silent> <leader>[ ]c
nnoremap <silent> <leader>] [c
nnoremap <silent> du :diffupdate<CR>
nnoremap <silent> dh :diffget //2<CR>\|:diffupdate<CR>
nnoremap <silent> dl :diffget //3<CR>\|:diffupdate<CR>

"Git (vim-fugitive) mappings
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gm :Gmerge<CR>
command! -nargs=1 Git call FastGit(<q-args>)
cnoreabbrev git Git

" Navigations between tabs
nnoremap <silent> H gT
nnoremap <silent> L gt

" Go to file under cursor
nnoremap <silent> gt lbve"by:call GoToTag('tab', @b)<CR>
nnoremap <silent> gs lbve"by:call GoToTag('vsplit', @b)<CR>
nnoremap <silent> go lbve"by:call GoToTag('current', @b)<CR>
command! -nargs=1 -complete=tag Gt call GoToTag('tab', <f-args>)
command! -nargs=1 -complete=tag Gs call GoToTag('vsplit', <f-args>)
command! -nargs=1 -complete=tag Go call GoToTag('current', <f-args>)

" Search and replace
nnoremap <silent> <F2> :call FileReplaceIt(0)<cr>
vnoremap <silent> <F2> "by:call FileReplaceIt(1)<cr>
vnoremap <silent> <F3> :<C-u>call VisReplaceIt()<cr>
nnoremap <silent> <F12> :call MassReplaceIt()<cr>

" EasyClip
" cut
nmap D <Plug>MoveMotionPlug
xmap D <Plug>MoveMotionXPlug
nmap DD <Plug>MoveMotionLinePlug
" replace
nmap <silent> r <plug>SubstituteOverMotionMap
xmap r <plug>XEasyClipPaste
nmap <silent> R <plug>SubstituteToEndOfLine
nmap rr <plug>SubstituteLine
" change yank buffer
nmap <C-B> <plug>EasyClipSwapPasteForward
nmap <C-F> <plug>EasyClipSwapPasteBackwards
" paste from default register in insert mode
inoremap <silent> <C-E> <C-r>+
" Paste content before or after line
nmap <silent> <leader>p o<ESC>p
nmap <silent> <leader>P O<ESC>P
" format last pasted text
nnoremap <leader>ff `[v`]=

" jk to exit insertmode (delete characters to beginning of line if only whitespace)
inoremap <silent><expr> jk getline('.') =~ '^\s\+$' && empty(&buftype) ? '<ESC>:call setline(line("."), "")<CR>' : '<ESC>'

" Move tab left and right
nnoremap <silent> th :tabm -1<cr>
nnoremap <silent> tl :tabm +1<cr>

" Save session
noremap <silent> <F7> :call SaveSession()<cr>

" Load previous session
noremap <silent> <F5> :call OpenSession()<cr>

" Copy multiple words to register
nnoremap <silent> <leader>8 lbve"cy
nnoremap <silent> <leader>9 :let @c .= ', '<cr>lbve"Cy
nnoremap <silent> <leader>0 :call PasteMultipleWords()<CR>

" Space to new line in vis selection
vnoremap K :<C-u>s@\%V @$%@g<cr>mb:s/$%/\r/g<cr>V`b=:noh<CR>
nnoremap K mb^v$:<C-u>s@\%V @$%@g<cr>mb:s/$%/\r/g<cr>V`b=:noh<CR>

"ALE
"jump on next error
nmap <leader>an <Plug>(ale_next_wrap)
nmap <leader>ap <Plug>(ale_previous_wrap)
"fix errors automatically
nnoremap <leader>af :ALEFix<CR>
"enable/disable
nnoremap <leader>ae :ALEEnable<CR>
nnoremap <leader>ad :ALEDisable<CR>
"manual lint
nnoremap <leader>al :ALELint<CR>

"Incsearch
nnoremap / /\V\c
"search backwards
nnoremap ? ?\V\c
"search in visual selection
vnoremap <leader>/ <ESC>/\%V\V\c
"search the copied content
nnoremap <silent> // :let @/ = '\V\c' . escape(@+, '\\/.*$^~[]')<CR>n
"search the selected
vnoremap <silent> // "by:let @/ = '\V\c' . escape(@b, '\\/.*$^~[]')<CR>n
"toggle search highlight
nnoremap <silent><expr> <leader>l (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

"Toggle wrapscan
nnoremap <silent> <leader>s :call ToggleWrapscan()<CR>

" Set marker
nnoremap * m

" Move to the next word
nnoremap <silent> n n:silent! norm! zv<CR>zz
nnoremap <silent> N N:silent! norm! zv<CR>zz
nnoremap <silent> m *:silent! norm! zv<CR>zz
nnoremap <silent> M #:silent! norm! zv<CR>zz

" Macro mappings
" @*<CR> to apply macro in * for everyline in visual selection
vnoremap @ :normal @
" Repeat 'e' macro if in a normal buffer
nnoremap <silent><expr> <CR> empty(&buftype) ? ':normal @@<CR>' : '<CR>'
vnoremap <silent><expr> <CR> empty(&buftype) ? ':normal @@<CR>' : '<CR>'

" Mundo (undo history) toggle
nnoremap <F1> :MundoToggle<CR>

" Silver searcher
" -F for no regex, -w for word search
nnoremap ) :Ag! -F<SPACE>
vnoremap <silent> ) "by:let @b = escape(@b, '"')<CR>:Ag! -F -w "<C-r>b"<CR>
vnoremap <silent> )) "by:let @b = escape(@b, '"')<CR>:Ag! "<C-r>b"<CR>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Center page when moving up or down
nnoremap <C-d> 25jzz
nnoremap <C-u> 25kzz

" File manipulation
cnoremap <expr> %% expand('%:h').'/'
" Open file for editing
cnoreabbrev te tabe
cnoreabbrev vs vsplit
" Copy file content into a new file
nmap <leader>fs :sav! %%
" Rename current file "
nnoremap <leader>fr :call RenameCurrentFile()<cr>
" Move current file "
nnoremap <leader>fm :call MoveCurrentFile()<cr>
" Delete current file "
nnoremap <silent> <leader>fD :call delete(expand('%')) \| bdelete!<CR>

" import-js mappings
nnoremap <silent> <leader>ia :ImportJSWord<CR>:silent! normal! zO<CR>
nnoremap <silent> <leader>if :ImportJSFix<CR>:silent! normal! zO<CR>

" Make using Ctrl+C do the same as Escape, to trigger autocmd
inoremap <C-c> <Esc>

" Remove suspending
vnoremap <C-z> <Esc>

" Tmux mapping
map <C-g> <Esc>

" tabular + vim-cucumber mapping
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

" don't go to the end of line char
xnoremap <expr> $ mode() == "v" ? "g_" : "$"

"smart indent when entering insert mode with i on empty lines
nnoremap <expr> i IndentWithI()

"more sensible mappings
map <leader><leader> <Esc>

" ability to end macro inside quicklist
noremap Q q

" Gutentags update
nnoremap <silent> tu :GutentagsUpdate!<CR>:redraw!<CR>

" Join spaceless
nnoremap <silent> J :call JoinSpaceless()<CR>

" go to next/prev line even if it is wrapped
nnoremap j gj
nnoremap k gk

" Abbreviations
ab teh the
ab cosnt const
ab prosp props
"MAPPINGS }}}
