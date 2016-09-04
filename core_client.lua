
local gameRunning = true
local x, y = guiGetScreenSize()
local delayTimer = nil
local hunter = "None"
local startTime
local timeLeft
local timePassed
local mapDuration = 600000
local soundStreamURL = "http://www.nonstopplay.com/site/media/wmrt-asx/broadband.asx"
local soundStream
local soundStreamString = ""
local soundStreamToggled = true

for i, v in ipairs({"ammo", "area_name", "armour", "breath", "clock", "health", "money", "vehicle_name", "weapon", "wanted"}) do
    showPlayerHudComponent(v, false)
end

function drawStatistics()
    if gameRunning then
        if hunter == nil then
            hunter = "None"
        end
        dxDrawText("Hunter: "..hunter:gsub("#%x%x%x%x%x%x", ""), 0+1.5, 0+1.5, x+1.5, y+1.5, tocolor(0, 0, 0, 205), 2*(y/1050), "default-bold", "center", "top", false, false, false, true, true)
        dxDrawText("#0fc0fcHunter: #ffffff"..hunter, 0, 0, x, y, tocolor(255, 255, 255, 255), 2*(y/1050), "default-bold", "center", "top", false, false, false, true, true)
        if isTimer(killDelay) then
            local killDetails = {getTimerDetails(killDelay)}
            dxDrawText("#ff0000YOU HAVE #ffffff"..string.sub(((killDetails[1])/1000), 0, 3).." #ff0000SECONDS TO LEAVE THIS AREA!", 0, 0+34*(y/1050), x, y, tocolor(255, 255, 0, 205), 3*(y/1050), "default-bold", "center", "top", false, false, false, true, true)
        end
        if startTime then
            timePassed = getTickCount()-startTime
            timeLeft = (mapDuration-timePassed)
            if timeLeft >= 0 then
                dxDrawText("Time Left: "..convertTime(timeLeft), 0+1.5, 0+1.5, x+1.5, y+1.5, tocolor(0, 0, 0, 205), 3*(y/1050), "default-bold", "right", "top", false, false, false, true, true)
                if timeLeft <= 10000 then
                    dxDrawText("#0fc0fcTime Left: #ff0000"..convertTime(timeLeft), 0, 0, x, y, tocolor(255, 255, 255, 255), 3*(y/1050), "default-bold", "right", "top", false, false, false, true, true)
                else
                    dxDrawText("#0fc0fcTime Left: #ffffff"..convertTime(timeLeft), 0, 0, x, y, tocolor(255, 255, 255, 255), 3*(y/1050), "default-bold", "right", "top", false, false, false, true, true)
                end
            end
        end
		if isElement(soundStream) and soundStreamToggled == true then
			dxDrawText("#0fc0fcNow Playing: #ffffff"..soundStreamURL, 0, 0, x, y, tocolor(255, 255, 255, 255), 1.3*(y/1050), "default-bold", "left", "bottom", false, false, false, true, true)
		end
    end
end
addEventHandler("onClientRender", root, drawStatistics)

function convertTime(ms)
    if not ms then
        return ''
    end
    local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
    if #centiseconds == 1 then
        centiseconds = '0' .. centiseconds
    end
    local s = math.floor(ms / 1000)
    local seconds = tostring(math.fmod(s, 60))
    if #seconds == 1 then
        seconds = '0' .. seconds
    end
    local minutes = tostring(math.floor(s / 60))
    return minutes .. ':' .. seconds .. ':' .. centiseconds
end

function cityCheck()
    local px, py, pz = getElementPosition(localPlayer)
    local city = getZoneName(px, py, pz, true)
    if getElementHealth(localPlayer) == 0 then
		return
	end
    if not isPedInVehicle(localPlayer) then
		return
	end
    if city:lower() ~= "los santos" then
        if not isTimer(killDelay) then
            killDelay = setTimer(function() setElementHealth(localPlayer, 0) triggerServerEvent("destroyServerSidedElements", localPlayer) end, 10000, 1)
        end
    else
        if isTimer(killDelay) then
            killTimer(killDelay)
            killDelay = nil
        end
    end
end

