" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" vim-which-key requires timeout
set timeout

call plug#begin('~/.vim/plugged')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vim-which-key'
    Plug 'farmergreg/vim-lastplace'
    Plug 'axelf4/vim-strip-trailing-whitespace'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'mtth/scratch.vim'
    Plug 'jacoborus/tender.vim'
    Plug 'itchyny/lightline.vim'
    Plug 'tpope/vim-fugitive'
    Plug 'chriskempson/base16-vim'
    Plug 'mike-hearn/base16-vim-lightline'
call plug#end()

" Colorscheme
" Use 24-bit colors (I think)
if (has('termguicolors'))
    set termguicolors
endif

" Don't forget to change the colorscheme in g:lightline when changing this
colorscheme base16-tomorrow-night-eighties
" Access colors present in 256 colorspace.
" See https://github.com/chriskempson/base16-vim#256-colorspace
let base16colorspace=256

" coc configuration

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

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

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

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

"" Map function and class text objects
"" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on

" Highlight current line.
set cursorline
" But only highlight the text line, not the number in the number column. This
" can also be set to "screenline" to only highlight part of the line when the
" cursor is on a long line that is broken into multiple "screen" lines when
" displayed.
set cursorlineopt=line

" Enable spellcheck. This is smart enough to only spellcheck within comments
" when editing code.
set spell
" Set English and Swedish as spellcheck languages. Adding "cjk" disables
" spellchecking for East Asian characters. "sv" requires the package
" "vim-spell-sv" on Arch. There's also a package "vim-spell-en", but the files
" in that package already seem to be included in "vim-runtime", but stored in
" a different directory. Weird.
set spelllang=en,sv,cjk

" Persistent undo stored in ~/vim/undo
set undofile
set undodir=~/.vim/undo

" Automatically re-read a file when it is updated on disk.
set autoread

" Don't insert an extra space after a period when joining lines with J.
set nojoinspaces

" Don't interpret numbers as octal for <C-A> and <C-X> (no "octal"). Also
" allow incrementing and decrementing of single alphabetical characters (add
" "alpha"). "bin" and "hex" are set by default.
set nrformats=bin,hex,alpha

" Store swap files in /tmp if possible, otherwise in the same directory as the
" file that is being edited.
set directory=/tmp,.

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

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion. TODO: possibly set wildmode.
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
set nomodeline

" Use the X clipboard (ctrl-C, ctrl-V, etc.) for y, d, p, and so on.
set clipboard=unnamedplus

"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Ignore case when completing file names.
set wildignorecase
" Ignore case when using file names. Not sure what "using" means here.
set fileignorecase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visual bell is set, and
" this line is also included, vim will neither flash nor beep. If visual bell
" is unset, this does nothing.
"set t_vb=

" Enable use of the mouse for all modes
set mouse=a
" Right click extends the selection, as opposed to opening a context menu,
" since that only works in GUI mode anyway.
set mousemodel=extend

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=1

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


" Indentation options
"
" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=4
set softtabstop=4
set expandtab

" Also include the currently open file in CtrlP results
let g:ctrlp_match_current_file = 1

" Make <C-P> and <C-N> work as they should in CtrlP buffers
let g:ctrlp_prompt_mappings = {
    \ 'PrtSelectMove("j")':   ['<c-j>', '<down>', "<c-n>"],
    \ 'PrtSelectMove("k")':   ['<c-k>', '<up>', '<c-p>'],
    \ 'PrtHistory(-1)':       [],
    \ 'PrtHistory(1)':        [],
    \ }

" Don't close scratch buffer when leaving insert mode.
let g:scratch_insert_autohide = 0

" Open scratch buffer at the bottom.
let g:scratch_top = 0

" Persist scratch buffer across vim restarts, but not across reboots.
let g:scratch_persistence_file = '/tmp/vimscratch'

" Disable default scratch mappings
let g:scratch_no_mappings = 1

" Use nice powerline-y symbols
let g:lightline = {
	\ 'component': {
	\   'lineinfo': ' %3l:%-2v',
	\ },
        \ 'colorscheme': 'base16_tomorrow_night_eighties',
	\ 'component_function': {
        \   'fileformat': 'LightlineFileformat',
	\   'readonly': 'LightlineReadonly',
	\   'fugitive': 'LightlineFugitive',
	\ },
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \           [ 'readonly', 'filename', 'modified' ] ],
        \   'right': [ [ 'lineinfo' ],
        \            [ 'percent' ],
        \            [ 'fileformat', 'fileencoding', 'filetype', 'fugitive' ] ],
        \ },
        \ 'inactive': {
        \   'left': [ [ 'filename' ] ],
        \   'right': [ [ 'lineinfo' ],
        \            [ 'percent' ] ],
        \ },
        \ 'tabline': {
        \   'left': [ [ 'tabs' ] ],
        \   'right': [ [ 'close' ] ] ,
        \ },
	\ }

let LightlineFileformat = {-> &fileformat == 'unix' ? 'LF'
                          \ : &fileformat == 'dos' ? 'CRLF' : 'CR' }

let LightlineReadonly = {-> &readonly ? '' : ''}

