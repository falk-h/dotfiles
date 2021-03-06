" GVim options

" Disable cursor blinking in all modes. TODO: Maybe enable it in insert and
" command mode.
set guicursor+=a:blinkon0

" Use dark theme variant if available.
set guioptions+=d

" Hide the menu bar.
set guioptions-=m

" Hide the toolbar.
set guioptions-=T

" Hide the scrollbar.
set guioptions-=r

" Hide the left hand scrollbar when there's a vertical split.
set guioptions-=L

" Keep the window the same size when a scrollbar, tabline or toolbar is added
" or removed.
set guioptions+=k

" Enable the context menu for right clicks.
set mousemodel=popup_setpos

" Set size on startup.
set columns=140
set lines=45

" Font
if has('gui_gtk2') || has('gui_gtk3')
    " Linux font.
    set guifont=Roboto\ Mono\ 10
elseif has('gui_win32')
    " Windows font. TODO.
    set guifont=Roboto\ Mono\ 10
endif
