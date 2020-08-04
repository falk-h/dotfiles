" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" vim-which-key requires timeout.
set timeout

call plug#begin('~/.vim/plugged')
    " Completions using language servers. (see :CocConfig for configuration)
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Spacemacs style popup for keybindings.
    Plug 'liuchengxu/vim-which-key'
    " Remember cursor position in files.
    Plug 'farmergreg/vim-lastplace'
    " Automatically strip trailing whitespace.
    Plug 'axelf4/vim-strip-trailing-whitespace'
    " Pop-up scratch buffer.
    Plug 'mtth/scratch.vim'
    " Lightweight statusbar.
    Plug 'itchyny/lightline.vim'
    " Color scheme.
    Plug 'chriskempson/base16-vim'
    " Color scheme for lightline.
    Plug 'mike-hearn/base16-vim-lightline'
    " Show Git changes in the line number column.
    Plug 'airblade/vim-gitgutter'
    " Git plugin, somewhat like magit.
    Plug 'tpope/vim-fugitive'
    " Text objects for working with things that are surrounded by other things.
    Plug 'tpope/vim-surround'
    " Provides some UNIX utilities such as :SudoWrite and :Move.
    Plug 'tpope/vim-eunuch'
    " Provides commands for replacing text with the contents of the clipboard.
    Plug 'svermeulen/vim-subversive'
    " Automatically enter matching (){}[]"".
    Plug 'jiangmiao/auto-pairs'
    " Support for EditorConfig per-project style definition files.
    Plug 'editorconfig/editorconfig-vim'
    " File finder.
    Plug 'junegunn/fzf'
    " UI implementation for fzf.
    Plug 'junegunn/fzf.vim'
call plug#end()


" Colorscheme
" Use 24-bit colors (I think).
if has('termguicolors')
    set termguicolors
endif

" Don't forget to change the colorscheme in g:lightline when changing this.
colorscheme base16-tomorrow-night-eighties
" Access colors present in 256 colorspace.
" See https://github.com/chriskempson/base16-vim#256-colorspace.
let base16colorspace=256

" Don't use vim-gitgutter's predefined mappings because they break which-key.
let g:gitgutter_map_keys = 0

" coc configuration.

" Some language servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting.
syntax on

" Highlight current line.
set cursorline
" But only highlight the text line, not the number in the number column. This
" can also be set to "screenline" to only highlight part of the line when the
" cursor is on a long line that is broken into multiple "screen" lines when
" displayed.
set cursorlineopt=line

" Disable spellcheck by default. It can be toggled with <Space>ts. This is
" smart enough to only spellcheck within comments and strings when editing code.
set nospell
" Treat CamelCased words sensibly.
set spelloptions=camel
" Set English and Swedish as spellcheck languages. Adding "cjk" disables
" spellchecking for East Asian characters. "sv" requires the package
" "vim-spell-sv" on Arch. There's also a package "vim-spell-en", but the files
" in that package already seem to be included in "vim-runtime", but stored in
" a different directory. Weird.
set spelllang=en,sv,cjk

" Persistent undo stored in ~/vim/undo.
set undofile
set undodir=~/.vim/undo

" Don't insert an extra space after a period when joining lines with J.
set nojoinspaces

" Don't interpret numbers as octal for <C-A> and <C-X> (no "octal"). Also
" allow incrementing and decrementing of single alphabetical characters (add
" "alpha"). "bin" and "hex" are set by default.
set nrformats=bin,hex,alpha

" Store swap files in /tmp if possible, otherwise in the same directory as the
" file that is being edited.
set directory=/tmp//,.

" Display the last line in the buffer, even if it doesn't fit entirely. If
" this isn't set, long lines aren't displayed at all if they don't fit
" entirely. It's also possible to add "uhex" here to display unprintable
" characters as hex instead of as ^@, ^M, etc.
set display=lastline

" Don't redundantly show the mode in the status line. Lightline already shows
" it.
set noshowmode

" Don't redraw the screen while macros are executing. Possibly try turning
" this off if there are visual bugs. Use <C-L> to redraw manually.
set lazyredraw

" Indicate to Vim that the terminal it's running in is fast. This is set by
" default if $TERM is xterm or rxvt, but it's nice to set this explicitly in
" case I switch to a terminal emulator that doesn't pretend to be xterm.
set ttyfast

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Better command-line completion. TODO: possibly set wildmode.
set wildmenu

" Show partial commands in the last line of the screen.
set showcmd

" Show the number of the current search result and the total number of search
" results in the command line.
set shortmess-=S

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
set nomodeline

