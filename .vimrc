" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" vim-which-key requires timeout.
set timeout

" TODO: Load plugins only when needed
call plug#begin('~/.vim/plugged')
    " Theme
    Plug 'srcery-colors/srcery-vim'
    " Register vim-plug as a plugin to get documentation for it in vim.
    Plug 'junegunn/vim-plug'
    " Completions using language servers. (see :CocConfig for configuration)
    Plug 'junegunn/fzf'
    " UI implementation for fzf.
    Plug 'junegunn/fzf.vim'
    " Autodetect build system.
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Use fzf instead of coc's fuzzy finder.
    Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
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
    " Show Git changes in the line number column.
    Plug 'airblade/vim-gitgutter'
    " Git plugin, somewhat like magit.
    Plug 'tpope/vim-fugitive'
    " Text objects for working with things that are surrounded by other
    " things.
    Plug 'tpope/vim-surround'
    " Lets vim-surround actions be repeated with '.'.
    Plug 'tpope/vim-repeat'
    " Provides some UNIX utilities such as :SudoWrite and :Move.
    Plug 'tpope/vim-eunuch'
    " Better text objects.
    Plug 'wellle/targets.vim'
    " Provides commands for replacing text with the contents of the clipboard.
    Plug 'svermeulen/vim-subversive'
    " Automatically enter matching (){}[]"".
    "Plug 'jiangmiao/auto-pairs'
    " Support for EditorConfig per-project style definition files.
    Plug 'editorconfig/editorconfig-vim'
    " File finder.
    Plug 'johnsyweb/vim-makeshift'
    " Fancy startup screen.
    Plug 'mhinz/vim-startify'
    " Loads of ready-made snippets.
    Plug 'honza/vim-snippets'
    " Some Rust features.
    Plug 'rust-lang/rust.vim'
    " TeX support
    Plug 'lervag/vimtex'
call plug#end()


" Color scheme.
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif
set t_Co=256
let g:srcery_italic = 1
colorscheme srcery

" Don't use vim-gitgutter's predefined mappings because they break which-key.
let g:gitgutter_map_keys = 0

" Close gitgutter previews when escape is pressed.
let g:gitgutter_close_preview_on_escape = 1

" Give gitgutter the absolute path to the git executable. Recommended by the docs.
let g:gitgutter_git_executable = '/usr/bin/git'

" Coc extensions to install. These can also be installed with :CocInstall, but
" I much prefer specifying them declaratively. FIXME: This caused Vim to
" segfault when adding 'coc-diagnostic'. Investigate.
let g:coc_global_extensions = [
    \'coc-json',
    \'coc-rust-analyzer',
    \'coc-diagnostic',
    \'coc-clangd',
    \'coc-tsserver',
    \'coc-jedi',
    \'coc-pairs',
    \'coc-yaml',
    \'coc-pyright',
    \'coc-html',
    \'coc-snippets',
    \'coc-tabnine',
    \'coc-texlab',
    \'coc-vimtex']

" Some language servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=100

" Don't give messages about completion menu matches.
set shortmess+=c

" Show the number of the current search result and the total number of search
" results in the command line.
set shortmess-=S

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

if has('syntax')
    " Enable syntax highlighting.
    syntax on
    " Highlight current line.
    set cursorline
    " Highlight column 80.
    set colorcolumn=80
endif

" But only highlight the text line, not the number in the number column. This
" can also be set to "screenline" to only highlight part of the line when the
" cursor is on a long line that is broken into multiple "screen" lines when
" displayed.
if exists('+cursorlineopt')
    set cursorlineopt=line
endif

" Load Vim's plugin for reading manpages.
if ! has('nvim')
    runtime ftplugin/man.vim
endif
" Don't search in other sections if the page wasn't found.
let g:ft_man_no_sect_fallback = 1

set formatoptions+=n " Recognize lists.
set formatoptions-=l " Break long lines in insert mode.

" Always prefer 80 columns unless overwritten by autocommands.
set textwidth=80

