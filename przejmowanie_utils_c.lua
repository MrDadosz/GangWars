--[[
	Skrypt stworzony przez MrDadosz. Nie masz prawa używać/rozpowszechniać go bez mojej zgody.
	Skype: MrDadosz
	Discord: MrDadosz#0690
	Mail: mrdadosz@gmail.com / orange-1998@tlen.pl
]]

local spawnbotTable = {}
local bots = {}
--[[addCommandHandler("spawnbot", function()
	local x,y,z = getElementPosition(localPlayer)
	_,_,rot = getElementRotation(localPlayer)
	x = string.format("%.4f", x)
	y = string.format("%.4f", y)
	z = string.format("%.4f", z)
	rot = string.format("%.2f", rot)
	table.insert(spawnbotTable, {x,y,z,rot})
	local bot = createPed(0, x,y,z,rot)
	setElementFrozen(bot, true)
	setElementAlpha(bot, 150)
	setElementCollisionsEnabled(bot, false)
	bots[bot] = true
	outputChatBox("Dodano lokację spawnu bota na pozycjach "..x..", "..y..", "..z..", "..rot.."!")
end)

addCommandHandler("spawnbotkoniec", function()
	local text = ""
	for i, v in ipairs(spawnbotTable) do
		text = text.."\n{"..v[1]..","..v[2]..","..v[3]..","..v[4].."},"
	end
	setClipboard(text)
	outputChatBox("Zapisano listę botów w clipboardzie")
	for bot, _ in pairs(bots) do
		destroyElement(bot)
	end
	spawnbotTable = {}
	bots = {}
end)

local tempRadarArea
addCommandHandler("spawnarea", function(cmd, sizeX, sizeY, r, g, b)
	if isElement(tempRadarArea) then
		destroyElement(tempRadarArea)
	end
	if not tonumber(sizeX) or not tonumber(sizeY) then
		outputChatBox("Użyj: /spawnarea <rozmiar X> <rozmiar Y> [r] [g] [b]")
		return
	end
	local x,y,z = getElementPosition(localPlayer)
	tempRadarArea = createRadarArea(x,y, sizeX, sizeY, tonumber(r) or 255,tonumber(g) or 0,tonumber(b) or 0, 240)
	setRadarAreaFlashing(tempRadarArea, true)
	local text = '["areaPos"] = {'..x..','..y..', '..sizeX..','..sizeY..'},'
	setClipboard(text)
	outputChatBox("Zapisano pozycję area w clipboardzie. Wpisane dane: "..sizeX..", "..sizeY..", "..(tonumber(r) or 255)..", "..(tonumber(g) or 0)..", "..(tonumber(b) or 0))
end)

local spawnvehicleTable = {}
local vehicles = {}
addCommandHandler("spawnauto", function()
	local vehicle = getPedOccupiedVehicle(localPlayer) or localPlayer
	local x,y,z = getElementPosition(vehicle)
	rotx,roty,rotz = getElementRotation(vehicle)
	x = string.format("%.4f", x)
	y = string.format("%.4f", y)
	z = string.format("%.4f", z)
	rotx = string.format("%.2f", rotx)
	roty = string.format("%.2f", roty)
	rotz = string.format("%.2f", rotz)
	table.insert(spawnvehicleTable, {x,y,z,rotx,roty,rotz})
	local vehicle = createVehicle(560,x,y,z,rotx,roty,rotz)
	setElementFrozen(vehicle, true)
	setElementAlpha(vehicle, 150)
	setElementCollisionsEnabled(vehicle, false)
	vehicles[vehicle] = true
	outputChatBox("Dodano lokację spawnu pojazdu na pozycjach "..x..", "..y..", "..z..", "..rotx..", "..roty..", "..rotz.."!")
end)

addCommandHandler("spawnautokoniec", function()
	local text = ""
	for i, v in ipairs(spawnvehicleTable) do
		text = text.."\n{"..v[1]..","..v[2]..","..v[3]..","..v[4]..","..v[5]..","..v[6].."},"
	end
	setClipboard(text)
	outputChatBox("Zapisano listę pojazdów w clipboardzie")
	for vehicle, _ in pairs(vehicles) do
		destroyElement(vehicle)
	end
	spawnvehicleTable = {}
	vehicles = {}
end)]]