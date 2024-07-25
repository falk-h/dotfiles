local u = require 'util'

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

local goto_diagnostic_opts = { severity = { min = vim.diagnostic.severity.WARN } }

-- selene: allow(mixed_table)
-- stylua: ignore
require 'which-key'.add {
    -- Normal mode
    { '<C-L>',   '<cmd>nohl|lclose<CR><c-l>', desc = 'Redraw' },
    { '<C-N>',   '<cmd>lnext!<CR>',           desc = 'Next in location list' },
    { '<C-S-N>', '<cmd>lprevious!<CR>',       desc = 'Previous in location list' }, -- FIXME: Not sure if this works
    { '<C-P>',   '<cmd>put<CR>',              desc = 'Paste linewise' },
    { '<C-S-P>', '<cmd>put!<CR>',             desc = 'Paste linewise behind' }, -- FIXME: Doesn't work
    { 'Y',       'y$',                        desc = 'Yank to end of line' },

    { ']', group = 'Jump formwards' },
        { ']g', u.bind(vim.diagnostic.goto_next, goto_diagnostic_opts), desc = 'Next diagnostic' },

    { '[', group = 'Jump backwards' },
        { '[g', u.bind(vim.diagnostic.goto_prev, goto_diagnostic_opts), desc = 'Previous diagnostic' },

    { 'g', group = 'Misc.' },
        { 'gh', '<cmd>WhichKey<CR>',                                                    desc = 'Show base level which-key' },
        { 'gK', vim.lsp.buf.signature_help,                                             desc = 'Signature help' },
        { 'gl', u.bind(vim.diagnostic.open_float, nil),                                 desc = 'Show line diagnostics' },
        { 'gm', '<cmd>Man<CR>',                                                         desc = 'Open manpage' },
        -- { 'gO', TODO: Show outline },
        { 'gR', vim.lsp.buf.rename,                                                     desc = 'Rename' },

    { 'K', 'v:lua.k_func()', desc = 'LSP hover, help or man', expr = true },

    { '<leader>a', vim.lsp.buf.code_action,                      desc = 'Code action' },
    { '<leader>A', vim.lsp.codelens.run,                         desc = 'Run code lens' },
    -- { '<leader>F', '<cmd>call v:lua.format(v:false)<CR>',        desc = 'Format' }, -- TODO: Make this work when there's no language server
    { '<leader>F', u.bind(vim.lsp.buf.format, { async = true }), desc = 'Format file' },
    { '<leader>k', '<cmd>Man<CR>',                               desc = 'Open manpage' },

    { '<leader>l', group = 'LSP' },
        { '<leader>lr', vim.lsp.buf.rename, desc = 'Rename symbol' },

    { '<leader>f', group = 'File/config' },
        { '<leader>fa', '<cmd>edit ~/.config/alacritty/alacritty.toml<CR>',    desc = 'Open alacritty.toml' },
        { '<leader>fA', '<cmd>edit ~/.config/nvim/lua/autocommands.lua<CR>',   desc = 'Open autocommands.lua' },
        { '<leader>fe', '<cmd>edit ~/.zshenv<CR>',                             desc = 'Open ~/.zshenv' },
        { '<leader>ff', '<cmd>edit ~/.config/nvim/lua/filetypes.lua<CR>',      desc = 'Open filetypes.lua' },
        { '<leader>fg', '<cmd>edit ~/.gvimrc<CR>',                             desc = 'Open ~/.gvimrc' },
        { '<leader>fG', '<cmd>edit ~/.config/gdb/gdbinit<CR>',                 desc = 'Open gdbinit' },
        { '<leader>fl', '<cmd>edit ~/.config/nvim/lua/bootstrap-lazy.lua<CR>', desc = 'Open bootstrap-lazy.lua' },
        { '<leader>fL', '<cmd>Lazy<CR>',                                       desc = 'Open the lazy.nvim GUI' },
        { '<leader>fm', '<cmd>edit ~/.config/nvim/lua/mappings.lua<CR>',       desc = 'Open mappings.lua' },
        { '<leader>fp', '<cmd>edit $MYVIMRC<CR>',                              desc = 'Open init.lua' },
        { '<leader>fP', '<cmd>edit ~/.config/nvim/lua/plugins/misc.lua<CR>',   desc = 'Open plugins/misc.lua' },
        { '<leader>fr', '<cmd>source $MYVIMRC<CR>',                            desc = 'Reload init.lua' },
        { '<leader>fU', '<cmd>edit ~/.config/nvim/lua/util.lua<CR>',           desc = 'Open util.lua' },
        { '<leader>fO', '<cmd>edit ~/.config/nvim/lua/options.lua<CR>',        desc = 'Open options.lua' },
        { '<leader>fS', '<cmd>options<CR>',                                    desc = 'Open options' },
        { '<leader>fz', '<cmd>edit ~/.zshrc.local<CR>',                        desc = 'Open ~/.zshrc.local' },
        { '<leader>fZ', '<cmd>edit ~/.zshrc<CR>',                              desc = 'Open ~/.zshrc' },

    { '<leader>g', group = 'Git' },
        { '<leader>gF', group = 'Pull' },
        { '<leader>gp', group = 'Push' },

    { '<leader>s', group = 'Search' },

    { '<leader>t', group = 'Toggles' },
        { '<leader>tn', '<cmd>set number! | echo &number?"Line numbers enabled":"Line numbers disabled"<CR>',             desc = 'Line numbers' },
        { '<leader>tp', '<cmd>set paste! | echo &paste?"Paste on":"Paste off"<CR>',                                       desc = 'Paste' },
        { '<leader>tr', '<cmd>set rnu! | echo &rnu?"Relative line numbers enabled":"Relative line numbers disabled"<CR>', desc = 'Relative line numbers' },
        { '<leader>ts', '<cmd>setl spell! | echo &spell?"Spellcheck enabled":"Spellcheck disabled"<CR>',                  desc = 'Spellcheck' },
        { '<leader>tw', '<cmd>set list! | echo &list?"Showing whitespace":"Hiding whitespace"<CR>',                       desc = 'Whitespace' },

        { '<leader>tS', group = 'Spellcheck languages' },
            { '<leader>tSd', '<cmd>setl spell spl=de_de,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'German' },
            { '<leader>tSe', '<cmd>setl spell spl=en_us,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'English (US)' },
            { '<leader>tSg', '<cmd>setl spell spl=de_de,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'German' },
            { '<leader>tSr', '<cmd>setl spell spl=en,sv,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'Reset' },
            { '<leader>tSs', '<cmd>setl spell spl=sv,cjk | echo "Set language to " .. &spl[:-5]<CR>',    desc = 'Swedish' },
            { '<leader>tSu', '<cmd>setl spell spl=en_gb,cjk | echo "Set language to " .. &spl[:-5]<CR>', desc = 'English (UK)' },

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

    -- Insert mode
    { '<C-BS>',  '<C-w>',                  desc = 'Backspace word',       mode = 'i' },
    { '<C-h>',   '<C-w>',                  desc = 'Backspace word',       mode = 'i' },
    { '<Tab>',   'v:lua.tab_complete()',   desc = 'Tab complete',         mode = 'i' },
    { '<S-Tab>', 'v:lua.s_tab_complete()', desc = 'Reverse tab complete', mode = 'i' },

    -- Select mode
    { '<Tab>',   'v:lua.tab_complete()',   desc = 'Tab complete',         expr = true, mode = 's' },
    { '<S-Tab>', 'v:lua.s_tab_complete()', desc = 'Reverse tab complete', expr = true, mode = 's' },
}

-- For some reason, mappings in weird modes don't work properly with which-key
-- They break operator-pending mode and e.g. cause `yy` to require pressing y three times
-- I am confusion
map('', '<ScrollWheelDown>', '<ScrollWheelDown><ScrollWheelDown>', { desc = 'Scroll down', noremap = true })
map('', '<ScrollWheelUp>', '<ScrollWheelUp><ScrollWheelUp>', { desc = 'Scroll up', noremap = true })
map('c', '<ScrollWheelDown>', '<ScrollWheelDown><ScrollWheelDown>', { desc = 'Scroll down', noremap = true })
map('c', '<ScrollWheelUp>', '<ScrollWheelUp><ScrollWheelUp>', { desc = 'Scroll up', noremap = true })
map('c', '<C-BS>', '<C-w>', { desc = 'Backspace word', noremap = true })
map('c', '<C-h>', '<C-w>', { desc = 'Backspace word', noremap = true })
