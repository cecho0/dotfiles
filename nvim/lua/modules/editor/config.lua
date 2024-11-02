local config = {}

function config.telescope()
  local telescope = require("telescope")
  local env = require("core.env")
  local enable_icons = not env.enable_icons

  telescope.setup{
    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key"
        }
      }
    },
    pickers = {
      find_files = {
        disable_devicons = enable_icons
      },
      live_grep = {
        disable_devicons = enable_icons
      },
      buffers = {
        disable_devicons = enable_icons
      },
      fd = {
        disable_devicons = enable_icons
      },
      grep_string = {
        disable_devicons = enable_icons
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- even more opts
        }
      },
      ["file_browser"] = {
        theme = "ivy",
        disable_devicons = enable_icons
      },
    }
  }

  telescope.load_extension("file_browser")
  telescope.load_extension("fzf")
end

function config.gitsigns()
  require("gitsigns").setup({
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "-" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
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
        local bufname = vim.api.nvim_buf_get_name(buf)
        local max_filesize = 300 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, bufname)
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
      additional_vim_regex_highlighting = false,
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
  require("spectre").setup({
    mapping = {
      ["tab"] = {
        cmd = "<cmd>lua require('spectre').tab()<cr>",
        desc = "next query"
      },
      ["shift-tab"] = {
        map = "<S-Tab>",
        cmd = "<cmd>lua require('spectre').tab_shift()<cr>",
        desc = "previous query"
      },
      ["toggle_line"] = {
        map = "dd",
        cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
        desc = "toggle item"
      },
      ["enter_file"] = {
        map = "<cr>",
        cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
        desc = "open file"
      },
      ["send_to_qf"] = {
        map = "<leader>sd",
        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
        desc = "send all items to quickfix"
      },
      ["replace_cmd"] = {
        map = "<leader>c",
        cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
        desc = "input replace command"
      },
      ["show_option_menu"] = {
        map = "<leader>o",
        cmd = "<cmd>lua require('spectre').show_options()<CR>",
        desc = "show options"
      },
      ["run_current_replace"] = {
        map = "<leader>rc",
        cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
        desc = "replace current line"
      },
      ["run_replace"] = {
        map = "<leader>R",
        cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
        desc = "replace all"
      },
      ["change_view_mode"] = {
        map = "<leader>v",
        cmd = "<cmd>lua require('spectre').change_view()<CR>",
        desc = "change result view mode"
      },
      ["change_replace_sed"] = {
        map = "trs",
        cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
        desc = "use sed to replace"
      },
      ["change_replace_oxi"] = {
        map = "tro",
        cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
        desc = "use oxi to replace"
      },
      ["toggle_live_update"]={
        map = "tu",
        cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
        desc = "update when vim writes to file"
      },
      ["toggle_ignore_case"] = {
        map = "ti",
        cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
        desc = "toggle ignore case"
      },
      ["toggle_ignore_hidden"] = {
        map = "th",
        cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
        desc = "toggle search hidden"
      },
      ["resume_last_search"] = {
        map = "<leader>l",
        cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
        desc = "repeat last search"
      },
        -- you can put your mapping here it only use normal mode
    },
  })
end

function config.mini_indent()
  require("indentmini").setup({
    -- char = "|",
    only_current = true,
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
