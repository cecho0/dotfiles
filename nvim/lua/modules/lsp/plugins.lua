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
  "williamboman/mason.nvim",
  config = conf.mason,
  cmd = "Mason",
  enabled = env.enable_plugin and env.enable_lsp,
})

package({
  "glepnir/lspsaga.nvim",
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

