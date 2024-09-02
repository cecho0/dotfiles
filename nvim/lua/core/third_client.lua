-- neovide gui client configure

-- font family and size
local function neovide_font()
  vim.o.guifont = "OperatorMono Nerd Font:h13"
  vim.g.neovide_scale_factor = 1.0
  -- cursor size
  vim.g.neovide_cursor_unfocused_outline_width = 0.125
end

-- animate
local function neovide_animate()
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = false
end

-- padding
local function neovide_padding()
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
end

-- float
local function neovide_float()
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
end

-- refresh
local function neovide_refresh()
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_no_idle = false
end

-- screen
local function neovide_screen()
  vim.g.neovide_fullscreen = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_profiler = false
  vim.g.neovide_input_use_logo = true
end

-- drag
local function neovide_drag()
  vim.g.neovide_touch_drag_timeout = 0.17
end

-- vfx
local function neovide_cursor_vfx()
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_vfx_particle_lifetime = 3
  vim.g.neovide_cursor_vfx_particle_density = 10.0
  vim.g.neovide_cursor_vfx_opacity = 200.0
  vim.g.neovide_cursor_vfx_particle_speed = 10.0
end

local function neovide_other()
  -- 模糊
  vim.g.neovide_transparency = 1
  -- 下划线自动缩放 
  vim.g.neovide_underline_automatic_scaling = false
  -- confirm quit
  vim.g.neovide_confirm_quit = true
end

local function neovide_init()
  neovide_font()
  neovide_animate()
  neovide_padding()
  neovide_float()
  neovide_refresh()
  neovide_screen()
  neovide_drag()
  neovide_cursor_vfx()
  neovide_other()
end

neovide_init()

