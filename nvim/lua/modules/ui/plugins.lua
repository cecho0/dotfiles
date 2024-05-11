local package = require("core.pack").package
local conf = require("modules.ui.config")
local env = require("core.env")

package({
  "nvim-tree/nvim-web-devicons",
  enabled = env.icons_enable,
})

package({
  "glepnir/dashboard-nvim",
  config = conf.dashboard,
  dependencies = {
      "nvim-tree/nvim-web-devicons",
  },
  enabled = env.enable_plugin and env.icons_enable,
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
  enabled = not env.enable_plugin,
})

package({
  "catppuccin/nvim",
  config = function()
    -- latte, frappe, macchiato, mocha
    --[[ vim.g.catppuccin_flavour = "macchiato"
    require("catppuccin").setup()
    vim.cmd [[colorscheme catppuccin]]
    --]]
  end,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enabled = env.enable_plugin,
})

package({
  "folke/tokyonight.nvim",
  config = function()
    --night storm day
    -- require("tokyonight").setup()
    -- vim.cmd[[colorscheme tokyonight-storm]]
  end,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enabled = env.enable_plugin,
})

package({
  "rebelot/kanagawa.nvim",
  config = function()
    require("kanagawa").setup({
        compile = true,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true},
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        colors = {
            palette = {},
            theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors)
            return {}
        end,
        theme = "dragon",
        background = {
            dark = "wave",
            light = "lotus"
        },
    })

    vim.cmd("colorscheme kanagawa")
  end,
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  enabled = env.enable_plugin,
})
