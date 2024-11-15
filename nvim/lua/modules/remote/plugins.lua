local env = require("core.env")
local package = require("core.pack").package
local conf = require("modules.remote.config")

package({
  "chipsenkbeil/distant.nvim",
  cmd = "Distant",
  config = conf.distant,
  enabled = not env.enable_plugin,
})
