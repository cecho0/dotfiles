local package = require('core.pack').package
local conf = require("modules.editor.config")
local env = require("core.env")

package({
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  config = conf.telescope,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "BurntSushi/ripgrep",
    "sharkdp/fd",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  enabled = env.enable_plugin,
})

package({
  "lewis6991/gitsigns.nvim",
  event = "BufRead",
  config = conf.gitsigns,
  enabled = env.enable_plugin,
})

package({
  "nvim-treesitter/nvim-treesitter",
  event = "BufRead",
  config = conf.nvim_treesitter,
  enabled = env.enable_plugin,
})

package({
  "p00f/nvim-ts-rainbow",
  event = "BufEnter",
  config = conf.nvim_ts_rainbow,
  enabled = env.enable_plugin,
})

package({
  "utilyre/sentiment.nvim",
  event = "BufEnter",
  config = conf.sentiment,
  enabled = env.enable_plugin,
})

package({
  "altermo/ultimate-autopair.nvim",
  event = {
    "InsertEnter",
    "CmdlineEnter"
  },
  config = conf.autopairs,
  enabled = env.enable_plugin and env.enable_lsp,
})

package({
  "norcalli/nvim-colorizer.lua",
  ft = { "lua", "css", "html", "sass", "less", "typescriptreact", "conf", "vim"},
  config = conf.nvim_colorizer,
  enabled = env.enable_plugin,
})

package({
  "numToStr/Comment.nvim",
  event = "BufEnter",
  config = conf.comment,
  ft = env.ft_enable,
  enabled = env.enable_plugin,
})

