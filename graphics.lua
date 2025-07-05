local graphics = {}
local config   = require('config')

local function RGB(hex)
  local r = ((hex >> 16) & 0xFF) / 255.0
  local g = ((hex >> 8) & 0xFF) / 255.0
  local b = ((hex) & 0xFF) / 255.0
  return r, g, b
end

function graphics.quad(glasses, v1, v2, v3, v4, color)
  local quad = glasses.addQuad()
  quad.setVertex(1, v1[1], v1[2])
  quad.setVertex(2, v2[1], v2[2])
  quad.setVertex(3, v3[1], v3[2])
  quad.setVertex(4, v4[1], v4[2])
  quad.setColor(RGB(color))
  quad.setAlpha(config.shapeAlpha)
  return quad
end

function graphics.text(glasses, string, v1, scale, color)
  local text = glasses.addTextLabel()
  text.setText(string)
  text.setPosition(v1[1], v1[2])
  text.setScale(scale/3 or 1)
  text.setColor(RGB(color))
  text.setAlpha(config.textAlpha)
  return text
end

function graphics.metricParser(value) -- Creds: Vlamonster
  local units = {' ', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'}
  for i = 1, #units do
    if value < 1000 or i == #units then
      return string.format('%.1f%s', value, units[i])
    end
    value = value / 1000
  end
end

function graphics.scientificParser(value)
  value = string.format('%.2e', value)
  value = string.sub(value, 0, -4) .. string.sub(value, -2, -1)
  return value
end

function graphics.calcOffset(scale)
  if scale == 1 then
    return 71
  elseif scale == 2 then
    return 35
  elseif scale == 3 then
    return 23
  elseif scale == 4 then
    return 17
  else
    return 0
  end
end

function graphics.calcRate(percentage, last, threshold)
  if percentage > last + 2*threshold then
    return '>>>'
  elseif percentage > last + threshold then
    return '>>'
  elseif percentage >= last then
    return '>'
  elseif percentage > last - threshold then
    return '<'
  elseif percentage > last - 2*threshold then
    return '<<'
  else
    return '<<<'
  end
end

function graphics.fox()
  print('\27[34m' .. [[

                                   ⠀⢀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀
         ███████╗ ██████╗ ██╗  ██╗  ⣾⠙⠻⢶⣄⡀⠀⠀⠀⢀⣤⠶⠛⠛⡇
         ██╔════╝██╔═══██╗╚██╗██╔╝  ⢹⣇⠀⠀⣙⣿⣦⣤⣴⣿⣁⠀⠀⣸⠇
         █████╗  ██║   ██║ ╚███╔╝   ⠀⠙⣡⣾⣿⣿⣿⣿⣿⣿⣿⣷⣌⠋
         ██╔══╝  ██║   ██║ ██╔██╗   ⠀⣴⣿⣷⣄⡈⢻⣿⡟⢁⣠⣾⣿⣦
         ██║     ╚██████╔╝██╔╝ ██╗  ⠀⢹⣿⣿⣿⣿⠘⣿⠃⣿⣿⣿⣿⡏
         ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ⠀⣀⠀⠈⠛ ⠛ ⠛⠁⠀⣀
    ██╗  ██╗██╗   ██╗██████╗⠀       ⠀⢀⣼⣿⣦⠀   ⠀⣴⣿⡇
    ██║  ██║██║   ██║██╔══██⠀    ⣀⣤⣶⣾⣿⣿⣿⣿⡇⠀⠀⠀⢸⣿⣿
    ███████║██║   ██║██║  ██║⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠀⠀⠀⠾⢿⣿⠃
    ██╔══██║██║   ██║██║  █⣠⣿⣿⣿⣿⣿⣿⡿⠟⠋⣁⣠⣤⣤⡶⠶⠶⣤⣄⠈
    ██║  ██║╚██████╔╝█████⢰⣿⣿⣮⣉⣉⣉⣤⣴⣶⣿⣿⣋⡥⠄⠀⠀⠀⠀⠉⢻⣄
    ╚═╝  ╚═╝ ╚═════╝⠀╚════⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣋⣁⣤⣀⣀⣤⣤⣤⣤⣄⣿
                           ⠙⠿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠋⠉⠁⠀⠀⠀⠀⠈⠛
                             ⠀⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
  ]] .. '\27[0m')
end

return graphics