" Use the X clipboard (ctrl-C, ctrl-V, etc.) for y, d, p, and so on.
set clipboard=unnamedplus

" Use case insensitive search...
set ignorecase
" except when there are any capital letters in the search pattern.
set smartcase
" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below).
set hlsearch
" Also start highlighting while the search pattern is still being typed.
set incsearch

" Larger search/command history. Also affects CtrlP.
set history=200

" Ignore case when completing file names.
set wildignorecase
" Ignore case when using file names. Not sure what "using" means here.
set fileignorecase

" Allow backspacing over autoindent, line breaks and start of insert action.
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
"  same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window.
set ruler

" Always display the status line, even if only one window is displayed.
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong.
set visualbell

" Enable use of the mouse for all modes.
set mouse=a
" Right click extends the selection, as opposed to opening a context menu,
" since that only works in GUI mode anyway.
set mousemodel=extend

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue".
set cmdheight=1

" Highlight column 80.
set colorcolumn=80

" Automatically wrap text longer than 80 characters. See also 'formatoptions'.
set textwidth=80

" Display line numbers on the left.
set number

" Quickly time out on keycodes, but never time out on mappings.
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'.
set pastetoggle=<F11>

" Add the g flag to substitutions by default.
set gdefault

" Indentation options

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=4
set softtabstop=4
set expandtab

" Put closing braces inside switch cases on the same indentation level as the
" case label. See cino-l.
set cino+=l1

" Print whitespace with nicer symbols. :set list to turn on.
set listchars=tab:→\ ,eol:⏎,space:·,trail:!,nbsp:␣,

"if executable('rg')
"    " Use ripgrep to search if available.
"    let &grepprg='rg --column --line-number --no-heading --smart-case'
"
"    " Use ripgrep instead of CtrlP's built in search because it's faster.
"    let g:ctrlp_user_command = 'rg --files --color=never %s'
"    " Also disable caching as ripgrep is fast enough that we don't need it.
"    let g:ctrlp_use_caching = 0
"    set grepformat=%f:%l:%c:%m
"endif

" Don't close scratch buffer when leaving insert mode.
let g:scratch_insert_autohide = 0

" Open scratch buffer at the bottom.
let g:scratch_top = 0

" Persist scratch buffer across vim restarts, but not across reboots.
let g:scratch_persistence_file = '/tmp/vimscratch'

" Disable default scratch mappings. Use which-key instead.
let g:scratch_no_mappings = 1

" Use nice powerline-y symbols
let g:lightline = {
    \ 'component': {
    \   'lineinfo': ' %3l:%-2v',
    \   'fileformat': '%{&fileformat==#"unix"?"LF":&fileformat==#"dos"?"CRLF":"CR"}',
    \   'readonly': '%{&readonly?"":""}',
    \ },
    \ 'colorscheme': 'base16_tomorrow_night_eighties',
    \ 'component_function': {
    \   'fugitive': 'LightlineFugitive',
    \   'cocstatus': 'coc#status',
    \ },
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \           [ 'relativepath', 'readonly', 'modified' ],
    \           [ 'cocstatus' ] ],
    \   'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'fileformat', 'fileencoding', 'filetype', 'fugitive' ] ],
    \ },
    \ 'inactive': {
    \   'left': [ [ 'relativepath' ] ],
    \   'right': [ [ 'lineinfo' ],
    \            [ 'percent' ] ],
    \ },
    \ 'tabline': {
    \   'left': [ [ 'tabs' ] ],
    \   'right': [ [ 'close' ] ] ,
    \ },
    \ 'subseparator': { 'left': '│', 'right': '│' }
    \ }

" Display Git branch, and counts of added/deleted/modified lines in lightline.
function! LightlineFugitive()
    if exists('*FugitiveHead')
        let branch = FugitiveHead(6)
        if branch !=# ''
            let ret = ' ' .. branch
            let [added, modified, deleted] = GitGutterGetHunkSummary()
            if added != 0
                let ret = ret .. ' +' .. added
            endif
            if modified != 0
                let ret = ret .. ' ~' .. modified
            endif
            if deleted != 0
                let ret = ret .. ' -' .. deleted
            endif
            return ret
        endif
    endif
    return ''
endfunction

" Use autocmd to force lightline update. Recommended in coc-status-lightline.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Always show the signcolumn, otherwise it would shift the text each time
" coc diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one.
  set signcolumn=number
else
  set signcolumn=yes
endif

