local event     = require('event')
local events    = {}
local exitFlag  = false

function events.keyboardEvent(eventName, keyboardAddress, charNum, codeNum, playerName)
  -- Exit if 'c' was pressed
  if charNum == 99 then
    exitFlag = true
    return false -- Unregister this event listener
  end
end

function events.hookEvents()
  exitFlag = false
  event.listen('key_up', events.keyboardEvent)
end

function events.unhookEvents()
  event.ignore('key_up', events.keyboardEvent)
end

function events.needExit()
  return exitFlag
end

return events