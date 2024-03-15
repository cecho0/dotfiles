return {
  -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
  ssh_domains = {
    {
      multiplexing = "None",
      name = "ubuntu-dev",
      remote_address = '10.6.1.84:22',

      -- Whether agent auth should be disabled.
      -- Set to true to disable it.
      -- no_agent_auth = false,

      -- The username to use for authenticating with the remote host
      username = "cecho",
      -- ssh_option = {
      --    identityfile = 'C:\\Users\\Fizz\\.ssh\\id_rsa',
      -- },
    },
  },

  unix_domains = {},

  -- wsl_domains = {
  --    {
  --       name = 'WSL:Ubuntu',
  --       distribution = 'Ubuntu',
  --       username = 'kevin',
  --       default_cwd = '/home/kevin',
  --       default_prog = { 'fish' },
  --    },
  -- },
}
