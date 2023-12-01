local config = {}

function config.dashboard()
  vim.cmd("highlight DashboardHeader guifg='#FFD39B'")
  vim.cmd("highlight DashboardFooter guifg='#b48EAD'")

  require("dashboard").setup({
    theme = "hyper",
    config = {
      header = {
        [[ /| 、   ]],
        [[(ﾟ、。7  ]],
        [[|、 ~丶  ]],
        [[じしf_,)/]],
      },
      packages = { enable = true },
      project = { 
        enable = false,
        limit = 0
      },
      mru = { limit = 8 },
      shortcut= {
        { desc = "󰚰 Update", group = "DashboardFooter", key = "u", action = "Lazy update" },
        { desc = " New", group = "DashboardFooter", key = "n", action = "NewFile"  },
        { desc = " Config", group = "DashboardFooter", key = "c", action = "EditConfig" },
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

function config.deadcolumn()
  require("deadcolumn").setup()
end

function config.codewindow()
  local codewindow = require("codewindow")
  codewindow.setup()
end

function config.which_key()
  require("which-key").setup({
    window = {
      border = "single",
      position = "bottom",
    },
  })
end

return config
