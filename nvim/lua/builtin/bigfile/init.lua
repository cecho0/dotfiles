local api = vim.api
local M = {}

local features = require "builtin.bigfile.features"

local default_config = {
  filesize = 2,
  pattern = { "*" },
  features = {
    -- "lsp",
    "treesitter",
    "syntax",
    "vimopts",
    "filetype",
  },
}

local function get_buf_size(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local ok, stats = pcall(function()
    return vim.loop.fs_stat(api.nvim_buf_get_name(bufnr))
  end)

  if not (ok and stats) then
    return
  end

  return math.floor(0.5 + (stats.size / (1024 * 1024)))
end

local function pre_bufread_callback(bufnr, config)
  local status_ok, _ = pcall(api.nvim_buf_get_var, bufnr, "bigfile_detected")
  if status_ok then
    return
  end

  local filesize = get_buf_size(bufnr) or 0
  local bigfile_detected = filesize >= config.filesize
  if type(config.pattern) == "function" then
    bigfile_detected = config.pattern(bufnr, filesize) or bigfile_detected
  end

  if not bigfile_detected then
    api.nvim_buf_set_var(bufnr, "bigfile_detected", 0)
    return
  end

  api.nvim_buf_set_var(bufnr, "bigfile_detected", 1)

  local matched_features = vim.tbl_map(function(feature)
    return features.get_feature(feature)
  end, config.features)

  local matched_deferred_features = {}
  for _, feature in ipairs(matched_features) do
    if feature.opts.defer then
      table.insert(matched_deferred_features, feature)
    else
      feature.disable(bufnr)
    end
  end

  api.nvim_create_autocmd({ "BufReadPost" }, {
    buffer = bufnr,
    callback = function()
      for _, feature in ipairs(matched_deferred_features) do
        feature.disable(bufnr)
      end
    end,
  })
end

function M.setup()
  local augroup = api.nvim_create_augroup("bigfile", {})
  local pattern = default_config.pattern

  api.nvim_create_autocmd("BufReadPre", {
    pattern = type(pattern) ~= "function" and pattern or "*",
    group = augroup,
    callback = function(args)
      pre_bufread_callback(args.buf, default_config)
    end,
    desc = string.format(
      "[bigfile.nvim] Performance rule for handling files over %sMiB",
      default_config.filesize
    ),
  })

  vim.g.loaded_bigfile_plugin = true
end

return M