augroup vimrc
    autocmd!
    " Quit help and man buffers with q.
    autocmd FileType help,man nnoremap <buffer> q :silent quit<CR>

    " Use K to look up other manpages.
    autocmd FileType man nmap <buffer> K <C-]>

    " Automatically wrap text longer than 80 characters.
    " See also 'formatoptions'.
    autocmd FileType markdown,rst,asciidoc setlocal textwidth=80
    " Disable text wrapping and colorcolumn for LaTeX.
    autocmd FileType tex setlocal textwidth=0 colorcolumn=
    " Avoid splitting words when wrapping lines.
    autocmd FileType markdown,rst,asciidoc,gitcommit,tex setlocal linebreak
    " Highlight column 50 in commit messages.
    autocmd FileType gitcommit set colorcolumn=50
    " Rust uses longer lines.
    autocmd FileType rust setl colorcolumn=100 linebreak textwidth=80

    " Forward search with K in TeX files.
    autocmd FileType tex nnoremap K :call CocActionAsync('runCommand', 'latex.ForwardSearch')<CR>

    if has('spell')
        " Turn on spelling automatically for some text files.
        autocmd FileType markdown,rst,asciidoc,gitcommit,tex setlocal spell

        " Autocorrect the word under the cursor. The default mapping for &
        " doesn't seem all that useful.
        autocmd FileType markdown,rst,asciidoc,gitcommit,tex nnoremap <buffer> & 1z=
    endif

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
    " Setup formatexpr specified filetype(s).
    autocmd FileType rust,c setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    " Use autocmd to force lightline update. Recommended in
    " coc-status-lightline.
    autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

    " Highlight yanked text
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false, timeout=200, higroup="Search"}
augroup end

if has('spell') && has('syntax')
    " Disable spellcheck by default. It can be toggled with <Space>ts. This is
    " smart enough to only spellcheck within comments and strings when editing
    " code.
    set nospell

    " Treat CamelCased words sensibly.
    if exists('+spelloptions')
        set spelloptions=camel
    endif

    " Set English and Swedish as spellcheck languages. Adding "cjk" disables
    " spellchecking for East Asian characters. "sv" requires the package
    " "vim-spell-sv" on Arch. There's also a package "vim-spell-en", but the
    " files in that package already seem to be included in "vim-runtime", but
    " stored in a different directory. Weird.
    set spelllang=en,sv,cjk
    " Turn off ugly background for misspelled words.
    highlight SpellBad   ctermbg=NONE
    highlight SpellCap   ctermbg=NONE
    highlight SpellRare  ctermbg=NONE
    highlight SpellLocal ctermbg=NONE
    " Use foreground color instead.
    highlight SpellBad   ctermfg=9
    highlight SpellCap   ctermfg=12
    highlight SpellRare  ctermfg=13
    highlight SpellRare  ctermfg=14
    " And underline.
    highlight SpellBad   cterm=NONE
    highlight SpellBad   cterm=underline
endif

" Persistent undo stored in ~/vim/undo.
if has('persistent_undo')
    set undofile
    set undodir=~/.vim/undo
endif

" Don't insert an extra space after a period when joining lines with J.
set nojoinspaces

" Don't interpret numbers as octal for <C-A> and <C-X> (no "octal"). Also
" allow incrementing and decrementing of single alphabetical characters (add
" "alpha"). "bin" and "hex" are set by default.
set nrformats=bin,hex,alpha
" Handle numbers with dashes properly. Not supported by all versions of
" (neo)vim.
silent! set nrformats=bin,hex,alpha,unsigned

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

" Vim with default settings does not allow easy switching between multiple
" files in the same editor window. Users can use multiple split windows or
" multiple tab pages to edit multiple files, but it is still best to enable an
" option to allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also
" allows you to keep an undo history for multiple files when re-using the same
" window in this way. Note that using persistent undo also lets you undo in
" multiple files even in the same window, but is less efficient and is
" actually designed for keeping undo history after closing Vim entirely. Vim
" will complain if you try to quit without saving, and swap files will keep
" you safe if your computer crashes.
set hidden

if has('wildmenu')
    " Better command-line completion.
    set wildmenu
    " Make wildmenu behave more or less like zsh's tab completion.
    set wildmode=longest,full
