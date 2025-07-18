-- Quick IME (Alacritty + Neovim)
hs.allowAppleScript(true)
hs.console.clearConsole()

-- Paths
local alacritty_bin = '/Applications/Alacritty.app/Contents/MacOS/alacritty'
local nvim_bin = '/opt/homebrew/bin/nvim'
local quick_ime_cfg = os.getenv('HOME') .. '/.config/alacritty/quick-ime.toml'

-- Global state
_G.quick_ime_front_app = nil
_G.quick_ime_front_bundle = nil
_G.quick_ime_win = nil
_G.quick_ime_pid = nil
_G.quick_ime_watcher = nil

-- Logging
local function log(fmt, ...)
  hs.printf('[QuickIME] ' .. fmt, ...)
end

local APP_PASTE_CONFIG = {
  ['Alacritty'] = 'keystrokes',
}
local DEFAULT_PASTE_METHOD = 'clipboard'

local function pasteToCurrentAppLineByLine(text)
  text = text:gsub('[\r\n]+$', '')

  local lines = {}
  for line in text:gmatch('([^\n]*)\n?') do
    if line ~= '' or #lines > 0 then -- 空行も保持
      table.insert(lines, line)
    end
  end

  if #lines > 0 and lines[#lines] == '' then
    table.remove(lines)
  end

  for i, line in ipairs(lines) do
    hs.eventtap.keyStrokes(line)
    if i < #lines then
      hs.eventtap.keyStroke({}, 'return')
    end
  end
end

-- Find window
local function find_win()
  if _G.quick_ime_win then
    local success, result = pcall(function()
      return _G.quick_ime_win:isStandard() and _G.quick_ime_win:isVisible()
    end)
    if success and result then
      local title = _G.quick_ime_win:title() or ''
      if title:find('Quick IME') then
        return _G.quick_ime_win
      end
    end
    _G.quick_ime_win = nil
  end

  -- Search by PID
  if _G.quick_ime_pid then
    local app = hs.application.applicationForPID(_G.quick_ime_pid)
    if app then
      local wins = app:allWindows()
      for _, w in ipairs(wins) do
        local title = w:title() or ''
        if title:find('Quick IME') then
          _G.quick_ime_win = w
          return w
        end
      end
    end
  end

  return nil
end

-- Show window
local function show_win()
  local w = find_win()
  if not w then
    log('Show: Quick IME window not found.')
    return
  end

  w:raise()
  w:focus()
end

-- Hide window
local function hide_win()
  local w = find_win()
  if not w then
    log('hide_win: No window found')
    return
  end

  local app = w:application()
  if app then
    local windows = app:allWindows()
    local quickIMECount = 0
    for _, win in ipairs(windows) do
      local title = win:title() or ''
      if title:find('Quick IME') then
        quickIMECount = quickIMECount + 1
      end
    end

    if quickIMECount == #windows then
      log('Killing Alacritty app')
      app:kill()
    else
      log('Closing window with Cmd+W')
      w:focus()
      hs.eventtap.keyStroke({ 'cmd' }, 'w', 0)
    end
  end

  _G.quick_ime_win = nil
  _G.quick_ime_pid = nil
end

-- Restore front window
local function restore_front_window()
  if _G.quick_ime_front_app then
    _G.quick_ime_front_app:activate(true)
    return true
  end
  if _G.quick_ime_front_bundle then
    local app = hs.application.get(_G.quick_ime_front_bundle)
    if app then
      app:activate(true)
      return true
    end
  end
  return false
end

-- Setup focus watcher
local function setup_focus_watcher()
  if _G.quick_ime_watcher then
    _G.quick_ime_watcher:stop()
    _G.quick_ime_watcher = nil
  end

  _G.quick_ime_watcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
      local quickWin = find_win()
      if quickWin and appName ~= 'Alacritty' then
        log('Another app activated: %s, closing Quick IME', appName)
        hide_win()
        if _G.quick_ime_watcher then
          _G.quick_ime_watcher:stop()
          _G.quick_ime_watcher = nil
        end
      end
    end
  end)

  _G.quick_ime_watcher:start()
  log('Focus watcher started (using application watcher)')
