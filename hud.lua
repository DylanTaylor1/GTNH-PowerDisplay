local graphics  = require('graphics')
local config    = require('config')
local events    = require('events')
local component = require('component')
local term      = require('term')
local glasses   = component.glasses
local lsc       = component.gt_machine
local last      = 0

glasses.removeAll()
term.clear()
graphics.fox()

-- Configure Graphics
local l = config.length
local h  = config.height
local b1 = config.borderBottom
local b2 = config.borderTop
local y  = config.resolution[2] / config.GUIscale

if not config.fullscreen then
  y = y - graphics.calcOffset(config.GUIscale)
end

-- Draw Static Shapes
graphics.quad(glasses, {0, y-b1}, {3.5*h+l+b2+1, y-b1}, {2.5*h+l+1, y-b1-h-b2}, {0, y-b1-h-b2}, config.borderColor)
graphics.quad(glasses, {0, y}, {3.5*h+l+b2+1, y}, {3.5*h+l+b2+1, y-b1}, {0, y-b1}, config.borderColor)
graphics.quad(glasses, {3.5*h, y-b1}, {3.5*h+l, y-b1}, {2.5*h+l, y-b1-h}, {2.5*h, y-b1-h}, config.secondaryColor)

-- Draw Energy Bar
energyBar = graphics.quad(glasses, {b2+3.25*h, y-b1}, {b2+3.25*h, y-b1}, {b2+2.25*h, y-b1-h}, {b2+2.25*h, y-b1-h}, config.primaryColor)
textPercent = graphics.text(glasses, 'X.X%', {0.5*h, y-b1-h/2-config.fontSize}, config.fontSize, config.primaryColor)

-- Draw Optional Values
textCurr = graphics.text(glasses, '', {b2+3.25*h+1, y-b1-h/2-config.fontSize}, config.fontSize/1.3, config.textColor)
textMax = graphics.text(glasses, '', {-2.25*h+l, y-b1-h/2-config.fontSize}, config.fontSize/1.3, config.textColor)
textMaintenance = graphics.text(glasses, '', {b2, y-b1-b2-h-3*config.fontSize}, config.fontSize, config.issueColor)

-- Stand Ready for Exit Command
events.hookEvents()

-- ===== MAIN LOOP =====
while true do

  -- Retrieve LSC data
  scan = lsc.getSensorInformation()
  
  if config.wirelessMode then
    power = scan[23]:gsub('%D', '')
    power = tonumber(power)
    capacity = config.wirelessMax
  else
    power = lsc.getEUStored()
    capacity = lsc.getEUMaxStored()
  end

  local percentage = math.min(power / capacity, 1)

  -- Adjust Energy Bar
  energyBar.setVertex(2, b2+3.25*h+l*percentage, y-b1)
  energyBar.setVertex(3, b2+2.25*h+l*percentage, y-b1-h)

  if percentage > 0.999 then
    textPercent.setText('100%')
    textPercent.setPosition(b2+2.1*h-2*config.fontSize*(#textPercent.getText()), y-b1-h/2-config.fontSize)
  else
    textPercent.setText(string.format('%.1f%%', percentage*100))
    textPercent.setPosition(b2+2*h-2*config.fontSize*(#textPercent.getText()-1), y-b1-h/2-config.fontSize)
  end

  -- Adjust Optional Values
  if config.showCurrentEU then
    if config.metric then
      curr = graphics.metricParser(power)
    else
      curr = graphics.scientificParser(power)
    end
  else
    curr = ""
  end

  if config.showRate then
    rate = graphics.calcRate(percentage, last, config.rateThreshold)
    last = percentage
  else
    rate = ""
  end

  textCurr.setText(curr .. " " .. rate)

  if config.showMaxEU then
    if config.metric then
      textMax.setText(graphics.metricParser(capacity))
      textMax.setPosition(2.25*h+l-1.5*config.fontSize*(#textMax.getText()-1), y-b1-h/2-config.fontSize)
    else
      textMax.setText(graphics.scientificParser(capacity))
      textMax.setPosition(2.25*h+l-1.5*config.fontSize*(#textMax.getText()-1), y-b1-h/2-config.fontSize)
    end
  end

  -- Detect Maintenance Issues
  if #scan[17] < 43 then
    textMaintenance.setText('Has Problems!')
  else
    textMaintenance.setText('')
  end

  -- Terminal Condition
  if events.needExit() then
    break
  end

  -- Pause
  os.sleep(config.sleep)
end

events.unhookEvents()
glasses.removeAll()