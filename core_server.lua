
local markers = {}
local delayTimer = nil
local vehicles = {}
local hunter = "None"
local playersPlaying = {}
local startTime = 0
local whistles = {}
local whistlesTime = {}
local timeLeft

_setMarkerColor = setMarkerColor
function setMarkerColor(p, r, g, b, a, s)
    _setMarkerColor(p, r, g, b, a)
    setTimer(setVehicleColor, 80, 1, getPedOccupiedVehicle(s), r, g, b, r, g, b, r, g, b, r, g, b)
	--triggerClientEvent(s, "hideMarkerForLocal", s, p)
end

function initArena()
	if #getElementsByType"player" == 0 then
		return
	end
    hunter = getRandomPlayer()
    startTime = 0
    setWaterLevel(-99999999)
    vehicles["hunter"] = createVehicle(411, 1383.7889404297, -2542.5693359375, 16.748104095459)
    setVehicleDamageProof(vehicles["hunter"], true)
    setElementFrozen(vehicles["hunter"], true)
    setElementRotation(vehicles["hunter"], 0, 0, -90)
    spawnPlayer(hunter, 1383.7889404297, -2542.5693359375, 16.748104095459)
    setCameraTarget(hunter, hunter)
    fadeCamera(hunter, true)
    setTimer(warpPedIntoVehicle, 50, 1, hunter, vehicles["hunter"])
    local players = {}
    local fY = 0
    for i, v in ipairs(getElementsByType"player") do
        if v ~= hunter then
            fY = fY + 1
            players[fY] = v
            playersPlaying[fY] = v
        end
    end
	playersPlaying[fY+1] = hunter
    local c = 0
    local x = 0
    for i=1, #players do
        vehicles[i] = createVehicle(411, 1478.1820068359+7*x, -2558.0366210938+3.5*c, 13.065192222595)
        setVehicleDamageProof(vehicles[i], true)
        setElementFrozen(vehicles[i], true)
        setElementRotation(vehicles[i], 0, 0, -90)
        spawnPlayer(players[i], 1478.1820068359+7*x, -2558.0366210938+3.5*c, 13.065192222595)
        fadeCamera(players[i], true)
        setCameraTarget(players[i], players[i])
        setTimer(warpPedIntoVehicle, 50, 1, players[i], vehicles[i])
        c = c + 1
        if c == 8 then
            c = 0
            x = x + 1
        end
    end
    setTimer(
        function()
            for i, v in ipairs(getElementsByType"player") do
                if v ~= hunter then
                    initAttachments(v)
                else
                    initAttachments(v, true)
                end
            end
        end, 500, 1
    )
    addEventHandler("onVehicleStartExit", root, function() cancelEvent() end)
    setTimer(
        function()
            triggerClientEvent("startCountdown", root, hunter)
            startdelay = setTimer(function() end, 5000, 1)
            setTimer(
                function()
                    for i, v in ipairs(getElementsByType"player") do
                        setElementFrozen(getPedOccupiedVehicle(v), false)
                    end
                    startTime = getTickCount()
                    triggerClientEvent("startClock", root, 0)
                    setTimer(
                        function()
                            for i, v in ipairs(getElementsByType"player") do
                                local veh = getPedOccupiedVehicle(v)
                                if veh then
                                    local attElems = getAttachedElements(veh)
                                    destroyElement(veh)
                                    for s, k in ipairs(attElems) do
                                        destroyElement(k)
                                    end
                                end
                            end
                            markers = {}
                            if isTimer(delayTimer) then
                                killTimer(delayTimer)
                            end
                            delayTimer = nil
                            vehicles = {}
                            hunter = "None"
                            playersPlaying = {}
                            setTimer(initArena, 50, 1)
                        end, 600000, 1
                    )
                end, 3000, 1
            )
        end, 2000, 1
    )
    setTime(0, 0)
    setMinuteDuration(99999999)
    if #playersPlaying == 0 then
        setTimer(restartRound, 5000, 1)
    end
end
addEventHandler("onResourceStart", resourceRoot, initArena)

function restartRound()
	for i, v in ipairs(getElementsByType"player") do
        local veh = getPedOccupiedVehicle(v)
        if veh then
            local attElems = getAttachedElements(veh)
            destroyElement(veh)
			for s, k in ipairs(attElems) do
                destroyElement(k)
            end
        end
    end
	markers = {}
	if isTimer(delayTimer) then
		killTimer(delayTimer)
	end
	delayTimer = nil
	vehicles = {}
	hunter = "None"
	playersPlaying = {}
	setTimer(initArena, 50, 1)
end

function initAttachments(player, hunter)
    local veh = getPedOccupiedVehicle(player)
    if isElement(veh) and getElementType(veh) == "vehicle" then
        if hunter then
            markers[player] = createMarker(0, 0, 0, "corona", 4, 255, 0, 0, 0)
            setMarkerColor(markers[player], 255, 0, 0, 0, player)
        else
            markers[player] = createMarker(0, 0, 0, "corona", 4, 0, 255, 0, 0)
            setMarkerColor(markers[player], 0, 255, 0, 0, player)
        end
        attachElements(markers[player], veh)
    end
end

