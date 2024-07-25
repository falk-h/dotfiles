local telescope = require 'telescope.builtin'

local function rg(ctx)
    if ctx.args then
        telescope.grep_string { search = ctx.args, use_regex = true }
    else
        telescope.live_grep {}
    end
end

vim.api.nvim_create_user_command('Rg', rg, {
    nargs = '?',
})

vim.cmd [[
    cabbrev rg Rg

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

    cabbrev waq wqa
    cabbrev waQ wqa
    cabbrev wAq wqa
    cabbrev wAQ wqa
    cabbrev Waq wqa
    cabbrev WaQ wqa
    cabbrev WAq wqa
    cabbrev WAQ wqa
]]
