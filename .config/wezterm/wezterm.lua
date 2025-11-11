local wezterm = require('wezterm')

local config = wezterm.config_builder and wezterm.config_builder() or {}
local act = wezterm.action
config.quit_when_all_windows_are_closed = false

local font_fallback = {
  'SF Mono Square',
  'SFMono Nerd Font',
  'UDEV Gothic NFLG',
  'JetBrainsMono Nerd Font',
  'Noto Sans Mono CJK JP',
}

config.font = wezterm.font_with_fallback(font_fallback)
config.font_size = 16.0
config.line_height = 1.0
config.cell_width = 1.0

config.initial_cols = 120
config.initial_rows = 30

config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.window_decorations = 'NONE'
config.window_background_opacity = 0.75
config.text_background_opacity = 0.9
config.macos_window_background_blur = 3
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
  left = 4,
  right = 4,
  top = 2,
  bottom = 2,
}
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}

config.audible_bell = 'Disabled'
config.default_cursor_style = 'SteadyBlock'
config.animation_fps = 60
config.max_fps = 120
config.disable_default_key_bindings = false
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'

config.keys = {
  { key = 'Escape', mods = 'NONE', action = act.SendKey({ key = 'Escape' }) },
  { key = '[', mods = 'CTRL', action = act.SendKey({ key = '[', mods = 'CTRL' }) },
  { key = 'C', mods = 'SUPER', action = act.CopyTo('Clipboard') },
  { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
  { key = 'V', mods = 'SUPER', action = act.PasteFrom('Clipboard') },
  { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
  { key = 'W', mods = 'SUPER', action = act.CloseCurrentTab({ confirm = false }) },
  { key = 'Q', mods = 'SUPER', action = act.QuitApplication },
  { key = 'H', mods = 'SUPER', action = act.HideApplication },
  { key = 'M', mods = 'SUPER', action = act.HideApplication },
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
  { key = 'q', mods = 'CTRL', action = act.SendKey({ key = 'q', mods = 'CTRL' }) },
}

config.colors = {
  foreground = '#CDD6F4',
  background = '#1E1E2E',
  cursor_bg = '#F5E0DC',
  cursor_border = '#F5E0DC',
  cursor_fg = '#1E1E2E',
  selection_bg = '#F5E0DC',
  selection_fg = '#1E1E2E',
  ansi = {
    '#45475A',
    '#F38BA8',
    '#A6E3A1',
    '#F9E2AF',
    '#89B4FA',
    '#F5C2E7',
    '#94E2D5',
    '#BAC2DE',
  },
  brights = {
    '#585B70',
    '#F38BA8',
    '#A6E3A1',
    '#F9E2AF',
    '#89B4FA',
    '#F5C2E7',
    '#94E2D5',
    '#A6ADC8',
  },
  indexed = {
    [16] = '#FAB387',
    [17] = '#F5E0DC',
  },
  tab_bar = {
    background = '#1E1E2E',
    active_tab = {
      bg_color = '#1E1E2E',
      fg_color = '#CDD6F4',
    },
    inactive_tab = {
      bg_color = '#1E1E2E',
      fg_color = '#585B70',
    },
    inactive_tab_hover = {
      bg_color = '#1E1E2E',
      fg_color = '#CDD6F4',
    },
    new_tab = {
      bg_color = '#1E1E2E',
      fg_color = '#CDD6F4',
    },
    new_tab_hover = {
      bg_color = '#1E1E2E',
      fg_color = '#CDD6F4',
    },
  },
}

config.set_environment_variables = {
  TERM = 'xterm-256color',
}

if wezterm.gui then
  local function normalize_window(window)
    if not window then
      return nil
    end
    if window.gui_window then
      local ok, gui_window = pcall(function()
        return window:gui_window()
      end)
      if ok and gui_window then
        window = gui_window
      end
    end
    if not window.get_dimensions then
      return nil
    end
    return window
  end

  local function center_on_main_display(window, attempt)
    attempt = attempt or 1
    if attempt > 6 then
      return
    end

    window = normalize_window(window)
    if not window then
      return
    end

    local screens = wezterm.gui.screens()
    if not screens then
      return
    end

    local main_screen = screens.main or screens.active
    if not main_screen then
      return
    end

    local dimensions = window:get_dimensions()
    if not dimensions or dimensions.is_full_screen then
      -- defer until we have valid dimensions / not fullscreen
      wezterm.time.call_after(0.1 * attempt, function()
        center_on_main_display(window, attempt + 1)
      end)
      return
    end

    if dimensions.pixel_width > 0 and dimensions.pixel_height > 0 then
      local centered_x = main_screen.x + math.floor((main_screen.width - dimensions.pixel_width) / 2)
      local centered_y = main_screen.y + math.floor((main_screen.height - dimensions.pixel_height) / 2)
      wezterm.log_info(string.format('Center attempt %d -> %d,%d', attempt, centered_x, centered_y))
      window:set_position(centered_x, centered_y)
    end

    if attempt < 6 then
      wezterm.time.call_after(0.1 * attempt, function()
        center_on_main_display(window, attempt + 1)
      end)
    end
  end

  wezterm.on('window-config-reloaded', function(window, _)
    center_on_main_display(window)
  end)

  wezterm.on('window-created', function(window, _)
    center_on_main_display(window)
  end)

  wezterm.on('window-resized', function(window, _)
    center_on_main_display(window)
  end)

  wezterm.on('gui-startup', function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    center_on_main_display(window)
  end)
end

return config
