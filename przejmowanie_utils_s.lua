--[[
	Skrypt stworzony przez MrDadosz. Nie masz prawa używać/rozpowszechniać go bez mojej zgody.
	Skype: MrDadosz
	Discord: MrDadosz#0690
	Mail: mrdadosz@gmail.com / orange-1998@tlen.pl
]]

function showGangLog(message, isError, isDebug)
	if isError then
		outputDebugString("GANGWARS BŁĄD: "..message)
	elseif isDebug and settings["debug"] then
		outputDebugString("Gangwars debug: "..message)
	else
		outputDebugString("Gangwars: "..message)
	end
	-- zalecam tu dodać zapis do jakiegoś pliku
end

function getOnlinePlayersInOrganisation(color)
	if not color then
		return {}
	end
	local query = call(getResourceFromName(settings["DBResource"]), settings["getOneRow"], "SELECT id FROM lss_co WHERE color = ?", color)
	if not query or not query.id then
		return {}
	end
	local gangID = tonumber(query.id)
	local playersTable = {}
	for _, player in ipairs(getElementsByType("player")) do
		local character = getElementData(player, "character")
		if character and character.co_id then
			local currentGangID = tonumber(character.co_id)
			if gangID == currentGangID then
				table.insert(playersTable, player)
			end
		end
	end
	return playersTable
end

function canAttackGang(color)
	if not color then
		return false, "(( Gang o takim kolorze nie istnieje! ))"
	end
	local playersInGang = getOnlinePlayersInOrganisation(color)
	local minimumPlayers = settings["minGangPlayersToAttack"]
	if #playersInGang < minimumPlayers then
		return false, "(( Na serwerze nie ma "..minimumPlayers.." członków tego gangu! ))"
	end
	return true
end

function checkAreaOwner(index)
	if not index then
		return
	end
	local query = call(getResourceFromName(settings["DBResource"]), settings["getOneRow"], "SELECT gang_owning_color FROM dadosz_gangwars WHERE area_index = ?", index)
	if not query or not query.gang_owning_color then
		return
	end
	return query.gang_owning_color
end

function isPlayerOrganisationLeader(player)
	if not isElement(player) then
		return false
	end
	local character = getElementData(player, "character")
	if character and character.co_id and tonumber(character.co_rank) == 5 then
		return true
	end
	return false
end

function getPlayerCharacterID(player)
	if not isElement(player) then
		return
	end
	local character = getElementData(player, "character")
	if character and character.id then
		return tonumber(character.id)
	end
end

function getPlayerOrganisation(player)
	if not isElement(player) then
		return
	end
	local character = getElementData(player, "character")
	if character and character.co_id then
		local characterID = tonumber(character.co_id)
		local color
		local query = call(getResourceFromName(settings["DBResource"]), settings["getOneRow"], "SELECT color FROM lss_co WHERE id = ?", characterID)
		if query and query.color then
			color = query.color
		end
		return characterID, color
	end
end

local function onClientDamagedVehicle(vehicle, loss)
	if not isElement(vehicle) or not loss then
		return
	end
	local gangWarsData = getElementData(vehicle, "gangWarsData")
	if not gangWarsData then
		return
	end
	local character = getElementData(client, "character")
	if not character or not character.co_id or tonumber(character.co_id) ~= tonumber(gangWarsData["gangID"]) then
		return
	end
	local hp = getElementHealth(vehicle)
	hp = hp - loss
	if hp <= 260 then
		destroyElement(vehicle)
		triggerEvent("addGangPoints", resourceRoot, settings["pointsForVehicle"])
	else
		setElementHealth(vehicle, hp)
	end
end
addEvent("onClientDamagedVehicle", true)
addEventHandler("onClientDamagedVehicle", resourceRoot, onClientDamagedVehicle)

local function onClientDamagedPed(ped, bodypart, loss)
	if not isElement(ped) or not bodypart or not loss then
		return
	end
	local gangWarsData = getElementData(ped, "gangWarsData")
	if not gangWarsData then
		return
	end
	local character = getElementData(client, "character")
	if not character or not character.co_id or tonumber(character.co_id) ~= tonumber(gangWarsData["gangID"]) then
		return
	end
	
	local hp = getElementHealth(ped)
	if bodypart == 9 then
		if settings["botHeadshots"] then
			hp = 1
		else
			loss = loss * 5
		end
	end
	hp = hp - loss
	if hp <= 3 then
		killPed(ped)
	else
		setElementHealth(ped, hp)
	end
end
addEvent("onClientDamagedPed", true)
addEventHandler("onClientDamagedPed", resourceRoot, onClientDamagedPed)

local function giveGangItemsByTime(gangID, gangColor, areaIndex, areaType, areaSize, containerID)
	local multipler = 1
	if gangSizes[areaSize] then
		multipler = gangSizes[areaSize]
	end
	for i = 1,5 do
		local iTable = {}
		for tempItemID, tempItemCount in pairs(possibleItems[areaType]) do
			table.insert(iTable, {tempItemID, tempItemCount})
		end
		local randomItem = iTable[math.random(1, #iTable)]
		local itemID = randomItem[1]
		local originalItemCount = randomItem[2]
		local itemCount = math.ceil(originalItemCount*multipler)
		exports["lss-pojemniki"]:insertItemToContainer(containerID, itemID, itemCount)
		showGangLog("Dodano przedmiot o ID "..itemID.." i ilości "..itemCount.." do sejfu o ID "..containerID.." za strefę o indeksie "..areaIndex, false, false)
	end
end

local function giveEveryGangItemsByTime()
	for index, _ in pairs(gangData) do
		local gangColor = checkAreaOwner(index)
		if gangColor and gangColor ~= "nobody" then
			local query = call(getResourceFromName(settings["DBResource"]), settings["getOneRow"], "SELECT id, container FROM lss_co WHERE color = ?", gangColor)
			if query and query.id and query.container then
				giveGangItemsByTime(query.id, gangColor, index, gangData[index]["type"], gangData[index]["size"], query.container)
			else
				showGangLog("Nie można znależć gangu/sejfu gangu w bazie o kolorze "..gangColor.." - nie dostanie przedmiotów", true, false)
			end
		elseif not gangColor then
			showGangLog("Nie można znależć terenu w bazie o indeksie "..index.." - nie dostanie przedmiotów", true, false)
		end
	end
end
setTimer(giveEveryGangItemsByTime, settings["giveItemsTime"]*60*60*1000, 0)