function! LightlineFugitive()
    if exists('*FugitiveHead')
        let branch = FugitiveHead(6)
        return branch !=# '' ? ' '..branch : ''
    endif
    return ''
endfunction

" Mappings
" Make Y work as it should
map Y y$

" Make > and < stay in visual mode
vnoremap < <gv
vnoremap > >gv

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Make ctrl-backspace delete the previous word in insert mode
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

" Unbind space, and use it as leader
let g:mapleader="\<Space>"
nnoremap <silent> <leader> :WhichKey "<Space>"<CR>
vnoremap <silent> <leader> :WhichKeyVisual "<Space>"<CR>

let g:which_key_fallback_to_native_key = 1
let g:which_key_use_floating_win = 1
let g:which_key_run_map_on_popup = 1

let g:leader = {}

let g:leader['.'] = [":CtrlPCurWD",     "Find file"]
let g:leader[' '] = [":CtrlP",          "Find file in project"]
let g:leader[','] = [":CtrlPBuffer",    "Switch buffer"]
let g:leader.x = [":ScratchInsert",     "Open scratch buffer"]

let g:leader.a   = {'name':'Code actions...'}
let g:leader.a.a = ["<Plug>(coc-codeaction-selected)",  "Code action on selected"]
let g:leader.a.c = ["<Plug>(coc-codeaction)",           "Code action"]
let g:leader.a.f = ["<Plug>(coc-fix-current)",          "Fix current"]

let g:leader.c   = {'name':"Coc..."}
let g:leader.c.a = [":CocList diagnostics",         "Diagnostics"]
let g:leader.c.c = [":CocList commands",            "Commands"]
let g:leader.c.e = [":CocList extensions",          "Extensions"]
let g:leader.c.f = ["<Plug>(coc-format-selected)",  "Format"]
let g:leader.c.j = [":CocNext",                     "Next"]
let g:leader.c.k = [":CocPrev",                     "Previous"]
let g:leader.c.l = ["<Plug>(coc-openlink)",         "Open link"]
let g:leader.c.o = [":CocList outline",             "Outline"]
let g:leader.c.o = [":CocList outline",             "Outline"]
let g:leader.c.p = [":CocListResume",               "Resume"]
let g:leader.c.r = ["<Plug>(coc-rename)",           "Rename"]
let g:leader.c.s = [":CocList -I symbols",          "Symbols"]
let g:leader.c.R = [":CocRebuild",                  "Rebuild extensions"]
let g:leader.c.U = [":CocUpdateSync",               "Update extensions"]

let g:leader.f = {'name':'File...'}
let g:leader.f.p = [":e $MYVIMRC", "Open ~/.vimrc"]
let g:leader.f.o = [":options", "Open options"]

let g:leader.b   = {'name':"Buffer..."}
let g:leader.b.d = [":bdelete", "delete"]

let g:leader.h = {}
let g:leader.h.g = {'name':'Miscellaneous...'}
let g:leader.h.g.d = ["<Plug>(coc-definition)", "Go to definition"]
nmap <silent> gd <Plug>(coc-definition)
let g:leader.h.g.y = ["<Plug>(coc-type-definition)", "Go to type definition"]
nmap <silent> gy <Plug>(coc-type-definition)
let g:leader.h.g.i = ["<Plug>(coc-implementation)", "Go to implementation"]
nmap <silent> gi <Plug>(coc-implementation)
let g:leader.h.g.r = ["<Plug>(coc-references)", "Go to references"]
nmap <silent> gr <Plug>(coc-references)
let g:leader.h['['] = {'name':'+['}
let g:leader.h['['].d = ["<Plug>(coc-diagnostic-prev)", "Previous diagnostic"]
nmap <silent> [g <Plug>(coc-diagnostic-prev)
let g:leader.h[']'] = {'name':'+]'}
let g:leader.h[']'].d = ["<Plug>(coc-diagnostic-next)", "Next diagnostic"]
nmap <silent> ]g <Plug>(coc-diagnostic-next)
let g:leader.h.z = {'name':'Folds and spelling...'}
let g:leader.h.z['='] = ["z=", "Correct word"]
let g:leader.h.z.g = ["zg", "Add good to persistent dict"]
let g:leader.h.z.G = ["zG", "Add good to temp dict"]
let g:leader.h.z.w = ["zw", "Add bad to persistent dict"]
let g:leader.h.z.W = ["zW", "Add bad to temp dict"]
let g:leader.h.z.u = {'name':'Undo...'}
let g:leader.h.z.u.g = ["zug", "Undo add good to persistent dict"]
let g:leader.h.z.u.G = ["zuG", "Undo add good to temp dict"]
let g:leader.h.z.u.w = ["zuw", "Undo add bad to persistent dict"]
let g:leader.h.z.u.W = ["zuW", "Undo add bad to temp dict"]

let g:leader.w   = {'name':"+window"}
let g:leader.w.d = ["<C-W>q", "Delete"]
let g:leader.w.q = ["<C-W>q", "Delete"]
let g:leader.w['='] = ["<C-W>=", "Balance windows"]

call which_key#register('<Space>', "g:leader")
