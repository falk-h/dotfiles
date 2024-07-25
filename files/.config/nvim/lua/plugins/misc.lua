local u = require 'util'

-- selene: allow(mixed_table)
return {
    {
        'nvim-treesitter/nvim-treesitter', -- Treesitter
        build = function()
            require('nvim-treesitter.install').update { with_sync = true }()
        end,
        config = function(_, _)
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
        config = function(_, _)
            local lsp_status = require 'lsp-status'
            lsp_status.register_progress()
            lsp_status.config {
                diagnostics = false,
                show_filename = false,
                status_symbol = '',
            }
            u.autocmd('LspAttach', function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                lsp_status.on_attach(client)
            end, 'Set up lsp-status.nvim when an LSP server attaches to a buffer')
        end,
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = { 'nvim-lua/lsp-status.nvim', 'hrsh7th/cmp-nvim-lsp' },
        config = function(_, _)
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
        end,
    },

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
        config = function(_, _)
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
        config = function(_, _)
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
        config = function(_, _)
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
        dependencies = 'nvim-telescope/telescope.nvim',
        -- That's also why key bindings for telescope are defined here.
        keys = function()
            local t = require 'telescope.builtin'
            local find_files_wrapper = u.bind(t.find_files, {
                no_ignore = true,
                hidden = true,
            })

            -- `telescope.git_files` if in a repo, else `telescope.find_files`
            local git_files_or_find_files =
                u.err_fallback(u.bind(t.git_files, { show_untracked = true }), find_files_wrapper)

            -- stylua: ignore
            return {
                { '<C-K>', t.grep_string,                                             desc = 'rg current word' },
                { 'gd',    t.lsp_definitions,                                         desc = 'Go to definition' },
                -- { 'gD',    vim.lsp.buf.declaration,                                   desc = 'Go to declaration' }, -- TODO
                { 'gi',    t.lsp_implementations,                                     desc = 'Go to implementation' },
                { 'gr',    u.bind(t.lsp_references, { include_declaration = false }), desc = 'Go to references' },
                { 'gs',    t.lsp_incoming_calls,                                      desc = 'Go to call sites' },
                { 'gS',    t.lsp_outgoing_calls,                                      desc = 'Go to outgoing calls' },
                { 'gt',    t.lsp_type_definitions,                                    desc = 'Go to type definition' },


                { '<leader>.',        find_files_wrapper,                                           desc = 'Find file in cwd' },
                { '<leader><leader>', git_files_or_find_files,                                      desc = 'Find file in project' },
                { '<leader>,',        u.bind(t.buffers, { sort_mru = true, sort_lastused = true }), desc = 'Switch buffer' },
                { '<leader>r',        t.oldfiles,                                                   desc = 'Most recently used files' },
                { '<leader>la',       u.bind(t.diagnostics, { bufnr = 0 }),                         desc = 'Diagnostics (current buffer)' },
                { '<leader>lA',       t.diagnostics,                                                desc = 'Diagnostics' },

                { '<leader>s/', t.search_history,                              desc = 'Search history' },
                { '<leader>s:', t.command_history,                             desc = 'Command history' },
                { '<leader>sa', t.autocommands,                                desc = 'Autocommands' },
                { '<leader>sb', t.git_branches,                                desc = 'Git branches' },
                { '<leader>sB', t.current_buffer_fuzzy_find,                   desc = 'Lines in current buffer' },
                { '<leader>sc', t.git_bcommits,                                desc = 'Commits for current buffer' },
                { '<leader>sC', t.git_commits,                                 desc = 'Commits' },
                { '<leader>se', t.commands,                                    desc = 'Commands' },
                { '<leader>sf', t.filetypes,                                   desc = 'File types' },
                { '<leader>sg', t.live_grep,                                   desc = 'Live grep' },
                { '<leader>sh', t.help_tags,                                   desc = 'Help' },
                { '<leader>sl', t.loclist,                                     desc = 'Location list' },
                { '<leader>sm', t.keymaps,                                     desc = 'Mappings' },
                { '<leader>sM', u.bind(t.man_pages, { sections = { 'ALL' } }), desc = 'Manpages' },
                { '<leader>sn', t.treesitter,                                  desc = 'Treesitter identifiers' },
                { '<leader>so', t.jumplist,                                    desc = 'Jumplist' },
                { '<leader>sO', t.vim_options,                                 desc = 'Options' },
                { '<leader>sp', t.planets,                                     desc = 'Planets' },
                { '<leader>sq', t.quickfix,                                    desc = 'Quickfix list' },
                { '<leader>sQ', t.quickfixhistory,                             desc = 'Quickfix history' },
                { '<leader>sr', t.registers,                                   desc = 'Registers' },
                { '<leader>sR', t.reloader,                                    desc = 'Reload Lua modules' },
                { '<leader>ss', t.resume,                                      desc = 'Resume previous search' },
                { '<leader>st', t.tagstack,                                    desc = 'Tagstack' },
                { '<leader>sT', t.current_buffer_tags,                         desc = 'Tags in current buffer' },
                { '<leader>sw', t.lsp_document_symbols,                        desc = 'Symbols in document' },
                { '<leader>sW', t.lsp_workspace_symbols,                       desc = 'Symbols in workspace' },

                { 'z=', t.spell_suggest, desc = 'Fix spelling' },
            }
        end,
        build = 'make',
        config = function(_, _)
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
        -- TODO: Maybe replace this with something newer. This doesn't have descriptions for its mappings, so they don't
        -- show up properly in which-key.
        'tomtom/tcomment_vim', -- Comment operator
        config = function(_, _)
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
        build = 'make install_jsregexp',
        config = function(_, _)
            require('luasnip.loaders.from_snipmate').lazy_load()
        end,
    },

    {
        'folke/which-key.nvim', -- Spacemacs style popup for keybindings
        config = function(_, _)
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
        config = function(_, _)
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
        lazy = false, -- Always load this, even if we're not using any of the mappings, so that the signs show up
        keys = function()
            local g = require 'gitsigns'

            function toggle_gitnumhl()
                if g.toggle_numhl() then
                    print 'Git line number highlighting disabled'
                else
                    print 'Git line number highlighting enabled'
                end
            end

            function toggle_gitlinehl()
                if g.toggle_linehl() then
                    print 'Git line highlighting disabled'
                else
                    print 'Git line highlighting enabled'
                end
            end

            -- stylua: ignore
            return {
                { ']c',         g.next_hunk,                                                     desc = 'Next Git hunk' },
                { '[c',         g.prev_hunk,                                                     desc = 'Previous Git hunk' },
                { 'gb',         u.bind(g.blame_line, { full = true, ignore_whitespace = true }), desc = 'Git blame in popup' },
                { '<leader>gd', g.preview_hunk,                                                  desc = 'Diff' },
                { '<leader>gs', g.stage_hunk,                                                    desc = 'Stage hunk' },
                { '<leader>gx', g.reset_hunk,                                                    desc = 'Reset hunk' },
                { 'ih',         '<cmd>Gitsigns select_hunk<CR>',                                 desc = 'Git hunk', mode = 'x' },
                { 'ah',         '<cmd>Gitsigns select_hunk<CR>',                                 desc = 'Git hunk', mode = 'x' },
                { '<leader>tg', toggle_gitnumhl,                                                 desc = 'Git line number highlighting' },
                { '<leader>tl', toggle_gitlinehl,                                                desc = 'Git line highlighting' },
                -- These two might not work consistently. I had issues when mapping these with which-key, but mapping
                -- them with lazy.nvim seems to work so far.
                { 'ih',         g.select_hunk,                                                   desc = 'Git hunk', mode = 'o' },
                { 'ah',         g.select_hunk,                                                   desc = 'Git hunk', mode = 'o' },
            }
        end,
    },

    {
        'tpope/vim-fugitive', -- Git plugin, somewhat like magit
        -- stylua: ignore
        keys = {
            { '<leader>ga',  '<cmd>Git commit --amend<CR>',   desc = 'Commit --amend' },
            { '<leader>gb',  '<cmd>Git blame<CR>',            desc = 'Blame' },
            { '<leader>gc',  '<cmd>Git commit<CR>',           desc = 'Commit' },
            { '<leader>gf',  '<cmd>Git fetch<CR>',            desc = 'Fetch' },
            { '<leader>gg',  '<cmd>Git<CR>',                  desc = 'Status (g? for help)' },
            { '<leader>gl',  '<cmd>Git log<CR>',              desc = 'Log' },
            { '<leader>gL',  '<cmd>Gllog<CR>',                desc = 'Log to location list' },
            { '<leader>gS',  '<cmd>Gwrite<CR>',               desc = 'Save and stage current file' },
            { '<leader>gFp', '<cmd>Git pull<CR>',             desc = 'Pull' },
            { '<leader>gFa', '<cmd>Git pull --autostash<CR>', desc = 'Pull --autostash' },
            { '<leader>gpp', '<cmd>Git push<CR>',             desc = 'Push (confirm)' },
        },
    },

    -- TODO
    -- { 'tpope/vim-surround' }, -- Text objects for working with things that are surrounded by other things
    -- { 'tpope/vim-repeat' }, -- Lets vim-surround actions be repeated with '.'

    {
        'tpope/vim-eunuch', -- Provides some UNIX utilities such as :SudoWrite and :Move
        config = function(_, _)
            -- 'ca' sets command line abbreviations, like :cabbrev
            vim.keymap.set('ca', 'sw', 'SudoWrite')
            vim.keymap.set('ca', 'Sw', 'SudoWrite')
            vim.keymap.set('ca', 'SW', 'SudoWrite')
        end,
        -- stylua: ignore
        cmd = {
            'Chmod', 'Mkdir', 'Mkdir', 'SudoEdit', 'SudoWrite', 'Wall', 'W', 'Remove', 'Unlink', 'Delete', 'Copy',
            'Duplicate', 'Move', 'Rename', 'Cfind', 'Lfind', 'Clocate', 'Llocate'
        },
    },

    { 'wellle/targets.vim' }, -- Better text objects

    {
        'svermeulen/vim-subversive', -- Provides commands for replacing text with the contents of the clipboard
        lazy = true,
        -- stylua: ignore
        keys = {
            -- TODO: map range substitutions, see vim-subversive's GitHub repo.
            -- TODO: These overlap. S is a prefix of SS.
            { 'S',  '<Plug>(SubversiveSubstitute)',     desc = 'Subversive substitute' },
            { 'SS', '<Plug>(SubversiveSubstituteLine)', desc = 'Subversive substitute line' },
        },
    },

    {
        'windwp/nvim-autopairs', -- Automatically enter matching (){}[]""''
        -- TODO: simplify if possible
        config = function(_, _)
            require('nvim-autopairs').setup()
        end,
    },

    {
        'editorconfig/editorconfig-vim', -- Support for EditorConfig per-project style definition files
        config = function(_, _)
            -- Make EditorConfig not affect Fugitive buffers. This is recommended by the EditorConfig README
            vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*' }
        end,
    },

    {
        'johnsyweb/vim-makeshift', -- Autodetect build system
        lazy = true,
        config = function(_, _)
            -- Tell Makeshift about some extra build systems
            vim.g.makeshift_systems = {
                ['meson.build'] = 'ninja -C builddir',
                ['Cargo.toml'] = 'cargo build',
            }
        end,
        -- stylua: ignore
        keys = {
            { '<leader>M', '<cmd>LMakeshiftBuild<CR>',               desc = 'Make' },
            { '<leader>m', '<cmd>silent wall | LMakeshiftBuild<CR>', desc = 'Save and make' },
        },
    },

    { -- Fancy startup screen
        'mhinz/vim-startify',
        config = function(_, _)
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
            vim.g.startify_custom_header = u.lines(header)

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
        lazy = false,
        keys = {
            { '<leader>R', '<cmd>Startify<CR>', desc = 'Home screen' },
        },
    },

    { 'rust-lang/rust.vim' }, -- Some Rust features
    {
        'simrat39/rust-tools.nvim', -- Inlay hints with rust-analyzer
        config = function(_, _)
            local rust_analyzer_settings = u.with_overrides 'ra.json'

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
        end,
    },

    -- TODO
    --use 'lervag/vimtex' -- TeX support

    { 'jackguo380/vim-lsp-cxx-highlight' },
}
