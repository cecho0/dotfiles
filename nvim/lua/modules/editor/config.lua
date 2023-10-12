local config = {}

function config.telescope()
  local telescope = require("telescope")

  telescope.setup{
    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key"
        }
      }
    },
    pickers = {
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- even more opts
        }
      },
      ["file_browser"] = {
        theme = "ivy",
      },
    }
  }

  telescope.load_extension("file_browser")
end

function config.gitsigns()
  require("gitsigns").setup({
    signs = {
      add          = { text = '+' },
      change       = { text = '~' },
      delete       = { text = '-' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 500,
      ignore_whitespace = false,
    },
    attach_to_untracked = true,
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1
    },
  })
end

function config.nvim_colorizer()
  require("colorizer").setup()
end

function config.sentiment()
  require("sentiment").setup()
end

function config.autopairs()
  require('ultimate-autopair').setup()
end

function config.nvim_treesitter()
  local env = require "core.env"

  require("nvim-treesitter.configs").setup({
    parser_install_dir = env.data_home,
    ensure_installed = {
      "c",
      "cpp",
      "rust",
      "go",
      "lua",
      "python",
      "html",
      "css",
      "javascript",
      "vue",
      --"sql",
      "cmake",
      "bash",
      "proto",
      "dockerfile",
      "json",
      "markdown",
      "toml",
      "yaml",
    },
    sync_install = false,
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<BS>",
        --scope_incremental = "<TAB>"
      }
    },
    indent = {
      enable = true
    },
  })

  vim.opt.runtimepath:append(env.data_home)
end

function config.nvim_ts_rainbow()
  require("nvim-treesitter.configs").setup {
    highlight = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true,
     --   --colors = {}, -- table of hex strings
     --   --termcolors = {} -- table of colour name strings
    },
  }
end

function config.comment()
  require("Comment").setup({
    padding = true,
    sticky = true,
    ignore = nil,
    toggler = {
        line = "gc",
        block = "gb",
    },
    ---LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
        line = "gc",
        block = "gb",
    },
    extra = {
        above = "gcO",
        below = "gco",
        eol = "gcA",
    },
    ---Enable keybindings
    mappings = {
        ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        ---Extra mapping; `gco`, `gcO`, `gcA`
        extra = false,
    },
    pre_hook = nil,
    post_hook = nil,
  })
end

return config
