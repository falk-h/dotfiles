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
-- stylua: ignore end

-- selene: allow(mixed_table)
local mappings = {
    asciidoc = {
        { '&', '1z=', desc = 'Autocorrect' },
    },
    gitcommit = {
        { '&', '1z=', desc = 'Autocorrect' },
    },
    help = {
        { 'q', '<cmd>silent quit<CR>', desc = 'Quit' },
    },
    markdown = {
        { '&', '1z=', desc = 'Autocorrect' },
    },
    qf = { -- Quickfix window and location list
        { 'q', ':quit', desc = 'Close window' },
    },
    rst = {
        { '&', '1z=', desc = 'Autocorrect' },
    },
    tex = {
        { '&', '1z=', desc = 'Autocorrect' },
        -- { 'K', call CocActionAsync("runCommand", "latex.ForwardSearch")<CR>', desc = 'Forward search'} TODO
    },
}

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
        local map_with_buf = vim.tbl_extend('force', map, { buffer = vim.fn.bufnr() })
        which_key.add(map_with_buf)
    end
end

util.autocmd('FileType', set_filetype_settings, 'Set filetype-specific options')
