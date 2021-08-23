-- Set options from lua/options.lua
require 'options'

local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    -- Install packer if it doesn't exist
    print 'Installing packer...'
    vim.fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
    vim.cmd 'packadd packer.nvim'
    print 'Installed packer!'
    require 'plugins'
    print 'Installing plugins... Restart nvim after installation is complete'
    require('packer').sync()
else
    -- Otherwise just load the plugins
    require 'plugins'
end

-- Use Lua for filetype detection, see `:h new-filetype`
vim.g.do_filetype_lua = 1

local lsp_status = require 'lsp-status'
local lspconfig = require 'lspconfig'

-- Use an on_attach function to only map the following keys after the language server attaches to the current buffer
local on_attach = function(client, _bufnr)
    lsp_status.on_attach(client)
    require('lsp_signature').on_attach(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_extend('keep', capabilities, require('cmp_nvim_lsp').default_capabilities())
capabilities = vim.tbl_extend('keep', capabilities, lsp_status.capabilities)

-- Type checker (and also General-purpose language server?) for Python
lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                useLibraryCodeForTypes = true,
            },
        },
    },
}

lspconfig.gopls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lspconfig.ccls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {
        'ccls',
        '--log-file=/tmp/ccls.log',
        '--log-file-append',
        '-v=1',
    },
    init_options = {
        cache = {
            directory = vim.env.HOME .. '/.cache/ccls',
        },
        highlight = {
            lsRanges = true,
        },
        client = {
            snippetSupport = true,
        },
        clang = {
            excludeArgs = { '-frounding-math' },
        },
    },
}

lspconfig.bashls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { 'sh', 'bash' },
}

lspconfig.dockerls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lspconfig.taplo.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- lspconfig.yamlls.setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
--     settings = {
--         redhat = {
--             telemetry = {
--                 enabled = false,
--             },
--         },
--     },
-- }

local util = require 'util'
local rust_analyzer_settings = util.with_overrides 'ra.json'

require('rust-tools').setup {
    tools = {
        inlay_hints = {
            parameter_hints_prefix = '← ',
            other_hints_prefix = '» ',
            reload_workspace_from_cargo_toml = false,
        },
    },

    server = {
        on_attach = on_attach,
        settings = {
            ['rust-analyzer'] = rust_analyzer_settings,
        },
    },
}

require 'commands'
require 'filetypes'
require 'autocommands'
