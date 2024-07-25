local u = require 'util'

-- selene: allow(mixed_table)
return {
    {
        'nvim-treesitter/nvim-treesitter', -- Treesitter
        build = function()
            require('nvim-treesitter.install').update { with_sync = true }()
        end,
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = 'all',
                highlight = {
                    enable = true,
                    disable = {
                        -- Disable highlighting for C/C++ because vim-lsp-cxx-highlight handles that better
                        'c',
                        'cpp',
                        'yaml', -- Disable highlighting for YAML because it breaks in Helm templates
                        'cmake', -- CMake highlighting is broken for some reason
                    },
                },
                indent = {
                    enable = false, -- Breaks in C, and possibly in other places
                },
                textobjects = {
                    enable = true,
                    select = {
                        enable = true,
                        -- TODO: These don't work consistently
                        -- keymaps = {
                        --     ["af"] = "@function.outer",
                        --     ["if"] = "@function.inner",
                        --     ["aC"] = "@class.outer",
                        --     ["iC"] = "@class.inner",
                        --     ["ac"] = "@conditional.outer",
                        --     ["ic"] = "@conditional.inner",
                        --     ["ab"] = "@block.outer",
                        --     ["ib"] = "@block.inner",
                        --     ["al"] = "@loop.outer",
                        --     ["il"] = "@loop.inner",
                        --     ["is"] = "@statement.inner",
                        --     ["as"] = "@statement.outer",
                        --     ["am"] = "@call.outer",
                        --     ["im"] = "@call.inner",
                        --     ["ad"] = "@comment.outer",
                        --     ["aa"] = "@parameter.inner",
                        -- },
                    },
                },
            }
        end,
    },
    { 'nvim-treesitter/nvim-treesitter-refactor' },
    { 'nvim-treesitter/nvim-treesitter-textobjects' },

    {
        'nvim-lua/lsp-status.nvim', -- LSP status in statusbar
        config = function()
            local lsp_status = require 'lsp-status'
            lsp_status.register_progress()
            lsp_status.config {
                diagnostics = false,
                show_filename = false,
                status_symbol = '',
            }
            require('util').autocmd('LspAttach', function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                lsp_status.on_attach(client)
            end, 'Set up lsp-status.nvim when an LSP server attaches to a buffer')
        end,
    },
    { 'neovim/nvim-lspconfig' },

    {
        'hrsh7th/nvim-cmp', -- Completion engine
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-document-symbol',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-path',
            'nvim-lua/plenary.nvim',
            'petertriho/cmp-git',
            'saadparwaiz1/cmp_luasnip',
            'windwp/nvim-autopairs',
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            local cmp_autopairs = require 'nvim-autopairs.completion.cmp'

            -- Make autopairs work
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

            -- From https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
            end

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),

                    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ['<CR>'] = cmp.mapping.confirm { select = true },

                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'nvim_lsp_document_symbol' },
                    { name = 'buffer' },
                }),
            }

            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'git' },
                }, {
                    { name = 'buffer' },
                }),
            })

            cmp.setup.filetype({ 'asciidoc', 'markdown', 'tex', 'text' }, {
                sources = cmp.config.sources {
                    { name = 'buffer' },
                    { name = 'buffer' },
                },
            })

            -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'nvim_lsp_document_symbol' },
                    { name = 'buffer' },
                },
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' },
                }, {
                    { name = 'cmdline' },
                }),
            })

            require('cmp_git').setup()
        end,
    },

    {
        'jose-elias-alvarez/null-ls.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            local null_ls = require 'null-ls'
            local code_actions = null_ls.builtins.code_actions
            local diagnostics = null_ls.builtins.diagnostics
            local formatting = null_ls.builtins.formatting
            null_ls.setup {
                sources = {
                    code_actions.shellcheck, -- Bash/sh

                    diagnostics.actionlint, -- GitHub actions
                    diagnostics.checkmake, -- Makefiles
                    diagnostics.chktex, -- LateX
                    diagnostics.jsonlint, -- JSON
                    -- diagnostics.markdownlint, -- Markdown
                    diagnostics.rstcheck, -- reStructuredText
                    diagnostics.selene.with { -- Lua
                        extra_args = {
                            '--config',
                            vim.env.HOME .. '/dotfiles/selene.toml',
                        },
                    },
                    diagnostics.shellcheck, -- Bash/sh
                    diagnostics.sqlfluff.with { -- SQL
                        extra_args = { '--dialect', 'postgres' },
                    },
                    diagnostics.tidy, -- HTML/XML
                    diagnostics.yamllint, -- YAML
                    diagnostics.zsh, -- zsh (only syntax)

                    formatting.cbfmt, -- Formatting of codeblocks inside markdown
                    formatting.clang_format, -- C, C++, and similar
                    formatting.cmake_format, -- CMake
                    formatting.mdformat.with { -- Markdown
                        extra_args = {
                            '--wrap',
                            '80',
                        },
                    },
                    formatting.jq.with { -- JSON
                        extra_args = { '--indent', '4' },
                    },
                    formatting.latexindent, -- LaTeX
                    formatting.shfmt.with { -- Bash
                        extra_filetypes = { 'zsh' },
                        extra_args = {
                            '--indent',
                            '4',
                            '--binary-next-line', -- Break lines before &&, etc.
                            '--simplify',
                        },
                    },
                    formatting.sqlfluff.with { -- SQL
                        extra_args = { '--dialect', 'postgres' },
                    },
                    formatting.stylua, -- Lua
                },
            }
        end,
    },

    { -- Theme
        'rebelot/kanagawa.nvim',
        -- Make sure the colorscheme is always loaded on startup, and is always loaded first.
        lazy = false,
        priority = 1000,
        config = function()
            -- Highlight trailing whitespace, but not when typing at the end of the line
            vim.cmd 'match ExtraWhitespace /\\s\\+\\%#\\@<!$/'

            vim.opt.fillchars:append {
                horiz = '━',
                horizup = '┻',
                horizdown = '┳',
                vert = '┃',
                vertleft = '┫',
                vertright = '┣',
                verthoriz = '╋',
            }

            require('kanagawa').setup {
                dimInactive = true,
                globalStatus = true,
                overrides = function(colors)
                    return {
                        ExtraWhitespace = { bg = colors.samuraiRed },
                        WhichKeySeperator = { link = 'Operator' },
                        WhichKeyFloat = { link = 'Label' },
                        WhichKeyDesc = { link = 'String' },
                    }
                end,
            }

            vim.cmd 'colorscheme kanagawa'
        end,
    },

    {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- The extension needs to be loaded after telescope to tell telescope to use it.
        dependencies = 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        config = function()
            require('telescope').load_extension 'fzf'
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        opts = {
            defaults = {
                -- Switch between horizontal and vertical layout based on terminal width
                layout_strategy = 'flex',
                layout_config = {
                    width = 0.999,
                    height = 0.7,
                    anchor = 'S',
                    flex = {
                        -- Use vertical layout when under 150 lines
                        flip_columns = 150,
                    },
                    horizontal = {
                        -- Slightly larger preview (default: 0.5)
                        preview_width = 0.6,
                    },
                },
                mappings = {
                    i = {
                        ['<ESC>'] = 'close', -- Don't go into normal mode on escape
                        ['<C-h>'] = function() -- Make ctrl-backspace work as expected
                            vim.api.nvim_input '<C-w>'
                        end,
                    },
                },
            },
        },
    },

    {
        'tomtom/tcomment_vim', -- Comment operator
        config = function()
            vim.fn['tcomment#type#Define']('c', {
                commentstring = '// %s',
                replacements = vim.g['tcomment#replacements_c'],
            })
            vim.fn['tcomment#type#Define']('cpp', {
                commentstring = '// %s',
                replacements = vim.g['tcomment#replacements_c'],
            })
        end,
    },

    {
        'L3MON4D3/LuaSnip', -- Snippet engine
        dependencies = {
            'honza/vim-snippets', -- A collection of snippets
        },
        config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip.loaders.from_snipmate').lazy_load()
            require('luasnip.loaders.from_lua').lazy_load()
        end,
    },

    {
        'folke/which-key.nvim', -- Spacemacs style popup for keybindings
        config = function()
            -- TODO
            require('which-key').setup {
                win = {
                    padding = { 0, 0 },
                },
            }
            -- Set mappings from lua/mappings.lua
            require 'mappings'
        end,
    },

    { 'farmergreg/vim-lastplace' }, -- Remember cursor position in files

    { 'axelf4/vim-strip-trailing-whitespace' }, -- Automatically strip trailing whitespace

    {
        'nvim-lualine/lualine.nvim', -- Lightweight statusbar
        dependencies = {
            'kyazdani42/nvim-web-devicons',
            'nvim-lua/lsp-status.nvim',
            'tpope/vim-fugitive',
            'lewis6991/gitsigns.nvim',
            'rebelot/kanagawa.nvim',
        },
        config = function()
            -- This works better than lualine's builtin diff source. Not sure how exactly.
            local function diff_source()
                local status = vim.b.gitsigns_status_dict
                if status then
                    return {
                        added = status.added,
                        modified = status.changed,
                        removed = status.removed,
                    }
                end
            end

            require('lualine').setup {
                options = {
                    globalstatus = true,
                    fmt = vim.trim, -- Trim all statusline components (mainly LSP status)
                    refresh = {
                        statusline = 200,
                    },
                },
                sections = {
                    lualine_b = {
                        {
                            'FugitiveHead',
                            icon = '',
                        },
                        {
                            'diff',
                            source = diff_source,
                        },
                        'diagnostics',
                    },
                    lualine_c = {
                        {
                            'filename',
                            path = 1, -- Show relative path
                        },
                        'require"lsp-status".status()',
                    },
                    lualine_x = {
                        -- Add windows and remove encoding, because encoding is always UTF-8 anyway
                        'windows',
                        'fileformat',
                        'filetype',
                    },
                },
                extensions = { 'fugitive', 'man' },
            }
        end,
    },

    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signcolumn = false,
            numhl = true,
            linehl = false,
        },
    },

    { 'tpope/vim-fugitive' }, -- Git plugin, somewhat like magit

    -- TODO
    -- use 'tpope/vim-surround' -- Text objects for working with things that are surrounded by other things

    { 'tpope/vim-repeat' }, -- Lets vim-surround actions be repeated with '.'

    { 'tpope/vim-eunuch' }, -- Provides some UNIX utilities such as :SudoWrite and :Move

    { 'wellle/targets.vim' }, -- Better text objects

    { 'svermeulen/vim-subversive' }, -- Provides commands for replacing text with the contents of the clipboard

    {
        'windwp/nvim-autopairs', -- Automatically enter matching (){}[]""''
        -- TODO: simplify if possible
        config = function()
            require('nvim-autopairs').setup()
        end,
    },

    {
        'editorconfig/editorconfig-vim', -- Support for EditorConfig per-project style definition files
        config = function()
            -- Make EditorConfig not affect Fugitive buffers. This is recommended by the EditorConfig README
            vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*' }
        end,
    },

    {
        'johnsyweb/vim-makeshift', -- Autodetect build system
        config = function()
            -- Tell Makeshift about some extra build systems
            vim.g.makeshift_systems = {
                ['meson.build'] = 'ninja -C builddir',
                ['Cargo.toml'] = 'cargo build',
            }
        end,
    },

    { -- Fancy startup screen
        'mhinz/vim-startify',
        config = function()
            local util = require 'util'

            -- Don't let startify change the working directory
            vim.g.startify_change_to_dir = 0

            local vim_version = vim.version()
            local vim_version_string =
                string.format('%s.%s.%s', vim_version.major, vim_version.minor, vim_version.patch)
            local hostname = vim.fn.hostname()
            local lua_version = _VERSION
            local jit_version = jit.version
            vim.g.startify_custom_footer = vim.fn['startify#pad'] {
                string.format('Neovim %s on %s', vim_version_string, hostname),
                string.format('%s, %s', lua_version, jit_version),
            }

            local header = [[
           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
           ┃      ::::::::::   :::   :::       :::      ::::::::   ::::::::┃
           ┃     :*:         :*:*: :*:*:    :*: :*:   :*:    :*: :*:    :*:┃
           ┃    *:*        *:* *:*:* *:*  *:*   *:*  *:*        *:*        ┃
           ┃   *#**:**#   *#*  *:*  *#* *#**:**#**: *#*        *#**:**#**  ┃
           ┃  *#*        *#*       *#* *#*     *#* *#*               *#*   ┃
           ┃ #*#        #*#       #*# #*#     #*# #*#    #*# #*#    #*#    ┃
           ┃########## ###       ### ###     ###  ########   ########      ┃
           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛]]
            vim.g.startify_custom_header = util.lines(header)

            -- Show recent files in current dir before global recent files
            vim.g.startify_lists = {
                { type = 'dir', header = { '   Recent files in current dir' } },
                { type = 'files', header = { '   Recent files' } },
            }

            -- Don't show <empty buffer> and <quit>
            vim.g.startify_enable_special = 0

            -- Use a relative path for files in or below the current dir
            vim.g.startify_relative_path = 1
        end,
    },

    { 'rust-lang/rust.vim' }, -- Some Rust features
    { 'simrat39/rust-tools.nvim' }, -- Inlay hints with rust-analyzer

    -- TODO
    --use 'lervag/vimtex' -- TeX support

    { 'jackguo380/vim-lsp-cxx-highlight' },
}
