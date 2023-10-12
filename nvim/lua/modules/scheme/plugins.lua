local package = require("core.pack").package
local conf = require("modules.scheme.config")

package({
  "catppuccin/nvim",
  config = conf.catppuccin_nvim,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
})

package({
  "folke/tokyonight.nvim",
  config = conf.tokyonight_nvim,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
})

package({
  "rose-pine/neovim",
  event = "BufEnter",
  config = conf.neovim,
})

