local api = vim.api
local config = {}

function config.dashboard()
  require("dashboard").setup({
    theme = "hyper",
    shortcut_type = "number",
    config = {
      header = {
        [[ /| 、   ]],
        [[(ﾟ、。7  ]],
        [[|、 ~丶  ]],
        [[じしf_,)/]],
        [[]],
      },
      disable_move = true,
      packages = { enable = true },
      project = { enable = false },
      mru = { enable = true, limit = 8, icon = " " },
      shortcut= {
        { icon = " ", desc = "Update", group = "Include", key = "u", action = "Lazy update" },
        { icon = "  ", desc = "New", group = "Function", key = "n", action = "NewFile"  },
        { icon = "  ", desc = "Config", group = "String", key = "c", action = "EditConfig" },
      },
      footer = {
        [[]],
        [[  hack is best]],
      },
    },
  })

  api.nvim_set_hl(0, "DashboardHeader", { fg = "#FFD39B" })
  api.nvim_set_hl(0, "DashboardFooter", { fg = "#b48EAD" })
  api.nvim_set_hl(0, "DashboardMruIcon", { fg = "#b48EAD" })
  api.nvim_set_hl(0, "DashboardMruTitle", { fg = "#b48EAD" })
  api.nvim_set_hl(0, "DashboardFiles", { fg = "#445555" })
end

return config
