local package = require('core.pack').package
local conf = require("modules.ui.config")
local env = require("core.env")

package({
  "glepnir/dashboard-nvim",
  config = conf.dashboard,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  enabled = env.enable_plugin,
})

package({
  "Bekaboo/deadcolumn.nvim",
  event = "BufEnter",
  config = function()
    require("deadcolumn").setup()
  end,
  enabled = env.enable_plugin,
})

package({
  "gorbit99/codewindow.nvim",
  event = "BufEnter",
  config = function()
    require("codewindow").setup()
  end,
  enabled = env.enable_plugin,
})

package({
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup({
      window = {
        border = "single",
        position = "bottom",
      },
    })
  end,
  enabled = env.enable_plugin,
})

package({
  "echasnovski/mini.animate",
  event = "BufEnter",
  config = function()
    require("mini.animate").setup()
  end,
  enable = env.enable_plugin,
})

package({
  "catppuccin/nvim",
  config = conf.catppuccin_nvim,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enable = env.enable_plugin,
})

package({
  "folke/tokyonight.nvim",
  config = conf.tokyonight_nvim,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enable = env.enable_plugin,
})