end

-- Spawn process
local function spawn_proc()
  log('Launching Quick IME Alacritty...')

  local existing_win = find_win()
  if existing_win then
    log('Found existing Quick IME window, showing it')
    show_win()
    setup_focus_watcher()
    return
  end

  _G.quick_ime_win = nil
  _G.quick_ime_pid = nil

  local cmd = string.format(
    [[%s --config-file %q --title "Quick IME" -e env QUICK_IME=1 %q]],
    alacritty_bin,
    quick_ime_cfg,
    nvim_bin
  )

  local task = hs.task.new('/bin/zsh', function(exitCode, stdout, stderr)
    log('alacritty launch exitCode=%s', tostring(exitCode))
    if stderr and #stderr > 0 then
      log('stderr: %s', stderr)
    end
  end, { '-lc', cmd })

  task:start()
  log('Started new Alacritty process with new Neovim')

  -- Wait for window
  local tries = 0

  local function waitForWindow()
    tries = tries + 1
    local alacritty_apps = hs.application.applicationsForBundleID('org.alacritty') or {}
    for _, app in ipairs(alacritty_apps) do
      local wins = app:allWindows()
      for _, w in ipairs(wins) do
        local title = w:title() or ''
        if title:find('Quick IME') then
          _G.quick_ime_win = w
          _G.quick_ime_pid = app:pid()
          log('Found Quick IME window pid=%s', _G.quick_ime_pid)
          show_win()
          setup_focus_watcher()
          return
        end
      end
    end

    if tries < 50 then
      hs.timer.doAfter(0.02, waitForWindow)
    else
      log('Quick IME window not found after %d tries', tries)
    end
  end

  hs.timer.doAfter(0.02, waitForWindow)
end

-- Callback from Neovim
function _G.quick_ime_done()
  log('quick_ime_done() called')
  local w = find_win()
  if w then
    log('quick_ime_done: Window found, title=%s, isStandard=%s', w:title(), tostring(w:isStandard()))
  else
    log('quick_ime_done: Window NOT found')
  end

  local text = hs.pasteboard.getContents() or ''
  log('quick_ime_done: Clipboard text length=%d', #text)

  restore_front_window()

  local frontApp = hs.application.frontmostApplication()
  local appName = frontApp and frontApp:name() or nil
  local pasteMethod = DEFAULT_PASTE_METHOD

  if appName and APP_PASTE_CONFIG[appName] then
    pasteMethod = APP_PASTE_CONFIG[appName]
    log('Using paste method "%s" for app: %s', pasteMethod, appName)
  else
    log('Using default paste method "%s" for app: %s', pasteMethod, appName or 'unknown')
  end

  if pasteMethod == 'keystrokes' then
    pasteToCurrentAppLineByLine(text)
  else -- "clipboard"
    hs.pasteboard.setContents(text)
    hs.eventtap.keyStroke({ 'cmd' }, 'v')
  end

  hide_win()
  if _G.quick_ime_watcher then
    _G.quick_ime_watcher:stop()
    _G.quick_ime_watcher = nil
  end
end

-- Hotkey handler
function QuickIMEAlacrittyToggle()
  log('Hotkey pressed.')

  local front_app = hs.application.frontmostApplication()
  local front_win = hs.window.frontmostWindow()
  local quick_win = find_win()
  if quick_win and front_win and front_win:id() == quick_win:id() then
    log('Quick IME is active, closing it')
    restore_front_window()
    hide_win()
    if _G.quick_ime_watcher then
      _G.quick_ime_watcher:stop()
      _G.quick_ime_watcher = nil
    end
    return
  end

  _G.quick_ime_front_app = front_app
  _G.quick_ime_front_bundle = front_app and front_app:bundleID() or nil

  log('Captured front app: bundle=%s', _G.quick_ime_front_bundle or 'nil')

  spawn_proc()
end

-- Register hotkey
hs.hotkey.bind({ 'cmd' }, 'i', QuickIMEAlacrittyToggle)

log('Quick IME Alacritty init loaded.')
