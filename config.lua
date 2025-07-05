local function loadConfig()
  -- NOTE: EACH CONFIG SHOULD END WITH A COMMA
  return {

  -- Monitor Settings
  resolution = {1920, 1080},
  fullscreen = true,
  GUIscale = 3,

  -- Display Options
  showCurrentEU = true,
  showRate = true,
  showMaxEU = true,

  -- Enable wireless mode
  wirelessMode = false,
  -- Set the maximum value to reach 100%
  wirelessMax = 1e15,

  -- The % difference between rate of change levels (chevrons)
  rateThreshold = 0.003,
  -- View numbers in metric or scientic notation
  metric = true,

  -- Dimensions
  height = 12,
  length = 168,
  borderBottom = 2,
  borderTop = 2,
  fontSize = 3,

  -- Transparency
  shapeAlpha = 0.9,
  textAlpha = 1.0,

  -- Colors (see below for options)
  primaryColor = colors.electricBlue,
  secondaryColor = colors.darkSlateBlue,
  textColor = colors.black,
  issueColor = colors.red,
  borderColor = colors.darkGray,

  -- Seconds between updates
  sleep = 1}
end

colors = {
  red = 0xFF0000,
  orange = 0xFFA500,
  yellow = 0xFFFF00,
  green = 0x008000,
  blue = 0x0000FF, 
  indigo = 0x4B0082,
  violet = 0x800080,

  maroon = 0x800000,
  golden = 0xDAA520,
  lime = 0x00FF00,
  olive = 0x556B2F,
  cyan = 0x00FFFF,
  magenta = 0xFF00FF,
    
  black = 0x000000,
  white = 0xFFFFFF,
  gray = 0x3C5B72,
  lightGray = 0xA9A9A9,
  darkGray = 0x181828,

  electricBlue = 0x00A6FF,
  dodgerBlue = 0x1E90FF,
  steelBlue = 0x4682B4,
  midnightBlue = 0x191970,
  darkBlue = 0x000080,

  darkSlateGreen = 0x2F4F4F,
  darkSlateBlue = 0x303850}

return loadConfig()