endif

if has('cmdline_info')
    " Show partial commands in the last line of the screen.
    set showcmd
    " Display the cursor position on the last line of the screen or in the
    " status line of a window.
    set ruler
endif

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
set nomodeline

" Use the X clipboard (ctrl-C, ctrl-V, etc.) for y, d, p, and so on.
if has('nvim') || has('xterm_clipboard') || has('gui_running')
    set clipboard=unnamedplus
endif

" Use case insensitive search...
set ignorecase
" except when there are any capital letters in the search pattern.
set smartcase
if has('extra_search')
    " Highlight searches (use <C-L> to temporarily turn off highlighting; see
    " the mapping of <C-L> below).
    set hlsearch
    " Also start highlighting while the search pattern is still being typed.
    set incsearch
endif

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

" Set the terminal window's title to the current file.
if has('title')
    set title
endif

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
" 200 ms timeout for double clicking.
set mousetime=200
" Prevent mouse clicks from moving the cursor, but allow them to switch focus
" to another window. This works by setting the mark 'z', and jumping back to
" it after the mouse click has moved the cursor. Additional hackery is needed
" to preserve insert mode, but only when not switching to another window.
noremap <LeftMouse> mz<LeftMouse>g`z
inoremap <expr><silent> <LeftMouse> "<ESC>mz<LeftMouse>:call <SID>mouse_insert(" .. getpos('.')[0] .. ")<CR>"
function! s:mouse_insert(pos)
    let [l:buf, _, _, _] = getpos('.')
    normal g`zl
    if a:pos == l:buf
        startinsert
    endif
endfunction
" Make the right mouse button do what the left mouse usually does, and unmap
" the left mouse button from everything but a single click.
noremap  <RightMouse> <LeftMouse>
cnoremap <RightMouse> <LeftMouse>
noremap  <RightDrag> <LeftDrag>
cnoremap <RightDrag> <LeftDrag>
noremap  <RightRelease> <LeftRelease>
cnoremap <RightRelease> <LeftRelease>
noremap  <2-RightMouse> <2-LeftMouse>
cnoremap <2-RightMouse> <2-LeftMouse>
noremap  <3-RightMouse> <3-LeftMouse>
cnoremap <3-RightMouse> <3-LeftMouse>
noremap  <LeftDrag> <NOP>
cnoremap <LeftDrag> <NOP>
noremap  <LeftRelease> <NOP>
cnoremap <LeftRelease> <NOP>
noremap  <2-LeftMouse> <NOP>
cnoremap <2-LeftMouse> <NOP>
noremap  <3-LeftMouse> <NOP>
cnoremap <3-LeftMouse> <NOP>

" Scroll six lines for each step on the scroll wheel.
noremap <ScrollWheelUp> <ScrollWheelUp><ScrollWheelUp>
noremap <ScrollWheelDown> <ScrollWheelDown><ScrollWheelDown>
cnoremap <ScrollWheelUp> <ScrollWheelUp><ScrollWheelUp>
cnoremap <ScrollWheelDown> <ScrollWheelDown><ScrollWheelDown>

" Display line numbers on the left.
set number

" Quickly time out on keycodes, but never time out on mappings.
set notimeout ttimeout ttimeoutlen=200

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
if has('cindent')
    set cino+=l1
endif

" Print whitespace with nicer symbols. :set list to turn on.
set listchars=tab:→\ ,eol:⏎,space:·,trail:!,nbsp:␣,

" Change directory to repo root when opening a file from startify.
let g:startify_change_to_vcs_root = 1

" Custom header and footer for startify. TODO: check that we have startify.
redir => s:ver " Capture the output of :version into s:ver.
    silent version
redir END
let s:ver = split(s:ver, '\n') " Split s:ver into lines.
if has('nvim')
    let s:ver = s:ver[0]
else
    " Remove some unnecessary info and add the patch number.
    let s:ver = substitute(s:ver[0], ' (.*)', '', '') . ', ' . s:ver[1]
endif
let g:startify_custom_footer =
    \startify#pad(['Host: ' . hostname() . ', Vim: ' . s:ver])
