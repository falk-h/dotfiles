local o = vim.o
local opt = vim.opt

-- Set 'nocompatible' to ward off unexpected things that your distro might have made, as well as sanely reset options
-- when re-sourcing .vimrc
o.compatible = false

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
o.updatetime = 100

-- Highlight current line.
o.cursorline = true

-- Highlight column 80.
o.colorcolumn = '120'

-- Always prefer 80 columns unless overwritten by autocommands.
o.textwidth = 80

-- Some language servers have issues with backup files, see #649.
o.backup = false
o.writebackup = false

o.cmdheight = 2

o.inccommand = 'nosplit'

o.termguicolors = true

opt.shortmess:append {
    -- Don't give messages about completion menu matches.
    c = true,
    -- Show the number of the current search result and the total number of search results in the command line.
    S = false,
}

opt.formatoptions:append {
    -- Recognize lists.
    n = true,
    -- Break long lines in insert mode.
    l = false,
}

-- Treat CamelCased words sensibly.
o.spelloptions = 'camel'

-- Set English and Swedish as spellcheck languages. Adding "cjk" disables spellchecking for East Asian characters. "sv"
-- requires the package "vim-spell-sv" on Arch. There's also a package "vim-spell-en", but the files in that package
-- already seem to be included in "vim-runtime", but stored in a different directory. Weird.
opt.spelllang = { 'en', 'sv', 'cjk' }

o.undofile = true

-- Don't insert an extra space after a period when joining lines with J.
o.joinspaces = false

-- Handle numbers with dashes properly.
opt.nrformats = { 'bin', 'hex', 'unsigned' }

-- Store swap files in /tmp if possible, otherwise in the same directory as the file that is being edited.
opt.directory = { '/tmp//', '.' }

-- Don't redundantly show the mode in the status line. Lightline already shows it.
o.showmode = false

-- Don't redraw the screen while macros are executing. Possibly try turning this off if there are visual bugs.
-- Use <C-L> to redraw manually.
o.lazyredraw = true

-- Allow for having buffers opened in the background.
o.hidden = true

-- Make wildmenu behave more or less like zsh's tab completion.
opt.wildmode = { 'longest', 'full' }

-- Modelines have historically been a source of security vulnerabilities. As such, it may be a good idea to disable them
-- and use the securemodelines script, <http://www.vim.org/scripts/script.php?script_id=1876>.
o.modeline = false

-- Use the X clipboard (ctrl-C, ctrl-V, etc.) for y, d, p, and so on.
o.clipboard = 'unnamedplus'

-- Use case insensitive search...
o.ignorecase = true
-- except when there are any capital letters in the search pattern.
o.smartcase = true

-- Ignore case when completing file names.
o.wildignorecase = true
-- Ignore case when using file names. Not sure what "using" means here.
o.fileignorecase = true

-- Set the terminal window's title to the current file.
o.title = true

-- Instead of failing a command because of unsaved changes, raise a dialogue asking if you wish to save changed files.
o.confirm = true

-- Use visual bell instead of beeping when doing something wrong.
o.visualbell = true

-- Enable use of the mouse for all modes.
o.mouse = 'ra'
-- 200 ms timeout for double clicking.
o.mousetime = 200

-- Display line numbers on the left.
o.number = true

-- How long to wait for a mapped sequence to complete. Also controls which-key's delay.
o.timeoutlen = 300

-- Add the g flag to substitutions by default.
o.gdefault = true

-- Indentation settings for using 4 spaces instead of tabs.
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true

-- << and >> should always shift to a multiple of shiftwidth.
o.shiftround = true

-- See cinoptions-values.
opt.cinoptions = {
    -- Put closing braces inside switch cases on the same indentation level as the case label.
    'l1',
    -- Don't add extra indentation in `extern "C"` blocks
    'E-s',
    -- Don't indent function return types. It's unclear if this does anything, as Vim doesn't seem to indent function
    -- return types anyway. See cino-t.
    't0',
    -- Indent at the same level as unclosed parentheses. See cino-(.
    '(0',
    -- Indent function arguments by 8 spaces when no argument is on the same line as the function's name.
    'W2s',
    -- Put lone closing parentheses at the same indent level as the line with the opening parenthesis.
    'm1',
}

o.laststatus = 3

-- Print whitespace with nicer symbols. :set list to turn on.
o.listchars = 'tab:→ ,eol:⏎,space:·,trail:!,nbsp:␣,'

-- Show diagnostic signs in the number column.
o.signcolumn = 'number'

-- Completion menu options. This setting was recommended by nvim-cmp.
opt.completeopt = { 'menu', 'menuone', 'noselect' }
