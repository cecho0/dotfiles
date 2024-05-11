local env = require("core.env")
local api = vim.api
local buffer = {}

local special_type_list = {
  "dashboard",
  "nofile",
  "help",
  "quickfix",
  "nvim",
  "terminal",
}

local function format_name(bufname, max_len)
  if bufname == nil or bufname == "" then
    return bufname
  end

  if vim.fn.strwidth(bufname) <= max_len then
    return bufname
  end

  local str = ""
  local total_len = 0
  for i = 0, vim.fn.strwidth(bufname), 1 do
    local char = vim.fn.strcharpart(bufname, i, 1)
    local char_w = vim.fn.strwidth(char)

    if total_len + char_w > max_len - 3 then
      str = str .. "..."
      break
    else
      total_len = total_len + char_w
      str = str .. char
    end
  end

  return str
end

function buffer:get_name()
  if self.buftype == "help" then
    return "help"
  elseif self.buftype == "quickfix" then
    return "quickfix"
  elseif self.buftype == "terminal" then
    return "terminal"
  elseif vim.fn.isdirectory(self.file) == 1 then
    return "directory"
  elseif self.file == "" then
    return "[No Name]"
  end

  return self.file
end

function buffer:get_short_file(filename)
  local start_idx = 0
  local last_idx = 0

  while true do
    start_idx = string.find(filename, env.sep, start_idx + 1)
    if start_idx ~= nil then
      last_idx = start_idx
    else
      return string.sub(filename, last_idx + 1)
    end
  end
end

function buffer:get_props(obj)
  local filepath = api.nvim_buf_get_name(self.bufnr)

  self.file = self:get_short_file(filepath)
  self.buftype = api.nvim_buf_get_option(self.bufnr, "buftype")
  self.filetype = api.nvim_buf_get_option(self.bufnr, "filetype")
  self.modified = api.nvim_buf_get_option(self.bufnr, "modified")
  self.name = format_name(self:get_name(), obj.config.tab_context_max_len)

  self.add = false
end

function buffer:get_render_str(obj)
  local modified_icon = self.modified and obj.config.icons.modified or nil
  local closed_icon = self.current and obj.config.icons.closed or nil
  local icon

  if closed_icon and modified_icon then
    icon = modified_icon
  elseif closed_icon then
    icon = closed_icon
  elseif modified_icon then
    icon = modified_icon
  else
    icon = " "
  end

  return " " .. self.name .. " " ..  icon
end

function buffer:new(obj, bufnr)
  if bufnr == nil then
    error("bufnr is nil")
  end

  local buf_obj = { bufnr = bufnr }
  self.__index = self
  buf_obj = setmetatable(buf_obj, self)
  buf_obj:get_props(obj)
  return buf_obj
end

function buffer:len(obj)
  return vim.fn.strwidth(self:get_render_str(obj))
end

function buffer:check_is_valid()
  return api.nvim_buf_is_valid(self.bufnr) and vim.bo[self.bufnr].buflisted
end

function buffer:check_is_special_type()
  return vim.tbl_contains(special_type_list, self.buftype)
end

function buffer:hl_str()
  local color_group = nil
  if self.current then
    color_group = "%#cur_buf_hl_grp#"
  else
    color_group = "%#nor_buf_hl_grp#"
  end
  return color_group
end

function buffer:hl_sep()
  local hl = nil

  if self.current then
    hl = "%#cur_sep_hl_grp#"
  else
    hl = "%#nor_sep_hl_grp#"
  end

  return hl
end

function buffer:render(obj)
  local left = self:hl_sep() .. obj.config.icons.sep.left
  local str = self:hl_str() .. self:get_render_str(obj)
  local right = self:hl_sep() .. obj.config.icons.sep.right

  return left .. str .. right
end

function gen_buffers(obj)
  local buf_list = api.nvim_list_bufs()
  local buffers = {}
  for i = 1, #buf_list do
    local buf = buffer:new(obj, buf_list[i])
    -- filter buffer, only add valid buffer
    if not buf:check_is_special_type() and buf:check_is_valid() then
      buffers[#buffers + 1] = buf
    end
  end

  -- get first, last and current bufnr
  for i, buf in pairs(buffers) do
    if i == 1 then
      buf.first = true
    end

    if i == #buffers then
      buf.last = true
    end

    if buf.bufnr == vim.fn.bufnr() then
      buf.current = true
    end
  end

  return buffers
end

function format_buffers(obj, buffers, max_percent)
  local max_length = math.floor(vim.o.columns - vim.fn.strwidth(obj.config.icons.first) * 2 - 2)

  local line = ""
  local total_length = 0
  local current
  local need_add_icon = false

  for i, buffer in pairs(buffers) do
    if buffer.current then
      current = i
    end
  end

  local current_buffer = buffers[current]
  if current_buffer == nil then
    local buf = buffer:new(obj, vim.fn.bufnr())
    buf.current = true
    buf.last = true
    buf.first = true
    line = buf:render(obj)
  else
    line = line .. current_buffer:render(obj)
    total_length = current_buffer:len(obj)

    local i = 0
    local before, after
    while true do
      i = i + 1
      before = buffers[current - i]
      after = buffers[current + i]

      -- only a buffer
      if before == nil and after == nil then
        break
      end

      -- add before one buffer
      if before then
        if total_length + before:len(obj) > max_length then
          need_add_icon = true
          break
        end
        total_length = total_length + before:len(obj)
        before.add = true
        line = before:render(obj) .. line
      end

      -- add after one buffer
      if after then
        if total_length + after:len(obj) > max_length then
          need_add_icon = true
          break
        end
        total_length = total_length + after:len(obj)
        after.add = true
        line = line .. after:render(obj)
      end

    end

    if need_add_icon then
      if before and not before.add then
        line = "%#first_hl_grp#" .. obj.config.icons.first .. " " .. line
      elseif before and (current - i) ~= 1 then
        line = "%#first_hl_grp#" .. obj.config.icons.first .. " " .. line
      end

      if after and not after.add then
        line = line .. " " .. "%#last_hl_grp#" .. obj.config.icons.last
      elseif after and (current + i) ~= #buffers then
        line = line .. " " .. "%#last_hl_grp#" .. obj.config.icons.last
      end
    end
  end

  line = "%#bg_hl_grp#" .. line .. "%#bg_hl_grp#"

  return line
end
