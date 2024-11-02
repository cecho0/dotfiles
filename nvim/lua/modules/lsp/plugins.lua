
local package = require("core.pack").package
local conf = require("modules.lsp.config")
local env = require("core.env")

package({
  "neovim/nvim-lspconfig",
  ft = env.ft_enable,
  config = conf.nvim_lspconfig,
  enabled = env.enable_plugin and env.enable_lsp,
})

package({
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  config = conf.nvim_cmp,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "saadparwaiz1/cmp_luasnip",
  },
  enabled = env.enable_plugin and env.enable_lsp,
})

-- package({
--   "saghen/blink.cmp",
--   dependencies = "rafamadriz/friendly-snippets",
--   version = 'v0.*',
--   event = "InsertEnter",
--   opts = {
--     keymap = {
--       ['<C-space>']  = { 'show', 'show_documentation', 'hide_documentation' },
--       ['<C-e>'] = { 'hide' },
--       ['<Tab>'] = { 'snippet_forward', 'fallback' },
--       ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
--       ['<C-y>'] = { 'select_and_accept' },
--       ['<Up>'] = { 'select_prev', 'fallback' },
--       ['<Down>'] = { 'select_next', 'fallback' },
--       ['<C-p>'] = { 'select_prev', 'fallback' },
--       ['<C-n>'] = { 'select_next', 'fallback' },
--       ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
--       ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
--     },
--     highlight = {
--       use_nvim_cmp_as_default = true,
--     },
--     windows = {
--       autocomplete = {
--         border = "single",
--       }
--     },
--     nerd_font_variant = "normal",
--     -- experimental auto-brackets support
--     accept = {
--       auto_brackets = {
--         enabled = true
--       }
--     },
--     -- experimental signature help support
--     trigger = {
--       signature_help = {
--         enabled = true
--       }
--     },
--   },
--   enabled = env.enable_plugin and env.enable_lsp,
-- })

package({
  "glepnir/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = env.ft_enable,
  config = conf.lspsaga,
  enabled = env.enable_plugin and env.enable_lsp,
})

-- package({
--   "Wansmer/symbol-usage.nvim",
--   event = "LspAttach", -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
--   config = function()
--     -- require('symbol-usage').setup()
--   end,
--   enabled = false,
-- })

package({
  "L3MON4D3/LuaSnip",
  event = "InsertCharPre",
  config = conf.lua_snip,
  dependencies = {
    "rafamadriz/friendly-snippets"
  },
  enabled = env.enable_plugin and env.enable_lsp,
})
