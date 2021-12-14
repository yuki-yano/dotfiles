-- https://github.com/asmagill/hs._asm.undocumented.spaces
local spaces = require('hs._asm.undocumented.spaces') 

local APP_NAME = 'Alacritty'
local KEY_EISUU = 102

-- Switch alacritty
hs.hotkey.bind({'ctrl'}, 'tab', function ()
  function moveWindow(alacritty, space, mainScreen)
    local win = nil
    while win == nil do
      win = alacritty:mainWindow()
    end
    win:spacesMoveTo(space)
    win:focus()
    hs.eventtap.keyStroke({}, 102)
  end
  local alacritty = hs.application.get(APP_NAME)
  if alacritty ~= nil and alacritty:isFrontmost() then
    alacritty:hide()
  else
    local space = spaces.activeSpace()
    local mainScreen = hs.screen.find(spaces.mainScreenUUID())
    if alacritty == nil and hs.application.launchOrFocus(APP_NAME) then
      local appWatcher = nil
      appWatcher = hs.application.watcher.new(function(name, event, app)
        if event == hs.application.watcher.launched and name == APP_NAME then
          app:hide()
          moveWindow(app, space, mainScreen)
          appWatcher:stop()
        end
      end)
      appWatcher:start()
    end
    if alacritty ~= nil then
      moveWindow(alacritty, space, mainScreen)
    end
  end
end)

-- Hide alacritty if not in focus
hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(window, appName)
  local alacritty = hs.application.get(APP_NAME)
  if alacritty ~= nil then
     alacritty:hide()
  end
end)
