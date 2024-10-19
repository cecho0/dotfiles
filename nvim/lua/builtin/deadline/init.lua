local api = vim.api
local M = {}
local config = {
  colorcolumn = "100",
  disabled_filetypes = {
    "help",
    "text",
    "markdown",
    "lspinfo",
    "dashboard",
    "checkhealth"
  },
  custom_colorcolumn = {},
  scope = "line",
}

local function exceed(buf, win, min_colorcolumn)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true) -- file scope
  if config.scope == "line" then
    lines = vim.api.nvim_buf_get_lines(
      buf,
      vim.fn.line(".", win) - 1,
      vim.fn.line(".", win),
      true
    )
  elseif config.scope == "window" then
    lines = vim.api.nvim_buf_get_lines(
      buf,
      vim.fn.line("w0", win) - 1,
      vim.fn.line("w$", win),
      true
    )
  end

  local max_column = 0

  for _, line in pairs(lines) do
    local success, column_number = pcall(vim.fn.strdisplaywidth, line)
    if not success then
      return false
    end

    max_column = math.max(max_column, column_number)
  end

  return not vim.tbl_contains(config.disabled_filetypes, vim.bo.ft) and max_column > min_colorcolumn
end

local function update()
  local buf_filetype = vim.api.nvim_buf_get_option(0, "filetype")
  local colorcolumns
  local win = api.nvim_get_current_win()
  local buf = api.nvim_get_current_buf()

  if vim.tbl_contains(config.disabled_filetypes, vim.bo.ft) then
    vim.wo[win].colorcolumn = ""
    return
  end

  if type(config.custom_colorcolumn) == "function" then
    colorcolumns = config.custom_colorcolumn()
  else
    colorcolumns = config.custom_colorcolumn[buf_filetype] or config.colorcolumn
  end

  local min_colorcolumn = tonumber(colorcolumns)

  local current_state = exceed(buf, win, min_colorcolumn)
  if current_state ~= vim.b.prev_state then
    print(current_state)
    vim.b.prev_state = current_state
    if current_state then
      vim.wo[win].colorcolumn = colorcolumns
    else
      vim.wo[win].colorcolumn = ""
    end
  end
end

local function disable()
  if vim.b.prev_state == nil or vim.b.prev_state == false then
    return
  end

  vim.wo[api.nvim_get_current_win()].colorcolumn = ""
  vim.b.prev_state = false
end

function M.setup()
  if config.custom_colorcolumn ~= nil
    and #config.custom_colorcolumn ~= 0
    and (type(config.custom_colorcolumn) ~= "function"
    or type(config.custom_colorcolumn) ~= "table") then
    vim.notify("[DeadColumn] config.custom_colorcolumn must be function that return string or table")
    return
  end

  local ins_group = api.nvim_create_augroup("DeadColumnEnable", { clear = true })
  api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI", "InsertCharPre" },
    {
      group = ins_group,
      callback = update,
    }
  )

  local nor_group = api.nvim_create_augroup("DeadColumnDisable", { clear = true })
  api.nvim_create_autocmd({ "InsertLeave" },
    {
      group = nor_group,
      callback = disable,
    }
  )
end

return M

