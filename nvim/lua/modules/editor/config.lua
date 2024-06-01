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
    highlight = {
      enable = true,
      disable = function(_, buf)
        return vim.api.nvim_buf_line_count(buf) > 5000
      end,
    },
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

function config.spectre()
  require("spectre").setup()
end

function config.mini_indent()
  require("indentmini").setup({
    -- char = "|",
    current = true,
    exclude = {
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
  })

  vim.cmd.highlight("IndentLine guifg=#999999")
  vim.cmd.highlight("IndentLineCurrent guifg=#f4a460")
end

return config
