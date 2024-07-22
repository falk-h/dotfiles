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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_extend('keep', capabilities, require('cmp_nvim_lsp').default_capabilities())
capabilities = vim.tbl_extend('keep', capabilities, lsp_status.capabilities)

-- Type checker (and also General-purpose language server?) for Python
lspconfig.pyright.setup {
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
    capabilities = capabilities,
}

lspconfig.ccls.setup {
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
    capabilities = capabilities,
    filetypes = { 'sh', 'bash' },
}

lspconfig.dockerls.setup {
    capabilities = capabilities,
}

lspconfig.taplo.setup {
    capabilities = capabilities,
}

-- lspconfig.yamlls.setup {
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
        settings = {
            ['rust-analyzer'] = rust_analyzer_settings,
        },
    },
}

require 'commands'
require 'filetypes'
require 'autocommands'