let g:startify_custom_header = [
\'                  ::::::::::   :::   :::       :::      ::::::::   ::::::::',
\'                 :*:         :*:*: :*:*:    :*: :*:   :*:    :*: :*:    :*:',
\'                *:*        *:* *:*:* *:*  *:*   *:*  *:*        *:*',
\'               *#**:**#   *#*  *:*  *#* *#**:**#**: *#*        *#**:**#**',
\'              *#*        *#*       *#* *#*     *#* *#*               *#*',
\'             #*#        #*#       #*# #*#     #*# #*#    #*# #*#    #*#',
\'            ########## ###       ### ###     ###  ########   ########','']

" Enable 'cursorline' and hide the tildes in the left fringe in startify.
autocmd User Startified setlocal cursorline
autocmd User Startified let &l:fcs = 'eob: '

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
    \   'lineinfo': "\uE0A1 %3l:%-2v",
    \   'fileformat': '%{&fileformat==#"unix"?"LF":&fileformat==#"dos"?"CRLF":"CR"}',
    \   'readonly': "%{&readonly?\"\uE0A2\":\"\"}",
    \ },
    \ 'colorscheme': 'srcery',
    \ 'component_function': {
    \   'fugitive': 'LightlineFugitive',
    \   'function': 'LightlineFunction',
    \   'cocstatus': 'coc#status',
    \ },
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \           [ 'relativepath', 'readonly', 'function', 'modified' ],
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
    \ 'separator': { 'left': "\uE0B0", 'right': "\uE0B2" },
    \ 'subseparator': { 'left': "\uE0b1", 'right': "\uE0B3" }
    \ }

function! LightlineFunction()
    if exists('b:coc_current_function')
        return b:coc_current_function[3:]
    endif
endfunction

" Display Git branch, and counts of added/deleted/modified lines in lightline.
function! LightlineFugitive()
    if exists('*FugitiveHead')
        let branch = FugitiveHead(6)
        if branch !=# ''
            let ret = "\uE0A0 " .. branch
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

autocmd TextYankPost * call OCSYank()

function! OCSYank()
    if v:event.regname ==# ""
        echo v:event.regname
    endif
endfunction

" Always show the signcolumn, otherwise it would shift the text each time
" coc diagnostics appear/become resolved.
if exists('+signcolumn')
    set signcolumn=yes
    " Recently vim can merge signcolumn and number column into one.
    silent! set signcolumn=number
endif

" Make fzf's window 12 rows high.
let g:fzf_layout = {'window': { 'width': 1.0, 'height': 12, 'yoffset': 1.0 } }

" Make fzf's preview window take up 70% of the width (default is 50%), and use
" C-/ to toggle the preview window (default).
let g:fzf_preview_window = ['right:70%', 'ctrl-/']

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

" Which-key colors.
highlight link WhichKeySeperator Operator
highlight link WhichKeyFloating Label
highlight link WhichKeyDesc String

" Make CocFzf look like regular fzf.
let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []

" Mappings
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
  \ pumvisible() ? coc#_select_confirm() :
  \ coc#expandableOrJumpable() ?
  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Jump to next/previous position in snippet with tab/shift-tab.
let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

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

" Show the outline of the current file.
" TODO: Run a function that checks if coc has any results and fall back to
" build-in gO if not.
nnoremap <expr> gO &ft=='man' ? "gO" : ":CocFzfList outline<CR>"

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()

    if coc#float#has_scroll()
        call coc#float#scroll(1)
    elseif index(['vim','help'], &filetype) >= 0
        try
            execute 'h '.expand('<cword>')
        catch
            echohl ErrorMsg
            echo 'Sorry, no help for '.expand('<cword>')
            echohl None
        endtry
    else
        call CocAction('doHover')
    endif
endfunction

" Make Y work as it should.
map Y y$

" Make > and < stay in visual mode.
vnoremap < <gv
vnoremap > >gv

" Switch windows with H and L.
nnoremap H <C-W>W
nnoremap L <C-W>w

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

