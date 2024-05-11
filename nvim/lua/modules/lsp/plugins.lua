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
  "glepnir/lspsaga.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
  },
  ft = env.ft_enable,
  config = conf.lspsaga,
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

package({
  "L3MON4D3/LuaSnip",
  event = "InsertCharPre",
  config = conf.lua_snip,
  dependencies = {
    "rafamadriz/friendly-snippets"
  },
  enabled = env.enable_plugin and env.enable_lsp,
})

package({
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DB",
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  config = conf.dadbod_ui,
  enabled = env.enable_plugin and env.enable_lsp,
})
