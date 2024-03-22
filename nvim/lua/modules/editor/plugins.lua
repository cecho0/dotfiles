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
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufEnter",
  config = function()
    require("rainbow-delimiters")
  end,
  enabled = env.enable_plugin,
})

package({
  "utilyre/sentiment.nvim",
  event = "BufEnter",
  config = function()
    require("sentiment").setup()
  end,
  enabled = env.enable_plugin,
})

package({
  "norcalli/nvim-colorizer.lua",
  ft = { "lua", "css", "html", "sass", "less", "typescriptreact", "conf", "vim"},
  config = function()
    require("colorizer").setup()
  end,
  enabled = env.enable_plugin,
})

package({
  "echasnovski/mini.comment",
  event = "BufEnter",
  config = function()
    require("mini.comment").setup({
      mappings = {
        comment = "gc",
        comment_line = "gc",
        comment_visual = "gb",
        textobject = "gc",
      },
    })
  end,
  enabled = env.enable_plugin,
})

package({
  "echasnovski/mini.pairs",
  event = "BufEnter",
  config = function()
    require("mini.pairs").setup()
  end,
  enabled = env.enable_plugin,
})

package({
  "echasnovski/mini.indentscope",
  event = "BufEnter",
  config = conf.mini_indentscope,
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
  enabled = env.enable_plugin,
})

package({
  "lukas-reineke/indent-blankline.nvim",
  event = "BufEnter",
  config = conf.indent_blankline,
  enabled = env.enable_plugin,
})

package({
  "nvim-pack/nvim-spectre",
  config = conf.spectre,
  cmd = "Spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  enabled = env.enable_plugin,
})