" Tell Makeshift about Meson.
let g:makeshift_systems = {
    \'meson.build': 'ninja -C builddir',
    \'Cargo.toml' : 'cargo build',
    \}

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

" Use <C-N> and <C-S-N> to go to the next/previous result of searching with
" :rg. TODO: Make this wrap around.
noremap <C-n> :lnext!<CR>
if has('gui_running')
    nnoremap <C-S-n> :lprevious!<CR>
else
    nnoremap <ESC>[78;5u :lprevious!<CR>
endif

" Go to definition.
nmap <silent> gd <Plug>(coc-definition)
" Go to type definition.
nmap <silent> gt <Plug>(coc-type-definition)
" Go to implementation.
nmap <silent> gi <Plug>(coc-implementation)
" List references.
nmap <silent> gr <Plug>(coc-references-used)
" Go to previous/next diagnostic.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Jump to previous/next Git hunk.
nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)

" Text objects for Git hunks.
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" Map function and class text objects.
" NOTE: Requires 'textDocument.documentSymbol' support from the language
" server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use S to substitute with the contents of the clipboard.
" TODO: map range substitutions, see vim-subversive's GitHub repo.
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
nnoremap <C-k> yiw:Rg <C-f>p<CR>
vnoremap <C-k> y:Rg <C-f>p<CR>

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
let g:mapleader = "\<Space>"
nnoremap <silent> <leader> :<c-u>WhichKey! g:leader<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual! g:leader<CR>

" Use - as local leader.
let g:maplocalleader = "\<BS>"

" Leader mappings.
let g:leader = {}

let g:leader['.'] = [':Files',   'Find file in cwd']
let g:leader[' '] = [':GFiles',  'Find file in project']
let g:leader[','] = [':Buffers', 'Switch buffer']

let g:leader.a   = ['<Plug>(coc-codeaction)',          'Code action']

let g:leader.A   = ['<Plug>(coc-codeaction-line)', 'Code action on line']

let g:leader.b   = {'name':     '+Buffer'}
let g:leader.b.d = [':bdelete', 'Delete']

let g:leader.c   = {'name':                        '+Coc'}
let g:leader.c.a = [':CocList diagnostics --current-buf', 'Diagnostics (current buffer)']
let g:leader.c.A = [':CocList diagnostics',               'Diagnostics']
let g:leader.c.c = [':CocFzfList commands',         'Commands']
let g:leader.c.e = [':CocList extensions',         'Extensions']
let g:leader.c.f = ['<Plug>(coc-format)',          'Format']
let g:leader.c.F = [':Format',                     'Format selected']
let g:leader.c.j = [':CocNext',                    'Next']
let g:leader.c.k = [':CocPrev',                    'Previous']
let g:leader.c.l = ['<Plug>(coc-openlink)',        'Open link']
let g:leader.c.o = [':CocFzfList outline',         'Outline']
let g:leader.c.O = [':OR',                         'Organize imports']
let g:leader.c.p = [':CocFzfListResume',           'Resume']
let g:leader.c.r = ['<Plug>(coc-rename)',          'Rename']
let g:leader.c.s = [':CocFzfList symbols',         'Symbols']
let g:leader.c.S = [':CocFzfList snippets',        'Snippets']
let g:leader.c.R = [':CocRebuild',                 'Rebuild extensions']
let g:leader.c.U = [':CocUpdateSync',              'Update extensions']
let g:leader.c.z = [':Fold',                       'Fold']

let g:leader.f   = {'name':                                    '+File/config'}
let g:leader.f.a = [':edit ~/.config/alacritty/alacritty.yml', 'Open alacritty.yml']
let g:leader.f.c = [':CocConfig',                              'Edit coc config']
let g:leader.f.C = [':PlugClean',                              'Clean plugins']
let g:leader.f.e = [':edit ~/.zshenv',                         'Open ~/.zshenv']
let g:leader.f.g = [':edit ~/.gvimrc',                         'Open ~/.gvimrc']
let g:leader.f.G = [':edit ~/.gdbinit',                        'Open ~/.gdbinit']
let g:leader.f.i = [':PlugInstall',                            'Install plugins']
let g:leader.f.l = [':CocLocalConfig',                         'Edit local coc config']
let g:leader.f.o = [':options',                                'Open options']
let g:leader.f.p = [':edit $MYVIMRC',                          'Open ~/.vimrc']
let g:leader.f.r = [':source $MYVIMRC',                        'Reload ~/.vimrc']
let g:leader.f.u = [':PlugUpdate',                             'Update plugins']
let g:leader.f.U = [':PlugUpgrade',                            'Update vim-plug']
let g:leader.f.z = [':edit ~/.zshrc.local',                    'Open ~/.zshrc.local']
let g:leader.f.Z = [':edit ~/.zshrc',                          'Open ~/.zshrc']

