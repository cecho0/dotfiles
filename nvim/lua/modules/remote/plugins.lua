local env = require("core.env")
local package = require("core.pack").package
local conf = require("modules.remote.config")

package({
  "chipsenkbeil/distant.nvim",
  cmd = "Distant",
  config = conf.distant,
  enabled = env.enable_plugin,
})
