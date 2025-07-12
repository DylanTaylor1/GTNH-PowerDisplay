local graphics  = require('graphics')
local config    = require('config')
local events    = require('events')
local component = require('component')
local term      = require('term')
local lsc       = component.gt_machine
local last      = 0
local glasses   = {}

-- Initialization
term.clear()
graphics.fox()

for address in component.list('glasses') do
	table.insert(glasses, component.proxy(component.get(address)))
end

-- Configure Graphics
local l = config.length
local h  = config.height
local b1 = config.borderBottom
local b2 = config.borderTop
local y  = config.resolution[2] / config.GUIscale

if not config.fullscreen then
  y = y - graphics.calcOffset(config.GUIscale)
end

for i=1, #glasses do
  glasses[i].removeAll()

  -- Draw Static Shapes
  graphics.quad(glasses[i], {0, y-b1}, {3.5*h+l+b2+1, y-b1}, {2.5*h+l+1, y-b1-h-b2}, {0, y-b1-h-b2}, config.borderColor)
  graphics.quad(glasses[i], {0, y}, {3.5*h+l+b2+1, y}, {3.5*h+l+b2+1, y-b1}, {0, y-b1}, config.borderColor)
  graphics.quad(glasses[i], {3.5*h, y-b1}, {3.5*h+l, y-b1}, {2.5*h+l, y-b1-h}, {2.5*h, y-b1-h}, config.secondaryColor)

  -- Draw Energy Bar
  glasses[i].energyBar = graphics.quad(glasses[i], {b2+3.25*h, y-b1}, {b2+3.25*h, y-b1}, {b2+2.25*h, y-b1-h}, {b2+2.25*h, y-b1-h}, config.primaryColor)
  glasses[i].textPercent = graphics.text(glasses[i], 'X.X%', {0.5*h, y-b1-h/1.8-config.fontSize}, config.fontSize, config.primaryColor)

  -- Draw Optional Values
  glasses[i].textCurr = graphics.text(glasses[i], '', {b2+3.25*h+1, y-b1-h/2-config.fontSize}, config.fontSize/1.3, config.textColor)
  glasses[i].textMax = graphics.text(glasses[i], '', {-2.25*h+l, y-b1-h/2-config.fontSize}, config.fontSize/1.3, config.textColor)
  glasses[i].textMaintenance = graphics.text(glasses[i], '', {b2, y-b1-b2-h-3*config.fontSize}, config.fontSize, config.issueColor)
end

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

  -- Adjust Values
  if config.showCurrentEU then
    if config.metric then
      curr = graphics.metricParser(power)
    else
      curr = graphics.scientificParser(power)
    end
  else
    curr = ''
  end

  if config.showRate then
    rate = graphics.calcRate(percentage, last, config.rateThreshold)
    last = percentage
  else
    rate = ''
  end

  for i=1, #glasses do

    -- Adjust Energy Bar
    glasses[i].energyBar.setVertex(2, b2+3.25*h+l*percentage, y-b1)
    glasses[i].energyBar.setVertex(3, b2+2.25*h+l*percentage, y-b1-h)

    if percentage > 0.999 then
      glasses[i].textPercent.setText('100%')
      glasses[i].textPercent.setPosition(b2+2.1*h-2*config.fontSize*(#glasses[i].textPercent.getText()), y-b1-h/1.8-config.fontSize)
    else
      glasses[i].textPercent.setText(string.format('%.1f%%', percentage*100))
      glasses[i].textPercent.setPosition(b2+2*h-2*config.fontSize*(#glasses[i].textPercent.getText()-1), y-b1-h/1.8-config.fontSize)
    end

    glasses[i].textCurr.setText(curr .. ' ' .. rate)

    if config.showMaxEU then
      if config.metric then
        glasses[i].textMax.setText(graphics.metricParser(capacity))
        glasses[i].textMax.setPosition(2.25*h+l-1.5*config.fontSize*(#glasses[i].textMax.getText()-1), y-b1-h/2-config.fontSize)
      else
        glasses[i].textMax.setText(graphics.scientificParser(capacity))
        glasses[i].textMax.setPosition(2.25*h+l-1.5*config.fontSize*(#glasses[i].textMax.getText()-1), y-b1-h/2-config.fontSize)
      end
    end

    -- Detect Maintenance Issues
    if #scan[17] < 43 then
      glasses[i].textMaintenance.setText('Has Problems!')
    else
      glasses[i].textMaintenance.setText('')
    end
  end

  -- Terminal Condition
  if events.needExit() then
    break
  end

  -- Pause
  os.sleep(config.sleep)
end

events.unhookEvents()
for i=1, #glasses do
  glasses[i].removeAll()
end