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

return config
