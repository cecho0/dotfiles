local M = {}

M.default = {
  tab_context_max_len = 15,
  icons = {
    modified  = " ",
    closed    = "x",
    sep = {
      left  = "",
      right = "",
    },
    last      = " ",
    first     = " ",
  },
  colors = {
    cur_buf_hl_grp = {
      fg = "#ED9121",
      bg = "#3b4261",
      bold = true,
    },
    nor_buf_hl_grp = {
      fg = "#283b4d",
      bg = "#737aa2",
    },
    cur_sep_hl_grp = {
      fg = "#3b4261",
      bg = "NONE",
    },
    nor_sep_hl_grp = {
      fg = "#737aa2",
      bg = "NONE",
    },
    bg_hl_grp = {
      fg = "NONE",
      bg = "NONE",
    },
    first_hl_grp = {
      fg = "#ED9121",
      bg = "NONE",
    },
    last_hl_grp = {
      fg = "#ED9121",
      bg = "NONE",
    },
  }
}

return M

