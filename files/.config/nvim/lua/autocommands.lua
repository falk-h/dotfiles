local util = require 'util'

util.autocmd(
    'TextYankPost',
    util.bind(vim.highlight.on_yank, { on_visual = false, timeout = 200, higroup = 'Search' }),
    'Highlight text after yanking'
)

util.autocmd('User', function()
    vim.wo.cursorline = true
    vim.wo.fillchars = ''
end, 'Make startify prettier', { pattern = 'Startified' })
