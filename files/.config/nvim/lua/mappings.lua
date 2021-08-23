local which_key = require 'which-key'
local gitsigns = require 'gitsigns'
local telescope = require 'telescope.builtin'
local u = require 'util'

vim.g.mapleader = ' '
vim.g.maplocalleader = '<BS>'

-- TODO: Repplace with LSP formatting. See init.lua.
local formatters = {
    c = 'clang-format --assume-filename=%',
    cpp = 'clang-format --assume-filename=%',
    cc = 'clang-format --assume-filename=%',
    objc = 'clang-format --assume-filename=%',
    objcpp = 'clang-format --assume-filename=%',
    rust = 'rustup run nightly rustfmt',
    python = 'black --fast --quiet --stdin-filename=% -',
}

function format(visual)
    local ft = vim.o.filetype
    local formatter = formatters[ft]
    if formatter then
        if visual then
            local cmd = u.vim_escape(string.format('!%s<CR>', formatter))
            vim.api.nvim_feedkeys(cmd, 'n', true)
        else
            vim.cmd(string.format(
                [[normal mF
                keepjumps keepmarks %%!%s
                normal g`F]],
                formatter
            ))
        end
    else
        print('No formatter for ' .. ft)
    end

    if vim.tbl_contains({ 'c', 'cpp', 'cc', 'objc', 'objcpp' }, ft) then
        vim.cmd 'LspCxxHighlight'
    end
end

local map = vim.api.nvim_set_keymap

-- Wrapper to share options
local find_files_wrapper = u.bind(telescope.find_files, {
    no_ignore = true,
    hidden = true,
})

-- `telescope.git_files` if in a repo, else `telescope.find_files`
local git_files_or_find_files =
    u.err_fallback(u.bind(telescope.git_files, { show_untracked = true }), find_files_wrapper)

local check_back_space = function()
    local col = vim.fn.col '.' - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s'
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
function _G.tab_complete()
    if vim.fn.pumvisible() == 1 then
        return u.vim_escape '<C-n>'
    elseif check_back_space() then
        return u.vim_escape '<Tab>'
    end
    return vim.fn['compe#complete']()
end
function _G.s_tab_complete()
    if vim.fn.pumvisible() == 1 then
        return u.vim_escape '<C-p>'
    end
    return u.vim_escape '<S-Tab>'
end

function _G.k_func()
    if u.lsp_attached() then
        if vim.o.filetype == 'rust' then
            return u.vim_escape "<cmd>lua require'rust-tools'.hover_actions.hover_actions()<CR>"
        end
        return u.vim_escape '<cmd>lua vim.lsp.buf.hover()<CR>'
    end

    return 'K'
end

function toggle_gitnumhl()
    if gitsigns.toggle_numhl() then
        print('Git line number highlighting disabled')
    else
        print('Git line number highlighting enabled')
    end
end

function toggle_gitlinehl()
    if gitsigns.toggle_linehl() then
        print('Git line highlighting disabled')
    else
        print('Git line highlighting enabled')
    end
end

local goto_diagnostic_opts = { severity = { min = vim.diagnostic.severity.WARN } }

-- stylua: ignore start
which_key.register({
    ['.'] = { find_files_wrapper,                                                   'Find file in cwd' },
    [' '] = { git_files_or_find_files,                                              'Find file in project' },
    [','] = { u.bind(telescope.buffers, { sort_mru = true, sort_lastused = true }), 'Switch buffer' },
    a     = { vim.lsp.buf.code_action,                                              'Code action' },
    A     = { vim.lsp.codelens.run,                                                 'Run code lens' },
    -- F     = { '<cmd>call v:lua.format(v:false)<CR>',                                'Format' }, -- TODO: Make this work when there's no language server
    F     = { u.bind(vim.lsp.buf.format, { async = true }),                         'Format file' },
    k     = { '<cmd>Man<CR>',                                                       'Open manpage' },
    m     = { '<cmd>silent wall | LMakeshiftBuild<CR>',                             'Save and make' },
    M     = { '<cmd>LMakeshiftBuild<CR>',                                           'Make' },
    r     = { telescope.oldfiles,                                                   'Most recently used files' },
    R     = { '<cmd>Startify<CR>',                                                  'Home screen' },

    l = {
        name = 'LSP',
        a    = { u.bind(telescope.diagnostics, { bufnr = 0 }), 'Diagnostics (current buffer)' },
        A    = { telescope.diagnostics,                        'Diagnostics' },
        r    = { vim.lsp.buf.rename,                           'Rename symbol' },
    },

    f = {
        name = 'File/config',
        a    = { '<cmd>edit ~/.config/alacritty/alacritty.yml<CR>', 'Open alacritty.yml' },
        A    = { '<cmd>edit ~/.config/nvim/autocommands.yml<CR>',   'Open autocommands.lua' },
        c    = { '<cmd>PackerCompile<CR>',                          'Compile plugins.lua' },
        C    = { '<cmd>PackerClean<CR>',                            'Clean plugins' },
        e    = { '<cmd>edit ~/.zshenv<CR>',                         'Open ~/.zshenv' },
        f    = { '<cmd>edit ~/.config/nvim/lua/filetypes.lua<CR>',  'Open filetypes.lua' },
        g    = { '<cmd>edit ~/.gvimrc<CR>',                         'Open ~/.gvimrc' },
        G    = { '<cmd>edit ~/.config/gdb/gdbinit<CR>',             'Open gdbinit' },
        i    = { '<cmd>PackerInstall<CR>',                          'Install plugins' },
        m    = { '<cmd>edit ~/.config/nvim/lua/mappings.lua<CR>',   'Open mappings.lua' },
        p    = { '<cmd>edit $MYVIMRC<CR>',                          'Open init.lua' },
        P    = { '<cmd>edit ~/.config/nvim/lua/plugins.lua<CR>',    'Open plugins.lua' },
        r    = { '<cmd>source $MYVIMRC<CR>',                        'Reload init.lua' },
        u    = { '<cmd>PackerUpdate<CR>',                           'Update plugins' },
        U    = { '<cmd>edit ~/.config/nvim/lua/util.lua<CR>',       'Open util.lua' },
        o    = { '<cmd>edit ~/.config/nvim/old.vim<CR>',            'Open old.vim' },
        O    = { '<cmd>edit ~/.config/nvim/lua/options.lua<CR>',    'Open options.lua' },
        s    = { '<cmd>PackerSync<CR>',                             'Sync plugins' },
        S    = { '<cmd>options<CR>',                                'Open options' },
        z    = { '<cmd>edit ~/.zshrc.local<CR>',                    'Open ~/.zshrc.local' },
        Z    = { '<cmd>edit ~/.zshrc<CR>',                          'Open ~/.zshrc' },
    },

    g = {
        name = 'Git',
        a    = { '<cmd>Git commit --amend<CR>', 'Commit --amend' },
        b    = { '<cmd>Git blame<CR>',          'Blame' },
        c    = { '<cmd>Git commit<CR>',         'Commit' },
        d    = { gitsigns.preview_hunk,         'Diff' },
        f    = { '<cmd>Git fetch<CR>',          'Fetch' },
        g    = { '<cmd>Git<CR>',                'Status (g? for help)' },
        l    = { '<cmd>Git log<CR>',            'Log' },
        L    = { '<cmd>Gllog<CR>',              'Log to location list' },
        s    = { gitsigns.stage_hunk,           'Stage hunk' },
        S    = { '<cmd>Gwrite<CR>',             'Save and stage current file' },
        x    = { gitsigns.reset_hunk,           'Reset hunk' },

        F = {
            name = 'Pull',
            p    = { '<cmd>Git pull<CR>',             'Pull' },
            a    = { '<cmd>Git pull --autostash<CR>', 'Pull --autostash' },
        },

        p = {
            p = { '<cmd>Git push<CR>', 'Push' },
        },
    },

    s = {
        name  = 'Search',
        ['/'] = { telescope.search_history,                              'Search history' },
        [':'] = { telescope.command_history,                             'Command history' },
        a     = { telescope.autocommands,                                'Autocommands' },
        b     = { telescope.git_branches,                                'Git branches' },
        B     = { telescope.current_buffer_fuzzy_find,                   'Lines in current buffer' },
        c     = { telescope.git_bcommits,                                'Commits for current buffer' },
        C     = { telescope.git_commits,                                 'Commits' },
        e     = { telescope.commands,                                    'Commands' },
        f     = { telescope.filetypes,                                   'File types' },
        g     = { telescope.live_grep,                                   'Live grep' },
        h     = { telescope.help_tags,                                   'Help' },
        l     = { telescope.loclist,                                     'Location list' },
        m     = { telescope.keymaps,                                     'Mappings' },
        M     = { u.bind(telescope.man_pages, { sections = { 'ALL' } }), 'Manpages' },
        n     = { telescope.treesitter,                                  'Treesitter identifiers' },
        o     = { telescope.jumplist,                                    'Jumplist' },
        O     = { telescope.vim_options,                                 'Options' },
        p     = { telescope.planets,                                     'Planets' },
        q     = { telescope.quickfix,                                    'Quickfix list' },
        Q     = { telescope.quickfixhistory,                             'Quickfix history' },
        r     = { telescope.registers,                                   'Registers' },
        R     = { telescope.reloader,                                    'Reload Lua modules' },
        s     = { telescope.resume,                                      'Resume previous search' },
        t     = { telescope.tagstack,                                    'Tagstack' },
        T     = { telescope.current_buffer_tags,                         'Tags in current buffer' },
        w     = { telescope.lsp_document_symbols,                        'Symbols in document' },
        W     = { telescope.lsp_workspace_symbols,                       'Symbols in workspace' },
    },

    t = {
        name = 'Toggles',
        g    = { toggle_gitnumhl,                                                                                  'Git line number highlighting' },
        l    = { toggle_gitlinehl,                                                                                 'Git line highlighting' },
        n    = { '<cmd>set number! | echo &number?"Line numbers enabled":"Line numbers disabled"<CR>',             'Line numbers' },
        p    = { '<cmd>set paste! | echo &paste?"Paste on":"Paste off"<CR>',                                       'Paste' },
        r    = { '<cmd>set rnu! | echo &rnu?"Relative line numbers enabled":"Relative line numbers disabled"<CR>', 'Relative line numbers' },
        s    = { '<cmd>setl spell! | echo &spell?"Spellcheck enabled":"Spellcheck disabled"<CR>',                  'Spellcheck' },
        w    = { '<cmd>set list! | echo &list?"Showing whitespace":"Hiding whitespace"<CR>',                       'Whitespace' },

        S = {
            name = 'Spellcheck languages',
            d    = { '<cmd>setl spell spl=de_de,cjk | echo "Set language to " .. &spl[:-5]<CR>', 'German' },
            e    = { '<cmd>setl spell spl=en_us,cjk | echo "Set language to " .. &spl[:-5]<CR>', 'English (US)' },
            g    = { '<cmd>setl spell spl=de_de,cjk | echo "Set language to " .. &spl[:-5]<CR>', 'German' },
            r    = { '<cmd>setl spell spl=en,sv,cjk | echo "Set language to " .. &spl[:-5]<CR>', 'Reset' },
            s    = { '<cmd>setl spell spl=sv,cjk | echo "Set language to " .. &spl[:-5]<CR>',    'Swedish' },
            u    = { '<cmd>setl spell spl=en_gb,cjk | echo "Set language to " .. &spl[:-5]<CR>', 'English (UK)' },
        },
    },

    w = {
        name = 'Workspace stuff',
        a    = { vim.lsp.buf.add_workspace_folder,                                        'Add folder to workspace' },
        l    = { function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, 'List workspace folders' },
        r    = { vim.lsp.buf.remove_workspace_folder,                                     'Remove folder from workspace' },
    },
}, { prefix = '<leader>' })

which_key.register({
    -- TODO
    -- F = { '<cmd>call v:lua.format(v:true)<CR>', 'Format selection' },
    F = { u.lsp_fallback(vim.lsp.buf.range_formatting, u.bind(format, true)), 'Format selection' },
}, { prefix = '<leader>', mode = 'v' })

which_key.register{
    ['<C-K>']   = { telescope.grep_string,              'rg current word' },
    ['<C-L>']   = { '<cmd>nohl|lclose<CR><c-l>',        'Redraw' },
    ['<C-N>']   = { '<cmd>lnext!<CR>',                  'Next in location list' },
    ['<C-S-N>'] = { '<cmd>lprevious!<CR>',              'Previous in location list' }, -- FIXME: Not sure if this works
    ['<C-P>']   = { '<cmd>put<CR>',                     'Paste linewise' },
    ['<C-S-P>'] = { '<cmd>put!<CR>',                    'Paste linewise behind' }, -- FIXME: Not sure if this works
    -- TODO: map range substitutions, see vim-subversive's GitHub repo.
    -- MASSIVE TODO:
    S           = { '<Plug>(SubversiveSubstitute)',     'Subversive substitute' },
    SS          = { '<Plug>(SubversiveSubstituteLine)', 'Subversive substitute line' },
    Y           = { 'y$',                               'Yank to end of line' },

    [']'] = {
        name = 'Jump forwards',
        c    = { gitsigns.next_hunk,                                     'Next Git hunk' },
        g    = { u.bind(vim.diagnostic.goto_next, goto_diagnostic_opts), 'Next diagnostic' },
    },

    ['['] = {
        name = 'Jump backwards',
        c    = { gitsigns.prev_hunk,                                     'Previous Git hunk' },
        g    = { u.bind(vim.diagnostic.goto_prev, goto_diagnostic_opts), 'Previous diagnostic' },
    },

    g = {
        b = { u.bind(gitsigns.blame_line, { full = true, ignore_whitespace = true }), 'Git blame in popup' },
        d = { telescope.lsp_definitions,                                              'Go to definition' },
        -- D = { vim.lsp.buf.declaration,                                                'Go to declaration' },
        h = { '<cmd>WhichKey<CR>',                                                    'Show base level which-key' },
        i = { telescope.lsp_implementations,                                          'Go to implementation' },
        K = { vim.lsp.buf.signature_help,                                             'Signature help' },
        l = { u.bind(vim.diagnostic.open_float, nil),                                 'Show line diagnostics' },
        m = { '<cmd>Man<CR>',                                                         'Open manpage' },
        -- O = { TODO: Show outline },
        r = { u.bind(telescope.lsp_references, { include_declaration = false }),      'Go to references' },
        R = { vim.lsp.buf.rename,                                                     'Rename' },
        s = { telescope.lsp_incoming_calls,                                           'Go to call sites' },
        S = { telescope.lsp_outgoing_calls,                                           'Go to outgoing calls' },
        t = { telescope.lsp_type_definitions,                                         'Go to type definition' },
    },

    z = {
        ['='] = { telescope.spell_suggest, 'Fix spelling' },
    },
}

which_key.register({
    ['<']     = { '<gv',                   'Indent left' },
    ['>']     = { '>gv',                   'Indent right' },
    ['<C-K>'] = { '"vy:Rg <C-R>v<CR><CR>', 'rg current selection' },
    ['<C-S>'] = { ':\'<,\'>sort<CR>',      'Sort selection'},

    g = {
        h = { '<cmd>WhichKey "" v<CR>', 'Show base level which-key' },
    },

    z = {
        ['#'] = { [["vy?\V<C-R>=escape(@v,'/\')<CR><CR>]], 'Search backwards for selection' },
        ['*'] = { [["vy/\V<C-R>=escape(@v,'/\')<CR><CR>]], 'Search forwards for selection' },
    },
}, { mode = 'v' })

which_key.register({
    ['<Tab>']     = { 'v:lua.tab_complete()',            'Tab complete'},
    ['<S-Tab>']   = { 'v:lua.s_tab_complete()',          'Reverse tab complete'},
}, { mode = 'i', expr = true })

which_key.register({
    ['<Tab>']     = { 'v:lua.tab_complete()',   'Tab complete'},
    ['<S-Tab>']   = { 'v:lua.s_tab_complete()', 'Reverse tab complete'},
}, { mode = 's', expr = true })

which_key.register({
    K = { 'v:lua.k_func()', 'LSP hover, help or man' },
}, { expr = true })

which_key.register({
    ih = { '<cmd>Gitsigns select_hunk<CR>', 'Git hunk' },
    ah = { '<cmd>Gitsigns select_hunk<CR>', 'Git hunk' },
}, { mode = 'x' })

which_key.register({
    ['<C-BS>'] = { '<C-w>', 'Backspace word' },
    ['<C-h>']  = { '<C-w>', 'Backspace word' },
}, { mode = 'i' })
-- stylua: ignore end

-- For some reason, mappings in weird modes don't work properly with which-key
-- They break operator-pending mode and e.g. cause `yy` to require pressing y three times
-- I am confusion
map('', '<ScrollWheelDown>', '<ScrollWheelDown><ScrollWheelDown>', { desc = 'Scroll down', noremap = true })
map('', '<ScrollWheelUp>', '<ScrollWheelUp><ScrollWheelUp>', { desc = 'Scroll up', noremap = true })
map('c', '<ScrollWheelDown>', '<ScrollWheelDown><ScrollWheelDown>', { desc = 'Scroll down', noremap = true })
map('c', '<ScrollWheelUp>', '<ScrollWheelUp><ScrollWheelUp>', { desc = 'Scroll up', noremap = true })
map('c', '<C-BS>', '<C-w>', { desc = 'Backspace word', noremap = true })
map('c', '<C-h>', '<C-w>', { desc = 'Backspace word', noremap = true })
map('o', 'ih', '<cmd>Gitsigns select_hunk<CR>', { desc = 'Git hunk', noremap = true })
map('o', 'ah', '<cmd>Gitsigns select_hunk<CR>', { desc = 'Git hunk', noremap = true })
