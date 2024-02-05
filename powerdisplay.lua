local computer = require("computer")
local colors = require("lib.graphics.colors")
local ar = require("lib.graphics.ar")
local parser = require("lib.utils.parser")
local screen = require("lib.utils.screen")
local states = require("server.entities.states")
local serialization = require("serialization")
local powerDisplay = {}
local hudObjects = {}
local updateInterval = 100
local energyUnit = "EU"


local function getNewTable(size, value)
    local array = {}
    for i = 1, size, 1 do
        array[i] = value
    end
    return array
end


local function updateMaxEU(value)
    local file = io.open("/home/NIDAS/settings/maxWireless", "w")
    if file then
        file:write(serialization.serialize({maxCapacity = value}))
        file:close()
    end
end


local function getMaxEU()
    file = io.open("/home/NIDAS/settings/maxWireless", "r")
    local maxValue = 10e5
    if file ~= nil then
        local data = serialization.unserialize(file:read("*a"))
        if maxValue then
            maxValue = data.maxCapacity
        end
        file:close()
    end
    return maxValue
end


local energyData = {
    intervalCounter = 1,
    readings = {},
    hourData = {intervalCounter = 1, readings = {}, average = 0, startTime = 0, endTime = 0},
    minuteData = {intervalCounter = 1, readings = {}, average = 0, startTime = 0, endTime = 0},
    startTime = 0,
    endTime = 0,
    updateInterval = updateInterval,
    energyPerTick = 0,
    offset = 0,
    highestInput = 1,
    highestOutput= -1,
    energyIn = getNewTable(updateInterval, 0),
    energyOut = getNewTable(updateInterval, 0),
    input = 0,
    output = 0,
    wirelessMode = false
}


function powerDisplay.changeColor(glasses, backgroundColor, primaryColor, accentColor)
    for i = 1, #hudObjects do
        if hudObjects[i] and hudObjects[i].glasses ~= nil and hudObjects[i].glasses.address == glasses then

            if backgroundColor ~= nil then
                for j = 1, #hudObjects[i].static do
                    hudObjects[i].static[j].setColor(screen.toRGB(backgroundColor))
                end
            end

            if primaryColor ~= nil then
                hudObjects[i].dynamic.energyBar.setColor(screen.toRGB(primaryColor))
                -- hudObjects[i].dynamic.currentEU.setColor(screen.toRGB(primaryColor))
            end

            if accentColor ~= nil then
                hudObjects[i].dynamic.percentage.setColor(screen.toRGB(accentColor))
            end
        end
    end
end

--Scales: Small = 1, Normal = 2, Large = 3, Auto = 4x to 10x (Even)
local currentEU = 0
local maxEU = getMaxEU()
local tick = 0