let g:leader.F = ['<Plug>(coc-fix-current)', 'Quickfix']

let g:leader.g     = {'name':                  '+Git'}
let g:leader.g.a   = [':Git commit --amend',   'Commit --amend']
let g:leader.g.b   = [':Git blame',            'Blame']
let g:leader.g.c   = [':Git commit',           'Commit']
let g:leader.g.d   = [':GitGutterPreviewHunk', 'Diff']
let g:leader.g.f   = [':Git fetch',            'Fetch']
let g:leader.g.F   = {'name':                  '+Pull'}
let g:leader.g.F.p = [':Git pull',             'Pull']
let g:leader.g.F.a = [':Git pull --autostash', 'Pull --autostash']
let g:leader.g.g   = [':Git',                  'Status (g? for help)']
let g:leader.g.l   = [':Git log',              'Log']
let g:leader.g.L   = [':Gllog',                'Log to location list']
let g:leader.g.p   = {'name':                  '+Push'}
let g:leader.g.p.p = [':Git push',             'Push']
let g:leader.g.s   = [':GitGutterStageHunk',   'Stage hunk']
let g:leader.g.S   = [':Gwrite',               'Save and stage current file']
let g:leader.g.x   = [':GitGutterUndoHunk',    'Discard hunk']
let g:leader.g.z   = [':GitGutterFold',        'Fold all unchanged lines']

let g:leader.h        = {'name':                        '+Help'}
let g:leader.h.g      = {'name':                        '+Miscellaneous'}
let g:leader.h.g.d    = ['<Plug>(coc-definition)',      'Go to definition']
let g:leader.h.g.t    = ['<Plug>(coc-type-definition)', 'Go to type definition']
let g:leader.h.g.i    = ['<Plug>(coc-implementation)',  'Go to implementation']
let g:leader.h.g.r    = ['<Plug>(coc-references-used)', 'Go to references']
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

let g:leader.k = ['Man', 'Open manpage']

let g:leader.m = [':silent wall | LMakeshiftBuild', 'Save and make']

let g:leader.M = [':LMakeshiftBuild', 'Make']

let g:leader.r = [':History', 'Most recently used files']

let g:leader.R = [':Startify', 'Home screen']

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
    \'GitGutter']
let g:leader.t.l = [
    \':GitGutterLineHighlightsToggle' ..
    \'| echo g:gitgutter_highlight_lines?"GitGutter line highlights enabled":"GitGutter line highlights disabled"',
    \'GitGutter line highlights']
let g:leader.t.n = [
    \':set number!' ..
    \'| echo &number?"Line numbers enabled":"Line numbers disabled"',
    \'Line numbers']
let g:leader.t.r = [
    \':set relativenumber!' ..
    \'| echo &relativenumber?"Relative line numbers enabled":"Relative line numbers disabled"',
    \'Relative line numbers']
let g:leader.t.s = [
    \':set spell!' ..
    \'| echo &spell?"Spellcheck enabled":"Spellcheck disabled"',
    \'Spellcheck']
let g:leader.t.p = [
    \':set paste!' ..
    \'| echo &paste?"Paste on":"Paste off"',
    \'Paste']
let g:leader.t.w = [
    \':set list!' ..
    \'| echo &list?"Showing whitespace":"Hiding whitespace"',
    \'Whitespace']

