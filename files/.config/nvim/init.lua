-- Set options from lua/options.lua
require 'options'

-- TODO: document better
-- lazy.nvim expects leader and localleader to be mapped before loading plugins "so that mappings
-- are correct". No idea what that means. Anyway, ideally, these would be set in mappings.lua, but
-- mappings.lua creates mappings to functions defined in plugins, so it needs to be loaded after all
-- of the plugins are loaded. Therefore, these are set here.
vim.g.mapleader = ' '
vim.g.maplocalleader = '<BS>'

-- Bootstrap the lazy.nvim plugin manager from lua/bootstrap-lazy.lua
require 'bootstrap-lazy'

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