function drawCountdown()
    local cdTickEnd = getTickCount() - cdTick
    if cdTickEnd >= 0 and cdTickEnd <= 1000 then
        dxDrawText("3", 0, 0, x, y, tocolor(255, 255, 255, 255), 6, "default-bold", "center", "center")
        if cdTickEnd >= 0 and cdTickEnd <= 25 then
            playSoundFrontEnd(43)
        end
    elseif cdTickEnd >= 1000 and cdTickEnd <= 2000 then
        dxDrawText("2", 0, 0, x, y, tocolor(255, 255, 255, 255), 6, "default-bold", "center", "center")
        if cdTickEnd >= 1000 and cdTickEnd <= 1025 then
            playSoundFrontEnd(43)
        end
    elseif cdTickEnd >= 2000 and cdTickEnd <= 3000 then
        dxDrawText("1", 0, 0, x, y, tocolor(255, 255, 255, 255), 6, "default-bold", "center", "center")
        if cdTickEnd >= 2000 and cdTickEnd <= 2025 then
            playSoundFrontEnd(43)
        end
    elseif cdTickEnd >= 3000 and cdTickEnd <= 4000 then
        dxDrawText("GO!", 0, 0, x, y, tocolor(255, 255, 255, 255), 6, "default-bold", "center", "center")
        if cdTickEnd >= 3000 and cdTickEnd <= 3025 then
            playSoundFrontEnd(45)
        end
    elseif cdTickEnd >= 4000 then
        cdTickEnd = nil
        cdTick = nil
        removeEventHandler("onClientRender", root, drawCountdown)
    end
end

addEvent("startCountdown", true)
addEventHandler("startCountdown", root,
    function(s)
        cdTick = getTickCount()
        addEventHandler("onClientRender", root, drawCountdown)
        hunter = getPlayerName(s)
        setTimer(cityCheck, 2000, 0)
    end
)

addEvent("startClock", true)
addEventHandler("startClock", root,
    function(timePassedTick)
        startTime = getTickCount()-timePassedTick
		soundStream = playSound(soundStreamURL)
		soundStreamURL = soundStreamURL:gsub("http://", "")
		soundStreamURL = soundStreamURL:gsub("https://", "")
		for i=1, #soundStreamURL do
			if string.sub(soundStreamURL, i, i) == "/" then
				soundStreamURL = soundStreamURL:sub(1, i-1)
				break
			end
		end
    end
)

addEvent("hideMarkerForLocal", true)
addEventHandler("hideMarkerForLocal", root,
    function(marker)
		if source == localPlayer then
			setMarkerColor(marker, 0, 0, 0, 0)
		end
    end
)

addEvent("onClientVehicleCollision", true)
addEventHandler("onClientVehicleCollision", root,
	function(theHitElement)
		if isElement(theHitElement) and getElementType(theHitElement) == "vehicle" then
			if getVehicleOccupant(theHitElement) and source == getPedOccupiedVehicle(localPlayer) then
				if getElementDimension(source) == getElementDimension(theHitElement) then
					if getPlayerName(getVehicleOccupant(theHitElement)) == hunter then
						triggerServerEvent("setNewHunter", root, getPlayerName(getVehicleOccupant(source)))
					elseif getPlayerName(getVehicleOccupant(source)) == hunter then
						triggerServerEvent("setNewHunter", root, getPlayerName(getVehicleOccupant(theHitElement)))
					end
				end
			end
		end
	end
)

function setNewHunter(theHitElement)
    hunter = theHitElement
end
addEvent("setClientNewHunter", true)
addEventHandler("setClientNewHunter", root, setNewHunter)

function playWhistle()
    local whistle = playSound3D("files/sounds/whistle.mp3", 0, 0, 0, false)
	attachElements(whistle, source)
	setSoundMaxDistance(whistle, 500)
	setSoundVolume(whistle, 1)
end
addEvent("playWhistle", true)
addEventHandler("playWhistle", root, playWhistle)

addCommandHandler("music",
	function()
		if isElement(soundStream) then
			if soundStreamToggled == true then
				setSoundVolume(soundStream, 0)
				soundStreamToggled = false
			else
				setSoundVolume(soundStream, 1)
				soundStreamToggled = true
			end
		end
	end
)