" Make EditorConfig not affect Fugitive buffers. This is recommended by the
" EditorConfig README.
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Fall through to native key mappings when a key is pressed that hasn't been
" mapped through which-key.
let g:which_key_fallback_to_native_key = 1

" Use a popup window instead of opening a regular window. This way, all of the
" other windows aren't shifted around when which-key opens.
let g:which_key_use_floating_win = 1

" Update which-key mappings every time the popup is displayed. This has
" negligible performance impact according to the which-key help file.
let g:which_key_run_map_on_popup = 1

" Don't shift the popup over a bit to avoid covering the line number column.
" This feature doesn't seem to work anyway, and the popup ends up covering
" half of the number column.
let g:which_key_disable_default_offset = 1

" Mappings
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Make Y work as it should.
map Y y$

" Make > and < stay in visual mode.
vnoremap < <gv
vnoremap > >gv

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search, and close the location list.
nnoremap <C-L> :nohl<bar>:lclose<CR><C-L>

" Make ctrl-backspace delete the previous word in insert and command mode.
if &runtimepath =~ 'auto-pairs'
    " NOTE: This workaround is required because AutoPairs maps <C-h>.
    " See https://vi.stackexchange.com/a/17587.
    let g:AutoPairsMapCh = 0
    inoremap <silent> <C-h> <C-R>=AutoPairsDelete()<CR><C-w>
    cnoremap <C-h>  <C-w>
else
    noremap! <C-h> <C-w>
endif
" For Gvim.
noremap! <C-BS> <C-w>

" Map <C-P> and <C-S-P> to paste like p and P, but always linewise. This is
" useful when pasting from the system clipboard. Note: this requires terminal
" emulator support. See https://stackoverflow.com/a/2179779 and
" ~/.config/alacritty/alacritty.yml.
nnoremap <C-p> :put<CR>
if has('gui_running')
    nnoremap <C-S-p> :put!<CR>
