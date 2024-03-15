local wezterm = require("wezterm")
local platform = require("core.utils.platform").check_platform()

local M = {
  launch_menu = {}
}

local ssh_cmd = {"powershell.exe", "ssh"}
if platform.is_win then
  ssh_cmd = {"powershell.exe", "ssh"}
  M.launch_menu = {
    { label = "🟣 Nushell", args = { "nu" } },
    { label = "🔵 PowerShell Core", args = { "pwsh" } },
    { label = "🟢 PowerShell Desktop", args = { "powershell" } },
    -- { label = "Command Prompt", args = { "cmd" } },
  }
elseif platform.is_linux or platform.is_mac then
  ssh_cmd = {"zsh", "ssh"}
  M.launch_menu = {
    { label = "🟣 Zsh", args = { "zsh" } },
    { label = "🔵 Bash", args = { "bash" } },
  }
end

local ssh_config_file = wezterm.home_dir .. "/.ssh/config"
local f = io.open(ssh_config_file)
if f then
  local line = f:read("*l")
  while line do
    if line:find("Host ") == 1 then
      local host = line:gsub("Host ", "")
      local args = {}
      for i, v in pairs(ssh_cmd) do
        args[i] = v
      end
      args[#args+1] = host
      table.insert(
        M.launch_menu,
        {
          label = "SSH " .. host,
          args = args,
        }
      )
    end
    line = f:read("*l")
  end
  f:close()
end

return M