addEventHandler("onPlayerWasted", root,
    function()
        for i, v in ipairs(getElementsByType"vehicle") do
            if not getVehicleOccupant(v) then
                local attElems = getAttachedElements(v)
                destroyElement(v)
                for s, k in ipairs(attElems) do
                    destroyElement(k)
                end
            end
        end
        if source ~= hunter then
            spawnPlayer(source, 0, 0, 4)
            setElementFrozen(source, true)
            setCameraTarget(source, hunter)
            setTimer(checkRunners, 2000, 1)
        end
        if source == hunter then
            vehicles["hunter"] = nil
            vehicles["hunter"] = createVehicle(411, 1383.7889404297, -2542.5693359375, 16.748104095459)
            setVehicleDamageProof(vehicles["hunter"], true)
            setElementRotation(vehicles["hunter"], 0, 0, -90)
            spawnPlayer(hunter, 1383.7889404297, -2542.5693359375, 16.748104095459)
            setCameraTarget(hunter, hunter)
            fadeCamera(hunter, true)
            setTimer(warpPedIntoVehicle, 50, 1, hunter, vehicles["hunter"])
            setTimer(initAttachments, 100, 1, hunter, true)
        end
    end
)

addEventHandler("onPlayerJoin", root,
    function()
        spawnPlayer(source, 0, 0, 4)
        setElementFrozen(source, true)
        fadeCamera(source, true)
        setCameraTarget(source, hunter)
		if #playersPlaying == 1 or #playersPlaying == 0 then
			setTimer(restartRound, 5000, 1)
		end
		triggerClientEvent(source, "setClientNewHunter", source, getPlayerName(hunter))
		triggerClientEvent(source, "startClock", source, getTickCount()-startTime)
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        local veh = getPedOccupiedVehicle(source)
        if veh then
            local attElems = getAttachedElements(veh)
            destroyElement(veh)
            for i, v in ipairs(attElems) do
                destroyElement(v)
            end
        end
        if source == hunter then
            local availablePlayers = {}
            local fY = 0
            for i, v in ipairs(getElementsByType"player") do
                if v ~= source then
                    if isPedInVehicle(v) and getElementHealth(v) ~= 0 then
                        fY = fY + 1
                        availablePlayers[fY] = v
                    end
                end
            end
            hunter = availablePlayers[math.random(1, #availablePlayers) or 1]
            local veh = getPedOccupiedVehicle(hunter)
            if veh then
                local attElems = getAttachedElements(veh)
                for i, v in ipairs(attElems) do
                    destroyElement(v)
                end
            end
            vehicles["hunter"] = nil
            vehicles["hunter"] = getPedOccupiedVehicle(hunter)
            setTimer(initAttachments, 100, 1, hunter, true)
            for i, v in ipairs(getElementsByType"player") do
                if not isPedInVehicle(v) then
                    setCameraTarget(v, hunter)
                end
            end
        end
        setTimer(checkRunners, 2000, 1)
    end
)

function checkRunners()
    local availablePlayers = {}
    local fY = 0
    for i, v in ipairs(getElementsByType"player") do
        if v ~= hunter then
            if isPedInVehicle(v) and getElementHealth(v) ~= 0 then
                fY = fY + 1
                availablePlayers[fY] = v
            end
        end
    end
    if #availablePlayers == 0 then
        for i, v in ipairs(getElementsByType"player") do
            local veh = getPedOccupiedVehicle(v)
            if veh then
                local attElems = getAttachedElements(veh)
                destroyElement(veh)
                for s, k in ipairs(attElems) do
                    destroyElement(k)
                end
            end
        end
        markers = {}
        if isTimer(delayTimer) then
            killTimer(delayTimer)
        end
        delayTimer = nil
        vehicles = {}
        hunter = "None"
        playersPlaying = {}
        setTimer(initArena, 50, 1)
    end
end

function setNewHunter(xhunter)
	if isTimer(delayTimer) then
		return
	end
	delayTimer = setTimer(function() end, 1000, 1)
    triggerClientEvent("setClientNewHunter", root, xhunter)
    for i, v in ipairs(getElementsByType"player") do
        if not isPedInVehicle(v) then
            setCameraTarget(v, getPlayerFromName(xhunter))
        end
    end
    if hunter ~= getPlayerFromName(xhunter) then
        setMarkerColor(markers[getPlayerFromName(xhunter)], 255, 0, 0, 0, getPlayerFromName(xhunter))
        setMarkerColor(markers[hunter], 0, 255, 0, 0, hunter)
    end
    hunter = getPlayerFromName(xhunter)
end
addEvent("setNewHunter", true)
addEventHandler("setNewHunter", root, setNewHunter)

addCommandHandler("whistle",
	function(player, command)
		if isPedInVehicle(player) then
			if player ~= hunter then
				if whistles[player] == nil then
					local blip = createBlipAttachedTo(player, 0, 2, 0, 255, 0)
					setTimer(destroyElement, 5000, 1, blip)
					triggerClientEvent("playWhistle", player)
					outputChatBox("[WHISTLE] "..getPlayerName(player).." #ffffffhas whistled!", root, 255, 255, 255, true)
					
					whistles[player] = true
					whistlesTime[player] = setTimer(function() whistles[player] = nil end, 15000, 1)
				else
					local remaining, executesRemaining, totalExecutes = getTimerDetails(whistlesTime[player])
					outputChatBox("[WHISTLE] You need to wait "..math.floor(remaining/1000).." more seconds!", player, 255, 255, 255, true)
				end
			end
		end
	end
)