else
    nnoremap <ESC>[80;5u :put!<CR>
endif

" Use <C-N> and <C-S-N> to go to the next/previous result of searching with :rg.
" TODO: Make this wrap around.
noremap <C-n> :lnext!<CR>
if has('gui_running')
    nnoremap <C-S-n> :lprevious!<CR>
else
    nnoremap <ESC>[78;5u :lprevious!<CR>
endif

" Go to definition.
nmap <silent> gd <Plug>(coc-definition)
" Go to type definition.
nmap <silent> gy <Plug>(coc-type-definition)
" Go to implementation.
nmap <silent> gi <Plug>(coc-implementation)
" List references.
nmap <silent> gr <Plug>(coc-references)
" Go to previous/next diagnostic.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Jump to previous/next Git hunk.
nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)

" Make text objects for {}()[]<> jump forwards in the current line if there is a
" pair of delimiters in the current line.
" TODO: Make this work. This is intended to also catch opening parentheses on
" the same line, even if the closing parenthesis is on another line.
"onoremap a( :<C-u>execute "normal /\%#.*\zs[()]\rva("<CR>
onoremap a[ :<C-u>normal! hf]va[<CR>
onoremap a] :<C-u>normal! hf]va[<CR>
onoremap i[ :<C-u>normal! hf]vi[<CR>
onoremap i] :<C-u>normal! hf]vi[<CR>
onoremap a< :<C-u>normal! hf>va<<CR>
onoremap a> :<C-u>normal! hf>va<<CR>
onoremap i< :<C-u>normal! hf>vi<<CR>
onoremap i> :<C-u>normal! hf>vi<<CR>
onoremap a( :<C-u>normal! hf)va(<CR>
onoremap a) :<C-u>normal! hf)va(<CR>
onoremap ab :<C-u>normal! hf)va(<CR>
onoremap i( :<C-u>normal! hf)vi(<CR>
onoremap i) :<C-u>normal! hf)vi(<CR>
onoremap ib :<C-u>normal! hf)vi(<CR>
onoremap a{ :<C-u>normal! hf}va{<CR>
onoremap a} :<C-u>normal! hf}va{<CR>
onoremap aB :<C-u>normal! hf}va{<CR>
onoremap i{ :<C-u>normal! hf}vi{<CR>
onoremap i} :<C-u>normal! hf}vi{<CR>
onoremap iB :<C-u>normal! hf}vi{<CR>

" Text objects for Git hunks.
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" Map function and class text objects.
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use S to substitute with the contents of the clipboard. TODO: map range
" substitutions, see vim-subversive's GitHub repo.
nmap S  <Plug>(SubversiveSubstitute)
nmap SS <Plug>(SubversiveSubstituteLine)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR     :call CocAction('runCommand', 'editor.action.organizeImport')

" Shortcut for ripgrep.
"command! -nargs=+ -complete=file Rg
"    \ execute 'silent lgrep! <args>' | redraw! | lwindow | lfirst
" TODO: Echo the number of results.
"| echo getloclist(0, {'size': 1})['size'] .. ' results'
cabbrev rg Rg

" Search for the current word or currently selected text with <C-k>
nnoremap <C-k> viwy:Rg ""<C-f>hP<CR>
vnoremap <C-k> y:Rg ""<C-f>hP<CR>

" Save file as root with :sw.
cabbrev sw SudoWrite

" Make :w, :q and :a case insensitive.
cabbrev W   w
cabbrev Q   q
cabbrev wQ  wq
cabbrev Wq  wq
cabbrev WQ  wq
cabbrev qA  qa
cabbrev Qa  qa
cabbrev QA  qa
cabbrev wqA wqa
cabbrev wQa wqa
cabbrev wQA wqa
cabbrev WqA wqa
cabbrev WQa wqa
cabbrev WQA wqa
" Also make :waq an alias for :wqa
cabbrev waq wqa
cabbrev waQ wqa
cabbrev wAq wqa
cabbrev wAQ wqa
cabbrev Waq wqa
cabbrev WaQ wqa
cabbrev WAq wqa
cabbrev WAQ wqa

" Unbind space, and use it as leader.
let g:mapleader="\<Space>"
nnoremap <silent> <leader> :WhichKey "<Space>"<CR>
vnoremap <silent> <leader> :WhichKeyVisual "<Space>"<CR>

" Leader mappings.
let g:leader = {}

let g:leader['.'] = [':Files',   'Find file in cwd']
let g:leader[' '] = [':GFiles',  'Find file in project']
let g:leader[','] = [':Buffers', 'Switch buffer']

let g:leader.a   = {'name':                            '+Actions'}
let g:leader.a.a = ['<Plug>(coc-codeaction-selected)', 'Code action on selected']
let g:leader.a.c = ['<Plug>(coc-codeaction)',          'Code action']
let g:leader.a.f = ['<Plug>(coc-fix-current)',         'Fix current']

let g:leader.b   = {'name':     '+Buffer'}
let g:leader.b.d = [':bdelete', 'Delete']

let g:leader.c   = {'name':                        '+Coc'}
let g:leader.c.a = [':CocList diagnostics',        'Diagnostics']
let g:leader.c.c = [':CocList commands',           'Commands']
let g:leader.c.e = [':CocList extensions',         'Extensions']
let g:leader.c.f = ['<Plug>(coc-format-selected)', 'Format selected']
let g:leader.c.F = ['<Plug>(coc-format)',          'Format']
let g:leader.c.j = [':CocNext',                    'Next']
let g:leader.c.k = [':CocPrev',                    'Previous']
let g:leader.c.l = ['<Plug>(coc-openlink)',        'Open link']
let g:leader.c.o = [':CocList outline',            'Outline']
let g:leader.c.O = [':OR',                         'Organize imports']
let g:leader.c.p = [':CocListResume',              'Resume']
let g:leader.c.r = ['<Plug>(coc-rename)',          'Rename']
let g:leader.c.s = [':CocList -I symbols',         'Symbols']
let g:leader.c.R = [':CocRebuild',                 'Rebuild extensions']
let g:leader.c.U = [':CocUpdateSync',              'Update extensions']
let g:leader.c.z = [':Fold',                       'Fold']

let g:leader.f   = {'name':             '+File/config'}
let g:leader.f.c = [':CocConfig',       'Edit coc config']
let g:leader.f.C = [':PlugClean',       'Clean plugins']
let g:leader.f.g = [':edit ~/.gvimrc',  'Open ~/.gvimrc']
let g:leader.f.i = [':PlugInstall',     'Install plugins']
let g:leader.f.o = [':options',         'Open options']
let g:leader.f.p = [':edit $MYVIMRC',   'Open ~/.vimrc']
let g:leader.f.r = [':source $MYVIMRC', 'Reload ~/.vimrc']
let g:leader.f.u = [':PlugUpdate',      'Update plugins']
let g:leader.f.U = [':PlugUpgrade',     'Update vim-plug']

let g:leader.g     = {'name':                  '+Git'}
let g:leader.g.b   = [':Git blame',            'Blame']
let g:leader.g.c   = [':Git commit',           'Commit']
let g:leader.g.f   = [':Git fetch',            'Fetch']
let g:leader.g.F   = {'name':                  '+Pull'}
let g:leader.g.F.p = [':Git pull',             'Pull']
let g:leader.g.F.a = [':Git pull --autostash', 'Pull --autostash']
let g:leader.g.g   = [':Git',                  'Status (g? for help)']
let g:leader.g.p   = {'name':                  '+Push'}
let g:leader.g.p.p = [':Git push',             'Push']
let g:leader.g.P   = [':GitGutterPreviewHunk', 'Preview hunk']
let g:leader.g.s   = [':GitGutterStageHunk',   'Stage hunk']
let g:leader.g.S   = [':Gwrite',               'Save and stage current file']
let g:leader.g.x   = [':GitGutterUndoHunk',    'Discard hunk']
let g:leader.g.z   = [':GitGutterFold',        'Fold all unchanged lines']

let g:leader.h        = {'name':                        '+Help'}
let g:leader.h.g      = {'name':                        '+Miscellaneous'}
let g:leader.h.g.d    = ['<Plug>(coc-definition)',      'Go to definition']
let g:leader.h.g.y    = ['<Plug>(coc-type-definition)', 'Go to type definition']
let g:leader.h.g.i    = ['<Plug>(coc-implementation)',  'Go to implementation']
let g:leader.h.g.r    = ['<Plug>(coc-references)',      'Go to references']
let g:leader.h['[']   = {'name':                        '+['}
let g:leader.h['['].d = ['<Plug>(coc-diagnostic-prev)', 'Previous diagnostic']
let g:leader.h[']']   = {'name':                        '+]'}
let g:leader.h[']'].d = ['<Plug>(coc-diagnostic-next)', 'Next diagnostic']
let g:leader.h.z      = {'name':                        '+Folds/spelling'}
let g:leader.h.z['='] = ['z=',                          'Correct word']
let g:leader.h.z.g    = ['zg',                          'Add good to persistent dict']
let g:leader.h.z.G    = ['zG',                          'Add good to temp dict']
let g:leader.h.z.w    = ['zw',                          'Add bad to persistent dict']
let g:leader.h.z.W    = ['zW',                          'Add bad to temp dict']
let g:leader.h.z.u    = {'name':                        '+Undo'}
let g:leader.h.z.u.g  = ['zug',                         'Undo add good to persistent dict']
let g:leader.h.z.u.G  = ['zuG',                         'Undo add good to temp dict']
let g:leader.h.z.u.w  = ['zuw',                         'Undo add bad to persistent dict']
let g:leader.h.z.u.W  = ['zuW',                         'Undo add bad to temp dict']

let g:leader.r = [':History', 'Most recently used files']

let g:leader.s      = {'name':       '+Search'}
let g:leader.s['/'] = [':History/',  'Search history']
let g:leader.s[':'] = [':History:',  'Command history']
let g:leader.s.c    = [':Commits',   'Commits']
let g:leader.s.C    = [':BCommits',  'Commits for current buffer']
let g:leader.s.e    = [':Commands',  'Commands']
let g:leader.s.f    = [':Filetypes', 'File types']
let g:leader.s.h    = [':Helptags',  'Help']
let g:leader.s.m    = [':Maps',      'Mappings']
let g:leader.s.t    = [':Tags',      'Tags']
let g:leader.s.T    = [':BTags',     'Tags in current buffer']

let g:leader.t   = {'name': '+Toggles'}
let g:leader.t.g = [
    \':GitGutterToggle' ..
    \'| echo g:gitgutter_enabled?"GitGutter enabled":"GitGutter disabled"',
    \'Git gutter']
let g:leader.t.l = [
    \':GitGutterLineHighlightsToggle' ..
    \'| echo g:gitgutter_highlight_lines?"Line highlights enabled":"Line highlights disabled"',
    \'Git gutter line highlights']
let g:leader.t.s = [
    \':set spell!' ..
    \'| echo &spell?"Spellcheck enabled":"Spellcheck disabled"',
    \'Spellcheck']
let g:leader.t.w = [
    \':set list!' ..
    \'| echo &list?"Showing whitespace":"Hiding whitespace"',
    \'Whitespace']

let g:leader.w      = {'name':   '+Window'}
let g:leader.w.d    = ['<C-W>q', 'Delete']
let g:leader.w.q    = ['<C-W>q', 'Delete']
let g:leader.w['='] = ['<C-W>=', 'Balance windows']

let g:leader.x = [':ScratchInsert', 'Open scratch buffer']

call which_key#register('<Space>', "g:leader")
