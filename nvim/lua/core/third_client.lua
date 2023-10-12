-- load some config of neovide

-- font family and size
vim.o.guifont = "ComicMono Nerd Font:h13"
vim.g.neovide_scale_factor = 1.0

-- padding
vim.g.neovide_padding_top = 0
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_right = 0
vim.g.neovide_padding_left = 0

-- 浮动模糊量
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

-- 模糊
vim.g.neovide_transparency = 1

-- 动画
vim.g.neovide_scroll_animation_length = 0.1
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_cursor_trail_size = 0.2
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_animate_command_line = false

-- cursor size
vim.g.neovide_cursor_unfocused_outline_width = 0.125

-- 下划线自动缩放 
vim.g.neovide_underline_automatic_scaling = false

-- refresh rate
vim.g.neovide_refresh_rate = 60
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_no_idle = false

-- confirm quit
vim.g.neovide_confirm_quit = true

-- fullscreen
vim.g.neovide_fullscreen = true
vim.g.neovide_remember_window_size = true
vim.g.neovide_profiler = false
vim.g.neovide_input_use_logo = true

-- drag timeout
vim.g.neovide_touch_drag_timeout = 0.17

-- 粒子
vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_cursor_vfx_particle_lifetime = 3
vim.g.neovide_cursor_vfx_particle_density = 10.0
vim.g.neovide_cursor_vfx_opacity = 200.0
vim.g.neovide_cursor_vfx_particle_speed = 10.0
