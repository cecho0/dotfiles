local package = require("core.pack").package
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
  "gorbit99/codewindow.nvim",
  event = "BufEnter",
  config = function()
    require("codewindow").setup()
  end,
  enabled = not env.enable_plugin,
})

package({
  "catppuccin/nvim",
  event = "BufEnter",
  config = function()
    -- latte, frappe, macchiato, mocha
    --[[ vim.g.catppuccin_flavour = "macchiato"
    require("catppuccin").setup()
    vim.cmd [[colorscheme catppuccin]]
    --]]
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enabled = env.enable_plugin,
})

package({
  "folke/tokyonight.nvim",
  event = "BufEnter",
  config = function()
    --night storm day
    -- require("tokyonight").setup()
    -- vim.cmd[[colorscheme tokyonight-storm]]
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enabled = env.enable_plugin,
})

package({
  "sontungexpt/witch",
  priority = 1000,
  lazy = false,
  event = "BufEnter",
  config = function(_, opts)
    require("witch").setup(opts)
  end,
  enabled = env.enable_plugin,
})

package({
  "rose-pine/neovim",
  name = "rose-pine",
  event = "BufEnter",
  config = function()
    -- require("rose-pine").setup()
  end,
  enabled = env.enable_plugin,
})

package({
  "sainnhe/sonokai",
  event = "BufEnter",
  config = function()

  end,
  enabled = env.enable_plugin,
})
