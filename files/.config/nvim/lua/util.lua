local mod = {}

-- Trims leading and trailing matches of a pattern from a string
function mod.trim_matches(s, pattern)
    -- Same as /^<pattern>*.*?<pattern>*$/ in a sane regex dialect
    local p = '^' .. pattern .. '*(.-)' .. pattern .. '*$'
    return s:match(p)
end

-- Trims leading and trailing whitespace from a string
function mod.trim(s)
    return mod.trim_matches(s, '%s')
end

-- Splits a string into lines, ignoring a single trailing newline
function mod.lines(s)
    return mod.split(s:match '^(.-)\n?$', '\n')
end

-- Splits a string into an array at sep
--
-- A trailing separator results in an empty string as the last return value
function mod.split(s, sep)
    local ret = {}

    -- .- is the same as .*? in sane regex dialects
    -- () "matches" the current position in the string
    local pattern = '(.-)' .. sep .. '()'

    local last_sep_end = 1 -- One index past the last separator

    for match, sep_end in s:gmatch(pattern) do
        table.insert(ret, match)
        last_sep_end = sep_end
    end

    table.insert(ret, s:sub(last_sep_end))

    return ret
end

function mod.with_overrides(filename, defaults)
    local options = defaults or {}

    -- Since no path is given, this searches from the current working directory
    local files = vim.fs.find(filename, {
        upward = true,
        type = 'file',
        limit = math.huge,
    })

    -- Loop over the files in reverse, since vim.fs.find() returns files in
    -- lower directories first, but we want files in lower directories to
    -- override files in higher directories
    for i = #files, 1, -1 do
        local path = files[i]
        local file = io.open(path)
        local contents = file:read '*a' -- "*a" reads the entire file
        file:close()

        local trimmed = mod.trim(contents)
        local ok, overrides = pcall(vim.json.decode, trimmed)
        if not ok then
            error('JSON decode error in ' .. path .. ": '" .. trimmed .. "': " .. overrides)
        end

        options = vim.tbl_extend('force', options, overrides)
    end

    return options
end

function mod.vim_escape(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function mod.bind(f, arg)
    return function()
        return f(arg)
    end
end

function mod.id(x)
    return x
end

function mod.lambda(x)
    return mod.bind(mod.id, x)
end

-- Returns `true` if `t` is an empty table
function mod.empty(table)
    for _, _ in pairs(table) do
        return false
    end
    return true
end

-- Calls `f1` and falls back to `f2` if it returns an error
function mod.err_fallback(f1, f2)
    return function()
        local success, ret = pcall(f1) -- pcall catches errors
        if success then
            return ret
        else
            return f2()
        end
    end
end

-- Returns `true` if a language server is attached to the current buffer
function mod.lsp_attached()
    return not mod.empty(vim.lsp.buf_get_clients(0))
end

-- Calls `f1` if a language server is attached, else calls `f2`
function mod.lsp_fallback(f1, f2)
    return function()
        if mod.lsp_attached() then
            return f1()
        else
            return f2()
        end
    end
end

local augroup_idx = 0
function mod.autocmd(event, f, desc, opts)
    local name = 'Init' .. event .. 'Group' .. augroup_idx
    augroup_idx = augroup_idx + 1
    local group = vim.api.nvim_create_augroup(name, {})
    opts = vim.tbl_extend('keep', opts or {}, {
        callback = function(arg)
            f(arg) -- Mask the return value of f so it doesn't accidentally delete the autocommand
        end,
        group = group,
        desc = desc,
    })
    return vim.api.nvim_create_autocmd(event, opts)
end

return mod
