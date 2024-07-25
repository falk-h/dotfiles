-- Set options from lua/options.lua
require 'options'

-- These must be set before loading plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = '<BS>'

-- Bootstrap the lazy.nvim plugin manager from lua/bootstrap-lazy.lua
require 'bootstrap-lazy'

-- Use Lua for filetype detection, see `:h new-filetype`
vim.g.do_filetype_lua = 1

require 'commands'
require 'filetypes'
require 'autocommands'
