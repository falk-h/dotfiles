local util = require 'util'

-- stylua: ignore start
local options = {
    colorcolumn = {
        c    = '120',
        cpp  = '120',
        rust = '100',
        tex  = nil,
    },
    foldexpr = {
        c    = 'nvim_treesitter:foldexpr()',
        cpp  = 'nvim_treesitter:foldexpr()',
        rust = 'nvim_treesitter:foldexpr()',
    },
    foldmethod = {
        c    = 'expr',
        cpp  = 'expr',
        rust = 'expr',
    },
    linebreak = {
        asciidoc  = true,
        gitcommit = true,
        markdown  = true,
        rst       = true,
        rust      = true,
        tex       = true,
    },
    spell = {
        asciidoc  = true,
        gitcommit = true,
        markdown  = true,
        rst       = true,
        tex       = true,
    },
    textwidth = {
        asciidoc  = 80,
        c         = 120,
        cpp       = 120,
        gitcommit = 72,
        lua       = 120,
        markdown  = 80,
        rst       = 80,
        rust      = 80,
        tex       = 0,
    },
}

local mappings = {
    asciidoc = {
        ['&'] = { '1z=', 'Autocorrect' },
    },
    gitcommit = {
        ['&'] = { '1z=', 'Autocorrect' },
    },
    help = {
        q = { '<cmd>silent quit<CR>', 'Quit' }
    },
    markdown = {
        ['&'] = { '1z=', 'Autocorrect' },
    },
    qf = { -- Quickfix window and location list
        q = { ':quit', 'Close window' },
    },
    rst = {
        ['&'] = { '1z=', 'Autocorrect' },
    },
    tex  = {
        ['&'] = { '1z=', 'Autocorrect' },
        -- K = {':call CocActionAsync("runCommand", "latex.ForwardSearch")<CR>', 'Forward search'} TODO
    },
}
-- stylua: ignore end

-- selene: allow(unused_variable) This called via an autocommand
function set_filetype_settings(ctx)
    local filetype = ctx.match

    vim.g.ft_test = filetype
    for option, filetypes in pairs(options) do
        local value = filetypes[filetype]
        if value then
            vim.opt_local[option] = value
        end
    end

    local which_key = require 'which-key'
    local map = mappings[filetype]
    if map then
        local buf = vim.fn.bufnr()
        which_key.register(map, { buffer = buf })
    end
end

util.autocmd('FileType', set_filetype_settings, 'Set filetype-specific options')