let g:leader.t.S      = {'name':                          '+Languages'}
let g:leader.t.S.d    = [':setlocal spelllang=de_de,cjk | set spell | echo "Set language to " .. &spl[:-5]', 'German']
let g:leader.t.S.e    = [':setlocal spelllang=en_us,cjk | set spell | echo "Set language to " .. &spl[:-5]', 'English (US)']
let g:leader.t.S.g    = [':setlocal spelllang=de_de,cjk | set spell | echo "Set language to " .. &spl[:-5]', 'German']
let g:leader.t.S.r    = [':setlocal spelllang=en,sv,cjk | set spell | echo "Set language to " .. &spl[:-5]', 'Reset']
let g:leader.t.S.s    = [':setlocal spelllang=sv,cjk | set spell | echo "Set language to " .. &spl[:-5]',    'Swedish']
let g:leader.t.S.u    = [':setlocal spelllang=en_gb,cjk | set spell | echo "Set language to " .. &spl[:-5]', 'English (UK)']

let g:leader.w      = {'name':   '+Window'}
let g:leader.w.d    = ['<C-W>q', 'Delete']
let g:leader.w.q    = ['<C-W>q', 'Delete']
let g:leader.w['='] = ['<C-W>=', 'Balance windows']

let g:leader.x = [':ScratchInsert', 'Open scratch buffer']

call which_key#register('<Space>', "g:leader")

" Local leader mappings.
augroup vimrc_localleader
    autocmd!
    let g:localleader_clangd = {}
    let g:localleader_clangd.h = [':CocCommand clangd.switchSourceHeader', 'Switch between source and header']
    let g:localleader_rust_analyzer = {}
    let g:localleader_rust_analyzer.c = [':CocCommand rust-analyzer.openCargoToml', 'Open Cargo.toml']
    let g:localleader_rust_analyzer.d = [':CocCommand rust-analyzer.openDocs', 'Open docs in browser']
    let g:localleader_rust_analyzer.e = [':CocCommand rust-analyzer.explainError', 'Explain error']
    let g:localleader_rust_analyzer.f = [':CocCommand rust-analyzer.reload', 'Reload file']
    let g:localleader_rust_analyzer.F = [':CocCommand rust-analyzer.reloadWorkspace', 'Reload workspace']
    let g:localleader_rust_analyzer.i = [':CocCommand rust-analyzer.toggleInlayHintns', 'Toggle inlay hints']
    let g:localleader_rust_analyzer.h = [':CocCommand rust-analyzer.viewHir', 'View HIR']
    let g:localleader_rust_analyzer.p = [':CocCommand rust-analyzer.parentModule', 'Go to parent module']
    let g:localleader_rust_analyzer.r = [':CocCommand rust-analyzer.run', 'Run']
    let g:localleader_rust_analyzer.s = [':CocCommand rust-analyzer.ssr', 'SSR']
    let g:localleader_rust_analyzer.t = [':CocCommand rust-analyzer.peekTests', 'Peek tests']
    let g:localleader_rust_analyzer.y = [':CocCommand rust-analyzer.syntaxTree', 'Syntax tree']
    let g:localleader_rust_analyzer.v = [':CocCommand rust-analyzer.analyzerStatus', 'Server status']
    let g:localleader_rust_analyzer.V = [':CocCommand rust-analyzer.serverVersion', 'Server version']
    let g:localleader_rust_analyzer.x = [':CocCommand rust-analyzer.expandMacro', 'Expand macro']

    autocmd FileType c,cpp call which_key#register('<BS>', "g:localleader_clangd")
    autocmd FileType c,cpp nnoremap <silent> <localleader> :<c-u>WhichKey! g:localleader_clangd<CR>
    autocmd FileType c,cpp vnoremap <silent> <localleader> :<c-u>WhichKeyVisual! g:localleader_clangd<CR>
    autocmd FileType rust call which_key#register('<BS>', "g:localleader_rust_analyzer")
    autocmd FileType rust nnoremap <silent> <localleader> :<c-u>WhichKey! g:localleader_rust_analyzer<CR>
    autocmd FileType rust vnoremap <silent> <localleader> :<c-u>WhichKeyVisual! g:localleader_rust_analyzer<CR>
augroup end
