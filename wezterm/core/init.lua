local Config = {}

function Config:init()
  local o = {}
  self = setmetatable(o, { __index = Config })
  self.options = {}
  return o
end

function Config:append(new_options)
  for k, v in pairs(new_options) do
    self.options[k] = v
  end
  return self
end

return Config
