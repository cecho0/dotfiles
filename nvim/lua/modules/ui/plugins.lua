local package = require('core.pack').package
local conf = require("modules.ui.config")
local env = require("core.env")

package({
  "glepnir/dashboard-nvim",
  config = conf.dashboard,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  enabled = env.enable_plugin,
})

package({
  "nvimdev/indentmini.nvim",
  event = "BufEnter",
  config = conf.indentmini,
  enabled = env.enable_plugin,
})

package({
  "Bekaboo/deadcolumn.nvim",
  event = "BufEnter",
  config = conf.deadcolumn,
  enabled = env.enable_plugin,
})

package({
  "gorbit99/codewindow.nvim",
  event = "BufEnter",
  config = conf.codewindow,
  enabled = env.enable_plugin,
})

