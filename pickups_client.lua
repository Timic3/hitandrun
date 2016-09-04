
local nitroFull = false
local x, y = guiGetScreenSize()
local width, height = 310, 35
local object = {}
local pickupStartPick = nil

pickups = {}
pickups.nos = {}
pickups.nos[1] = {1965.4697265625, -2362.8515625, 13.273694038391, 0, 0, 359.42855834961}
pickups.nos[2] = {1911.1865234375, -1776.4541015625, 13.109889030457, 0, 0, 179.82415771484}
pickups.nos[3] = {2062.576171875, -1784.810546875, 13.277022361755, 0, 0, 182.19779968262}
pickups.nos[4] = {2480.763671875, -1706.0263671875, 13.259983062744, 0, 0, 357.05493164063}
pickups.nos[5] = {2247.3671875, -1619.689453125, 15.680458068848, 0, 0, 302.10989379883}
pickups.nos[6] = {2336.7880859375, -1243.1396484375, 22.227069854736, 0, 0, 183.4285736084}
pickups.nos[7] = {2428.361328125, -1154.212890625, 31.763103485107, 0, 0, 272.13186645508}
pickups.nos[8] = {1189.673828125, -1616.8212890625, 21.914571762085, 0, 0, 0.65936279296875}
pickups.nos[9] = {1550.296875, -981.9072265625, 37.248359680176, 0, 0, 257.0989074707}
pickups.nos[10] = {1658.904296875, -1679.4248046875, 21.158868789673, 0, 0, 91.472534179688}
pickups.nos[11] = {2805.9052734375, -1440.3115234375, 39.770969390869, 0, 0, 177.62634277344}
pickups.nos[12] = {1938.2001953125, -1832.1103515625, 6.8052062988281, 0, 0, 256.65933227539}
pickups.nos[13] = {2200.3037109375, -2454.669921875, 15.852070808411, 0, 0, 27.120880126953}
pickups.nos[14] = {864.462890625, -1167.716796875, 16.707111358643, 0, 0, 88.835174560547}
pickups.nos[15] = {2868.361328125, -1588.8486328125, 22.18204498291, 0, 0, 249.62637329102}
pickups.nos[16] = {953.330078125, -911.115234375, 45.492691040039, 0, 0, 274.41760253906}
pickups.nos[17] = {2676.009765625, -1541.455078125, 24.992799758911, 0, 0, 183.25274658203}
pickups.nos[18] = {2454.4775390625, -1461.0625, 23.727079391479, 0, 0, 271.16485595703}
pickups.nos[19] = {1971.2333984375, -1199.9873046875, 16.313014984131, 0, 0, 92.087921142578}
pickups.nos[20] = {1295.1953125, -984.9189453125, 32.422386169434, 0, 0, 89.274719238281}
pickups.nos[21] = {1017.673828125, -917.4111328125, 42.070831298828, 0, 0, 187.91209411621}
pickups.nos[22] = {1086.828125, -1187.52734375, 18.040243148804, 0, 0, 91.296722412109}
pickups.nos[23] = {1109.9189453125, -1187.203125, 18.07656288147, 0, 0, 90.769226074219}
pickups.nos[24] = {1302.9287109375, -966.314453125, 37.855045318604, 0, 0, 2.5934143066406}
pickups.nos[25] = {735.287109375, -1117.8115234375, 23.289796829224, 0, 0, 332}
pickups.nos[26] = {1486.5302734375, -1723.6298828125, 6.6388540267944, 0, 0, 252.08790588379}
pickups.nos[27] = {794.939453125, -1337.216796875, -0.78073352575302, 0, 0, 48.747253417969}
pickups.nos[28] = {736.2021484375, -1138.58203125, 17.521194458008, 0, 0, 319.25274658203}
pickups.nos[29] = {1954.3916015625, -1545.541015625, 13.375513076782, 0, 0, 185.0989074707}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		local colshape
		object = {}
		pickupStartTick = getTickCount()
		
		for i, v in ipairs(pickups.nos) do
			local tempObj = createObject(2221, v[1], v[2], v[3])
			object[#object+1] = tempObj
			setElementCollisionsEnabled(tempObj, false)
			colshape = createColSphere(v[1], v[2], v[3], 3.5)
			setElementData(colshape, "type", "nos")
		end
		
		engineImportTXD(engineLoadTXD('files/models/nitro.txd'), 2221)
		engineReplaceModel(engineLoadDFF('files/models/nitro.dff', 2221), 2221)
		engineSetModelLODDistance(2221, 60)
	end
)

addEventHandler("onClientElementColShapeHit", root,
	function(shape, dim)
		if (shape and isElement(shape)) then
			if getElementData(shape, "type") then
				if isElement(source) and getElementType(source) == "vehicle" then
					if getElementData(shape, "type") == "nos" then
						addVehicleUpgrade(source, 1010)
						if getVehicleOccupant(source) == localPlayer then
							playSoundFrontEnd(46)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientRender", root,
	function()
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if vehicle then
			local driver = getVehicleOccupant(vehicle, 0)
			if driver then
				local nitro = getVehicleUpgradeOnSlot(vehicle, 8)
				if nitro then
					local nitroLevel = getVehicleNitroLevel(vehicle)
					if nitroLevel then
						dxDrawRectangle(x-width-10, dxGetFontHeight(3*(y/1050), "default-bold"), width, height, tocolor(0, 0, 0, 140))
						dxDrawRectangle(x-width-10+2, dxGetFontHeight(3*(y/1050), "default-bold")+2, (width-2*2)*nitroLevel, height-2*2, tocolor(15, 192, 252, 150))
						if math.floor((nitroLevel*100)) == 0 then
							removeVehicleUpgrade(vehicle, 1010)
						end
					end
				end
			end
		end
		for i, v in ipairs(object) do
			local angle = math.fmod((getTickCount() - pickupStartTick) * 360 / 2000, 360)
			setElementRotation(v, angle, angle, angle)
		end
	end
)