function powerDisplay.widget(glasses, data)
    if data ~= nil and data.state ~= states.MISSING then

        --Wireless EU addition
        if energyData.wirelessMode or data.wirelessEU > 10000000 then
            energyData.wirelessMode = true
            currentEU = data.wirelessEU
            if currentEU > maxEU then
                maxEU = maxEU * 10
                updateMaxEU(maxEU)
            end
        else
            currentEU = math.abs(math.floor(data.storedEU))
            maxEU = math.abs(math.floor(data.EUCapacity))
        end

        local percentage = math.min(currentEU/maxEU, 1.0)
        if percentage >= 0.999 then
            currentEU = maxEU
            percentage = 1.0
        end

        tick = tick + 1
        if tick > 72100 then tick = 0 end

        --Update I/O
        if energyData.intervalCounter == 1 then
            energyData.startTime = computer.uptime()
            energyData.readings[1] = currentEU
        end

        if energyData.intervalCounter < energyData.updateInterval then
            energyData.intervalCounter = energyData.intervalCounter + 1
            energyData.energyIn[energyData.intervalCounter] = data.EUIn
            energyData.energyOut[energyData.intervalCounter] = data.EUOut
        end

        if energyData.intervalCounter == energyData.updateInterval then
            energyData.endTime = computer.uptime()
            energyData.readings[2] = currentEU

            local ticks = math.ceil((energyData.endTime - energyData.startTime) * 20)
            energyData.energyPerTick = math.floor((energyData.readings[2] - energyData.readings[1])/ticks)
            if energyData.energyPerTick >= 0 then
                if energyData.energyPerTick > energyData.highestInput then
                    energyData.highestInput = energyData.energyPerTick
                end
            else
                if energyData.energyPerTick < energyData.highestOutput then
                    energyData.highestOutput = energyData.energyPerTick
                end
            end
            energyData.intervalCounter = 1
        end

        energyData.offset = energyData.offset + 2
        if energyData.energyPerTick >= 0 then
            energyData.offset = energyData.offset + 10*(energyData.energyPerTick / energyData.highestInput)
        else
            energyData.offset = energyData.offset + 10*(energyData.energyPerTick / energyData.highestOutput)
        end

        -- 5 minute average
        if energyData.minuteData.intervalCounter == 1 then
            energyData.minuteData.startTime = computer.uptime()
            energyData.minuteData.readings[1] = currentEU
            energyData.minuteData.intervalCounter = energyData.minuteData.intervalCounter + 1
        end

        if tick % 6000 == 0 then
            energyData.minuteData.endTime = computer.uptime()
            energyData.minuteData.readings[2] = currentEU
            local ticks = math.ceil((energyData.minuteData.endTime - energyData.minuteData.startTime) * 20) + 1
            energyData.minuteData.average = ((energyData.minuteData.readings[2] - energyData.minuteData.readings[1])/ticks)
            energyData.minuteData.intervalCounter = 1
        end

        if energyData.hourData.intervalCounter == 1 then
            energyData.hourData.startTime = computer.uptime()
            energyData.hourData.readings[1] = currentEU
            energyData.hourData.intervalCounter = energyData.hourData.intervalCounter + 1
        end

        if tick % 72000 == 0 then
            energyData.hourData.endTime = computer.uptime()
            energyData.hourData.readings[2] = currentEU
            local ticks = math.ceil((energyData.hourData.endTime - energyData.hourData.startTime) * 20) + 1
            energyData.hourData.average = ((energyData.hourData.readings[2] - energyData.hourData.readings[1])/ticks)
            energyData.hourData.intervalCounter = 1
        end

        if #hudObjects < #glasses then
            for i = 1, #glasses do
                if glasses[i][1] == nil then
                    error("Must provide glass proxy for energy display.")
                end
                table.insert(hudObjects,  {
                    static          = {},
                    dynamic         = {},
                    glasses         = glasses[i][1],
                    resolution      = glasses[i][2] or {2560, 1440},
                    scale           = glasses[i][3] or 3,
                    borderColor     = glasses[i][4] or colors.darkGray,
                    primaryColor    = glasses[i][5] or colors.lime,
                    accentColor     = glasses[i][6] or colors.black,
                    backColor       = colors.darkSlateGrey,
                    width           = 0,
                    height          = 24,
                    compactMode     = glasses[i][7] or false
                })
            end
        end

        for i = 1, #hudObjects do
            if hudObjects[i] then
                if hudObjects[i].width == 0 then hudObjects[i].width = screen.size(hudObjects[i].resolution, hudObjects[i].scale)[1]/2 - 91 end
                local h = hudObjects[i].height
                local w = hudObjects[i].width
                local compact = (w < 250) or hudObjects[i].compactMode
                local x = 0
                local y = screen.size(hudObjects[i].resolution, hudObjects[i].scale)[2] - h + 9
                local hProgress = math.ceil(h * 0.4)
                local energyBarLength = w-4-hProgress
                local hDivisor = 3
                if #hudObjects[i].static == 0 and #hudObjects[i].glasses ~= nil then
                    local borderColor = hudObjects[i].borderColor
                    local primaryColor = hudObjects[i].primaryColor
                    local accentColor = hudObjects[i].accentColor
                    local backColor = hudObjects[i].backColor
                    table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x, y}, w-hProgress-1, hDivisor, borderColor))
                    table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x, y+hDivisor+hProgress}, w+2, hDivisor, borderColor))
                    table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x-1, y+hDivisor}, {x-1, y+hDivisor+hProgress}, {x+2+hProgress, y+hDivisor+hProgress}, {x+2, y+hDivisor}, borderColor))
                    table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+w-1-hProgress, y}, {x+w-2-hProgress, y+hDivisor}, {x+w-2, y+hDivisor+hProgress}, {x+w+2, y+hDivisor+hProgress}, borderColor))
                    table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+1, y+hDivisor}, {x+1+hProgress, y+hDivisor+hProgress}, {x+218+hProgress, y+hDivisor+hProgress}, {x+218, y+hDivisor}, backColor))
                    hudObjects[i].dynamic.energyBar = ar.quad(hudObjects[i].glasses, {x+1, y+hDivisor}, {x+1+hProgress, y+hDivisor+hProgress}, {x+2+hProgress, y+hDivisor+hProgress}, {x+1, y+hDivisor}, primaryColor)
                    -- hudObjects[i].dynamic.currentEU = ar.text(hudObjects[i].glasses, "", {x+2, y-9}, primaryColor)
                    hudObjects[i].dynamic.percentage = ar.text(hudObjects[i].glasses, "", {x+w/2-5, y-1}, accentColor)
                    hudObjects[i].dynamic.wirelessEU = ar.text(hudObjects[i].glasses, "", {x+w/2-5 + 50, y-9}, primaryColor)
                    hudObjects[i].dynamic.state = ar.text(hudObjects[i].glasses, "", {x+w-95, y+2*hDivisor+hProgress+2}, colors.red)
                    if compact then
                        hudObjects[i].dynamic.state.setPosition(x+w/2-15, y+hDivisor+2)
                        hudObjects[i].dynamic.percentage.setPosition(x+w/2-10, y-9)
                    end
                end
                hudObjects[i].dynamic.energyBar.setVertex(3, x+3+hProgress+energyBarLength*percentage, y+hDivisor+hProgress)
                hudObjects[i].dynamic.energyBar.setVertex(4, x+3+energyBarLength*percentage, y+hDivisor)

                --Show LSC EU if wireless mode
                if energyData.wirelessMode then
                    hudObjects[i].dynamic.wirelessEU.setText(parser.metricNumber(math.abs(math.floor(data.storedEU))).." "..energyUnit)
                end

                if data.wirelessMode then
                    hudObjects[i].dynamic.percentage.setText("")
                else

                    if percentage < 0.05 then
                        hudObjects[i].dynamic.percentage.setPosition(x+w/2-20, y+5)
                        hudObjects[i].dynamic.percentage.setText(tostring(math.floor(percentage*10000000)/100000).."%")
                    else
                        hudObjects[i].dynamic.percentage.setPosition(x+w/2-5, y+5)
                        hudObjects[i].dynamic.percentage.setText(parser.percentage(percentage))
                    end
                end

                if data.state == states.OFF then
                    hudObjects[i].dynamic.state.setText("Disabled")
                else
                    if data.problems > 0 then
                        hudObjects[i].dynamic.state.setText("Maintenance")
                    else
                        hudObjects[i].dynamic.state.setText("")
                    end
                end
            end
        end
    end
end


function powerDisplay.remove(glassAddress)
    for i = 1, #hudObjects do
        local hudObject = hudObjects[i]
        if hudObject then
            local glasses = hudObject.glasses
            if glasses ~= nil then
                if glasses.address == glassAddress then
                    for j = 1, #hudObjects[i].static do
                        hudObjects[i].glasses.removeObject(hudObjects[i].static[j].getID())
                    end
                    hudObjects[i].static = {}
                    for name, value in pairs(hudObjects[i].dynamic) do
                        hudObjects[i].glasses.removeObject(hudObjects[i].dynamic[name].getID())
                    end
                    hudObjects[i].dynamic = {}
                    hudObjects[i] = nil
                end
            end
        end
    end
end


return powerDisplay