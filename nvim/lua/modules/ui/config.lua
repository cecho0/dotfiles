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

function config.catppuccin_nvim()
  -- latte, frappe, macchiato, mocha
  --[[ vim.g.catppuccin_flavour = "macchiato"
  require("catppuccin").setup()
  vim.cmd [[colorscheme catppuccin]]
  --]]
end

function config.tokyonight_nvim()
  --night storm day
  require("tokyonight").setup()
  vim.cmd[[colorscheme tokyonight-storm]]
end

return config
