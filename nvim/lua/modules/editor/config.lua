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

function config.mini_indentscope()
  require("mini.indentscope").setup({
    symbol = "│",
    options = {
      try_as_border = true,
    },
  })

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
    end,})
end

function config.indent_blankline()
  require("ibl").setup({
    indent = {
      char = "│",
      tab_char = "│",
    },
    scope = {
      enabled = false,
    },
    exclude = {
      filetypes = {
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
    },
  })
end

function config.indentmini()
  require("indentmini").setup({
    char = "│",
  })

  vim.api.nvim_set_hl(0, "IndentMini_Line_Grp", { ctermfg = 14, fg = 7109270 })
  vim.cmd.highlight("default link IndentLine IndentMini_Line_Grp")
end

return config
