local config = {}

function config.distant()
  require("distant"):setup({
    ["network.unix_socket"] = "/tmp/distant.sock",
  })
end

return config
