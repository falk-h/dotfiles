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
-- selene: allow(mixed_table)
which_key.add {
    -- Normal mode
    { '<C-K>',   telescope.grep_string,       desc = 'rg current word' },
    { '<C-L>',   '<cmd>nohl|lclose<CR><c-l>', desc = 'Redraw' },
    { '<C-N>',   '<cmd>lnext!<CR>',           desc = 'Next in location list' },
    { '<C-S-N>', '<cmd>lprevious!<CR>',       desc = 'Previous in location list' }, -- FIXME: Not sure if this works
    { '<C-P>',   '<cmd>put<CR>',              desc = 'Paste linewise' },
    { '<C-S-P>', '<cmd>put!<CR>',             desc = 'Paste linewise behind' }, -- FIXME: Not sure if this works

    -- TODO: map range substitutions, see vim-subversive's GitHub repo.
    -- MASSIVE TODO:
    { 'S',  '<Plug>(SubversiveSubstitute)',     desc = 'Subversive substitute' },
    { 'SS', '<Plug>(SubversiveSubstituteLine)', desc = 'Subversive substitute line' },
    { 'Y',  'y$',                               desc = 'Yank to end of line' },

    { ']', group = 'Jump formwards' },
        { ']c', gitsigns.next_hunk,                                     desc = 'Next Git hunk' },
        { ']g', u.bind(vim.diagnostic.goto_next, goto_diagnostic_opts), desc = 'Next diagnostic' },

    { '[', group = 'Jump backwards' },
        { '[c', gitsigns.prev_hunk,                                     desc = 'Previous Git hunk' },
        { '[g', u.bind(vim.diagnostic.goto_prev, goto_diagnostic_opts), desc = 'Previous diagnostic' },

    { 'g', group = 'Misc.' },
        { 'gb', u.bind(gitsigns.blame_line, { full = true, ignore_whitespace = true }), desc = 'Git blame in popup' },
        { 'gd', telescope.lsp_definitions,                                              desc = 'Go to definition' },
        -- { 'gD', vim.lsp.buf.declaration,                                                desc = 'Go to declaration' },
        { 'gh', '<cmd>WhichKey<CR>',                                                    desc = 'Show base level which-key' },
        { 'gi', telescope.lsp_implementations,                                          desc = 'Go to implementation' },
        { 'gK', vim.lsp.buf.signature_help,                                             desc = 'Signature help' },
        { 'gl', u.bind(vim.diagnostic.open_float, nil),                                 desc = 'Show line diagnostics' },
        { 'gm', '<cmd>Man<CR>',                                                         desc = 'Open manpage' },
        -- { 'gO', TODO: Show outline },
        { 'gr', u.bind(telescope.lsp_references, { include_declaration = false }),      desc = 'Go to references' },
        { 'gR', vim.lsp.buf.rename,                                                     desc = 'Rename' },
        { 'gs', telescope.lsp_incoming_calls,                                           desc = 'Go to call sites' },
        { 'gS', telescope.lsp_outgoing_calls,                                           desc = 'Go to outgoing calls' },
        { 'gt', telescope.lsp_type_definitions,                                         desc = 'Go to type definition' },

    { 'z=', telescope.spell_suggest, desc = 'Fix spelling' },

    { 'K', 'v:lua.k_func()', desc = 'LSP hover, help or man', expr = true },

    { '<leader>.', find_files_wrapper,                                                   desc = 'Find file in cwd' },
    { '<leader> ', git_files_or_find_files,                                              desc = 'Find file in project' },
    { '<leader>,', u.bind(telescope.buffers, { sort_mru = true, sort_lastused = true }), desc = 'Switch buffer' },
    { '<leader>a', vim.lsp.buf.code_action,                                              desc = 'Code action' },
    { '<leader>A', vim.lsp.codelens.run,                                                 desc = 'Run code lens' },
 -- { '<leader>F', '<cmd>call v:lua.format(v:false)<CR>',                                desc = 'Format' }, -- TODO: Make this work when there's no language server
    { '<leader>F', u.bind(vim.lsp.buf.format, { async = true }),                         desc = 'Format file' },
    { '<leader>k', '<cmd>Man<CR>',                                                       desc = 'Open manpage' },
    { '<leader>m', '<cmd>silent wall | LMakeshiftBuild<CR>',                             desc = 'Save and make' },
    { '<leader>M', '<cmd>LMakeshiftBuild<CR>',                                           desc = 'Make' },
    { '<leader>r', telescope.oldfiles,                                                   desc = 'Most recently used files' },
    { '<leader>R', '<cmd>Startify<CR>',                                                  desc = 'Home screen' },

    { '<leader>l', group = 'LSP' },
        { '<leader>la', u.bind(telescope.diagnostics, { bufnr = 0 }), desc = 'Diagnostics (current buffer)' },
        { '<leader>lA', telescope.diagnostics,                        desc = 'Diagnostics' },
        { '<leader>lr', vim.lsp.buf.rename,                           desc = 'Rename symbol' },

    { '<leader>f', group = 'File/config' },
        { '<leader>fa', '<cmd>edit ~/.config/alacritty/alacritty.yml<CR>', desc = 'Open alacritty.yml' },
        { '<leader>fA', '<cmd>edit ~/.config/nvim/autocommands.yml<CR>',   desc = 'Open autocommands.lua' },
        { '<leader>fc', '<cmd>PackerCompile<CR>',                          desc = 'Compile plugins.lua' },
        { '<leader>fC', '<cmd>PackerClean<CR>',                            desc = 'Clean plugins' },
        { '<leader>fe', '<cmd>edit ~/.zshenv<CR>',                         desc = 'Open ~/.zshenv' },
        { '<leader>ff', '<cmd>edit ~/.config/nvim/lua/filetypes.lua<CR>',  desc = 'Open filetypes.lua' },
        { '<leader>fg', '<cmd>edit ~/.gvimrc<CR>',                         desc = 'Open ~/.gvimrc' },
        { '<leader>fG', '<cmd>edit ~/.config/gdb/gdbinit<CR>',             desc = 'Open gdbinit' },
        { '<leader>fi', '<cmd>PackerInstall<CR>',                          desc = 'Install plugins' },
        { '<leader>fm', '<cmd>edit ~/.config/nvim/lua/mappings.lua<CR>',   desc = 'Open mappings.lua' },
        { '<leader>fp', '<cmd>edit $MYVIMRC<CR>',                          desc = 'Open init.lua' },
        { '<leader>fP', '<cmd>edit ~/.config/nvim/lua/plugins.lua<CR>',    desc = 'Open plugins.lua' },
        { '<leader>fr', '<cmd>source $MYVIMRC<CR>',                        desc = 'Reload init.lua' },
        { '<leader>fu', '<cmd>PackerUpdate<CR>',                           desc = 'Update plugins' },
        { '<leader>fU', '<cmd>edit ~/.config/nvim/lua/util.lua<CR>',       desc = 'Open util.lua' },
        { '<leader>fo', '<cmd>edit ~/.config/nvim/old.vim<CR>',            desc = 'Open old.vim' },
        { '<leader>fO', '<cmd>edit ~/.config/nvim/lua/options.lua<CR>',    desc = 'Open options.lua' },
        { '<leader>fs', '<cmd>PackerSync<CR>',                             desc = 'Sync plugins' },
        { '<leader>fS', '<cmd>options<CR>',                                desc = 'Open options' },
        { '<leader>fz', '<cmd>edit ~/.zshrc.local<CR>',                    desc = 'Open ~/.zshrc.local' },
        { '<leader>fZ', '<cmd>edit ~/.zshrc<CR>',                          desc = 'Open ~/.zshrc' },

    { '<leader>g', group = 'Git' },
        { '<leader>ga', '<cmd>Git commit --amend<CR>', desc = 'Commit --amend' },
        { '<leader>gb', '<cmd>Git blame<CR>',          desc = 'Blame' },
        { '<leader>gc', '<cmd>Git commit<CR>',         desc = 'Commit' },
        { '<leader>gd', gitsigns.preview_hunk,         desc = 'Diff' },
        { '<leader>gf', '<cmd>Git fetch<CR>',          desc = 'Fetch' },
        { '<leader>gg', '<cmd>Git<CR>',                desc = 'Status (g? for help)' },
        { '<leader>gl', '<cmd>Git log<CR>',            desc = 'Log' },
        { '<leader>gL', '<cmd>Gllog<CR>',              desc = 'Log to location list' },
        { '<leader>gs', gitsigns.stage_hunk,           desc = 'Stage hunk' },
        { '<leader>gS', '<cmd>Gwrite<CR>',             desc = 'Save and stage current file' },
        { '<leader>gx', gitsigns.reset_hunk,           desc = 'Reset hunk' },

        { '<leader>gF', group = 'Pull' },
        { '<leader>gFp', '<cmd>Git pull<CR>',             desc = 'Pull' },
        { '<leader>gFa', '<cmd>Git pull --autostash<CR>', desc = 'Pull --autostash' },

        { '<leader>gp', group = 'Push' },
        { '<leader>gpp', '<cmd>Git push<CR>', desc = 'Push (confirm)' },

    { '<leader>s', group = 'Search' },
        { '<leader>s/', telescope.search_history,                              desc = 'Search history' },
        { '<leader>s:', telescope.command_history,                             desc = 'Command history' },
        { '<leader>sa', telescope.autocommands,                                desc = 'Autocommands' },
        { '<leader>sb', telescope.git_branches,                                desc = 'Git branches' },
        { '<leader>sB', telescope.current_buffer_fuzzy_find,                   desc = 'Lines in current buffer' },
        { '<leader>sc', telescope.git_bcommits,                                desc = 'Commits for current buffer' },
        { '<leader>sC', telescope.git_commits,                                 desc = 'Commits' },
        { '<leader>se', telescope.commands,                                    desc = 'Commands' },
        { '<leader>sf', telescope.filetypes,                                   desc = 'File types' },
        { '<leader>sg', telescope.live_grep,                                   desc = 'Live grep' },
        { '<leader>sh', telescope.help_tags,                                   desc = 'Help' },
        { '<leader>sl', telescope.loclist,                                     desc = 'Location list' },
        { '<leader>sm', telescope.keymaps,                                     desc = 'Mappings' },
        { '<leader>sM', u.bind(telescope.man_pages, { sections = { 'ALL' } }), desc = 'Manpages' },
        { '<leader>sn', telescope.treesitter,                                  desc = 'Treesitter identifiers' },
        { '<leader>so', telescope.jumplist,                                    desc = 'Jumplist' },
        { '<leader>sO', telescope.vim_options,                                 desc = 'Options' },
        { '<leader>sp', telescope.planets,                                     desc = 'Planets' },
        { '<leader>sq', telescope.quickfix,                                    desc = 'Quickfix list' },
        { '<leader>sQ', telescope.quickfixhistory,                             desc = 'Quickfix history' },
        { '<leader>sr', telescope.registers,                                   desc = 'Registers' },
        { '<leader>sR', telescope.reloader,                                    desc = 'Reload Lua modules' },
        { '<leader>ss', telescope.resume,                                      desc = 'Resume previous search' },
        { '<leader>st', telescope.tagstack,                                    desc = 'Tagstack' },
        { '<leader>sT', telescope.current_buffer_tags,                         desc = 'Tags in current buffer' },
        { '<leader>sw', telescope.lsp_document_symbols,                        desc = 'Symbols in document' },
        { '<leader>sW', telescope.lsp_workspace_symbols,                       desc = 'Symbols in workspace' },

    { '<leader>t', group = 'Toggles' },
        { '<leader>tg',    toggle_gitnumhl,                                                                                  desc = 'Git line number highlighting' },
        { '<leader>tl',    toggle_gitlinehl,                                                                                 desc = 'Git line highlighting' },
        { '<leader>tn',    '<cmd>set number! | echo &number?"Line numbers enabled":"Line numbers disabled"<CR>',             desc = 'Line numbers' },
        { '<leader>tp',    '<cmd>set paste! | echo &paste?"Paste on":"Paste off"<CR>',                                       desc = 'Paste' },
        { '<leader>tr',    '<cmd>set rnu! | echo &rnu?"Relative line numbers enabled":"Relative line numbers disabled"<CR>', desc = 'Relative line numbers' },
        { '<leader>ts',    '<cmd>setl spell! | echo &spell?"Spellcheck enabled":"Spellcheck disabled"<CR>',                  desc = 'Spellcheck' },
        { '<leader>tw',    '<cmd>set list! | echo &list?"Showing whitespace":"Hiding whitespace"<CR>',                       desc = 'Whitespace' },

        { '<leader>tS', group = 'Spellcheck languages' },
            { '<leader>tSd',    '<cmd>setl spell spl=de_de,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'German' },
            { '<leader>tSe',    '<cmd>setl spell spl=en_us,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'English (US)' },
            { '<leader>tSg',    '<cmd>setl spell spl=de_de,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'German' },
            { '<leader>tSr',    '<cmd>setl spell spl=en,sv,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'Reset' },
            { '<leader>tSs',    '<cmd>setl spell spl=sv,cjk | echo "Set language to " .. &spl[:-5]<CR>',    desc = 'Swedish' },
            { '<leader>tSu',    '<cmd>setl spell spl=en_gb,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'English (UK)' },

    { '<leader>w', group = 'Workspace stuff' },
        { '<leader>wa', vim.lsp.buf.add_workspace_folder,                                        desc = 'Add folder to workspace' },
        { '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, desc = 'List workspace folders' },
        { '<leader>wr', vim.lsp.buf.remove_workspace_folder,                                     desc = 'Remove folder from workspace' },

    -- Visual and select mode
    { '<',     '<gv',                   desc = 'Indent left',          mode = 'v' },
    { '>',     '>gv',                   desc = 'Indent right',         mode = 'v' },
    { '<C-K>', '"vy:Rg <C-R>v<CR><CR>', desc = 'rg current selection', mode = 'v' },
    { '<C-S>', ':\'<,\'>sort<CR>',      desc = 'Sort selection',       mode = 'v' },

    { 'z#', [["vy?\V<C-R>=escape(@v,'/\')<CR><CR>]], desc = 'Search backwards for selection', mode = 'v' },
    { 'z*', [["vy/\V<C-R>=escape(@v,'/\')<CR><CR>]], desc = 'Search forwards for selection',  mode = 'v' },

    { '<leader>F', u.lsp_fallback(vim.lsp.buf.range_formatting, u.bind(format, true)), desc = 'Format selection', mode = 'v' },

    -- Visual mode
    { 'ih', '<cmd>Gitsigns select_hunk<CR>', desc = 'Git hunk', mode = 'x' },
    { 'ah', '<cmd>Gitsigns select_hunk<CR>', desc = 'Git hunk', mode = 'x' },

    -- Insert mode
    { '<C-BS>',  '<C-w>',                  desc = 'Backspace word',       mode = 'i' },
    { '<C-h>',   '<C-w>',                  desc = 'Backspace word',       mode = 'i' },
    { '<Tab>',   'v:lua.tab_complete()',   desc = 'Tab complete',         mode = 'i' },
    { '<S-Tab>', 'v:lua.s_tab_complete()', desc = 'Reverse tab complete', mode = 'i' },

    -- Select mode
    { '<Tab>',   'v:lua.tab_complete()',   desc = 'Tab complete',         expr = true, mode = 's' },
    { '<S-Tab>', 'v:lua.s_tab_complete()', desc = 'Reverse tab complete', expr = true, mode = 's' },
}
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
