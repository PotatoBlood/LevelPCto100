name = "VulcanToVermilion"
author = "PotatoBlood"

description = [[This allows you to move from anywhere on Vulcan Island to Vermilion City]]


function onStart()
end

function onPathAction()
				if isOnMap ("Mt. Summer Summit 2") then
					moveToCell(28,39)
				elseif isOnMap ("Mt. Summer 4F 2") then
					moveToCell(22,20)
				elseif isOnMap ("Mt. Summer 3F 2") then
					moveToMap("Mt. Summer 2F 2")
				elseif isOnMap ("Mt. Summer 2F 2") then
					moveToMap("Mt. Summer 1F 2")
				elseif isOnMap ("Mt. Summer 1F 2") then
					moveToMap("Mt. Summer Exterior 2")
				elseif isOnMap ("Mt. Summer Exterior 2") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Mt. Summer Exterior") then
					moveToMap("Vulcan Forest")
				elseif getMapName() == "Kalijodo Cave B2F" then
				   moveToMap("Kalijodo Cave B1F")
				elseif getMapName() == "Kalijodo Cave B1F" then
					moveToMap("Kalijodo Cave Entrance")
				elseif getMapName() == "Kalijodo Cave Entrance" then
					moveToMap("Kalijodo Lake")
				elseif getMapName() == "Kalijodo Lake" then
					moveToMap("Kalijodo Path")
				elseif getMapName() == "Kalijodo Path" then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcan Path")
				elseif isOnMap ("Vulcan Path") then
					moveToMap("Vulcan Island shore")
				elseif isOnMap ("Vulcan Island shore") then
					if isNpcOnCell(11,47) then
						pushDialogAnswer(1)
						talkToNpcOnCell(11,47)
					else
						pushDialogAnswer(1)
						talkToNpc("Sailor Dionisis")
					end
				elseif isOnMap ("Vermilion City") then
					log("Destination Reached - Vermilion City")
				end
end

function onBattleAction()
	return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
end

function onDialogMessage(message)
end

function onStop()
end

function isOnMap (mapName)
	if getMapName () == mapName then
		return true
	else
		return false
	end
end