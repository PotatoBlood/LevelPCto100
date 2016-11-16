-------------------------------------------------
-------------------- Config ---------------------
-------------------------------------------------
-- List of Pokemons that you would like to catch while running this script 
-------------------------------------------------
-- DONT REMOVE Torchic, Darumaka, Shroomish, Sableye, Wynaut !!!!!!!!
catchList = {"Mudkip","Torchic","Darumaka","Binacle","Shellos","Shroomish","Treecko","Sableye","Wynaut","Woobat","Feebas"}
--------------------------------------------------------------
-- Max level - set to 100 to stop at 100, 101 to keep going
maxPokeLevel = 101
--------------------------------------------------------------
-- Please make sure that you have CUT AND SURF and that your
-- Pokemon are MINIMUM LVL 45, you can change this if needed
--------------------------------------------------------------
-- magma or aqua  -- AQUA NOT IMPLEMENTED YET !!!!!!!!!!!!
eventTeam = magma -- AQUA NOT IMPLEMENTED YET !!!!!!!!!!!!
--------------------------------------------------------------
-- Settings for after the quest
catchShroomish = true --put true to catch shroomish
catchTorchic = true --put true to catch torchic
catchSableye = true --put true to catch sableye
catchDarumaka = true --put true to catch Darumaka
resetFarm = true --false will catch 1 each and farm Darumaku infinitly
buyBallAmount = 200
--------------------------------------------------------------
-- Only touch the code below if you know what you are doing --
--------------------------------------------------------------
useSync = false --not implemented yet
useFalseSwipe = false --not implemented yet
-- !!!!!!not implemented yet dont set to false!!!!!!
ignoreWynaut = true --put false to catch Wynaut -- !!!!!!not implemented yet dont set to false!!!!!!
-- !!!!!!not implemented yet dont set to false!!!!!!
local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"

Import_Essentials = require "Maps_Pathfind"

questPart = 0 --19 if you already did the quest
questCompleted = false

name = "PRO Summer Event Quester + Rare Pokemon Farmer"
author = "PotatoBlood"
description = "Completes full Magma Quest Line, get clothes and hat reward and will farm rare pokemon. Catch shinies, pokemon not caught yet and from catchList."

isDebug = true

function onPause()
  log("***********************************PAUSED - SESSION STATS***********************************")
  endtime = os.time()
  log(string.format("Bot running time: %.2f", os.difftime(endtime,startime)/60 ).. " minutes") -- /3600 ).. " hours")
  log("Shinies Caught: " .. shinyCounter .. " - Pokemon Caught: " .. catchCounter .. " - Pokemons encountered: " .. wildCounter)
  log("Shroomish Caught: " .. shroomishCounter)
  log("Torchic Caught: " .. torchicCounter)
  log("Sableye Caught: " .. sableyeCounter)
  log("Darumaka Caught: " .. darumakaCounter)
  log("You have visited the PokeCenter ".. healCounter .." times.")
	if isDebug then
		log("Catch: Shroomish= " .. tostring(catchShroomish) .. " - Torchic= " .. tostring(catchTorchic) .. " - Sableye= " .. tostring(catchSableye) .. " - Darumaka= " .. tostring(catchDarumaka) .. " - Reset= " .. tostring(resetFarm))
		log("Ignore: Shroomish= " .. tostring(ignoreShroomish) .. " - Torchic= " .. tostring(ignoreTorchic) .. " - Sableye= " .. tostring(ignoreSableye) .. " - Darumaka= " .. tostring(ignoreDarumaka))
		log("Questpart: " .. questPart .. " - Quest Completed: " .. tostring(questCompleted) .. " - Current Map: " .. getMapName())
	end
  log("*********************************************************************************************")
end

function onResume()
  log("SESSION RESUMED")
end

function leftovers()
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = game.getFirstUsablePokemon()
	local PokemonWithLeftovers = game.getPokemonIdWithItem(ItemName)

	if getTeamSize() > 0 then
		if PokemonWithLeftovers > 0 then
			if PokemonNeedLeftovers == PokemonWithLeftovers  then
				return false
			else
				takeItemFromPokemon(PokemonWithLeftovers)
				return true
			end
		else

			if hasItem(ItemName) and PokemonNeedLeftovers ~= 0 then
				giveItemToPokemon(ItemName,PokemonNeedLeftovers)
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function advanceSorting()
	local pokemonsUsable = game.getTotalUsablePokemonCount()
	for pokemonId=1, pokemonsUsable, 1 do
		if not isPokemonUsable(pokemonId) then --Move it at bottom of the Team
			for pokemonId_ = pokemonsUsable + 1, getTeamSize(), 1 do
				if isPokemonUsable(pokemonId_) then
					swapPokemon(pokemonId, pokemonId_)
					return true
				end
			end
			
		end
	end
	if not isTeamRangeSortedByLevelAscending(1, pokemonsUsable) then --Sort the team without not usable pokemons
		return sortTeamRangeByLevelAscending(1, pokemonsUsable)
	end
	return false
end

function checkRareFarm()
	if catchShroomish then
		ignoreShroomish = false
	else
		ignoreShroomish = true
	end
	if catchTorchic then
		ignoreTorchic = false
	else
		ignoreTorchic = true
	end
	if catchSableye then
		ignoreSableye = false
	else
		ignoreSableye = true
	end
	if catchDarumaka then
		ignoreDarumaka = false
	else
		ignoreDarumaka = true
	end
end

function onStart ()
	checkRareFarm()
	startime = os.time()
	healCounter = 0
	shinyCounter = 0
	catchCounter = 0
	wildCounter = 0
	shroomishCounter = 0
	torchicCounter = 0
	sableyeCounter = 0
	darumakaCounter = 0
	log("Start botting.")
end

function onBattleMessage(message)
	if sys.stringContains(message, "You can not run away!") then
		canRun = false
	elseif stringContains(message, "caught") and stringContains(message, "Torchic") and questCompleted then
		torchicCounter = torchicCounter + 1
		--checkRareFarm()
			if catchTorchic then
				if catchSableye then
					ignoreTorchic = true
					questPart = 19
				elseif catchDarumaka then
					ignoreTorchic = true
					questPart = 19
				elseif catchShroomish then
					checkRareFarm()
					ignoreTorchic = true
					questPart = 19
				else
				questPart = 19
				end	
			end
	elseif stringContains(message, "caught") and stringContains(message, "Shroomish") and questCompleted then
		shroomishCounter = shroomishCounter + 1
			if catchShroomish then
				if catchTorchic or catchSableye or catchDarumaka then
					ignoreShroomish = true
					questPart = 19
				else
				questPart = 19
				end	
			end
	elseif stringContains(message, "caught") and stringContains(message, "Sableye") and questCompleted then
		sableyeCounter = sableyeCounter + 1
			if catchSableye then
				if catchDarumaka then
					ignoreSableye = true
					questPart = 21
				elseif catchTorchic or catchShroomish then
					checkRareFarm()
					ignoreSableye = true
					questPart = 15
				else
					questPart = 20
				end
			end
		elseif stringContains(message, "caught") and stringContains(message, "Darumaka") and questCompleted then
		darumakaCounter = darumakaCounter + 1
		--checkRareFarm()
			if catchDarumaka then
				if catchTorchic or catchShroomish or catchSableye and resetFarm then
					ignoreDarumaka = true
					questPart = 22
				else
					questPart = 21
				end
			end
	elseif sys.stringContains(message, "You can not switch this Pokemon!") then
		fatal("Cant switch pokemon, restarting bot, be sure auto reconnect is on") -- not the ideal fix
	elseif stringContains(message, "A Wild SHINY ") then
		shinyCounter = shinyCounter + 1
		wildCounter = wildCounter + 1
	elseif stringContains(message, "Success! You caught ") then
		catchCounter = catchCounter + 1
		  log("Shinies Caught: " .. shinyCounter)
		  log("Pokemon Caught: " .. catchCounter)
		  log("Pokemons encountered: " .. wildCounter)
		  log("Shroomish' Caught: " .. shroomishCounter)
		  log("Torchics Caught: " .. torchicCounter)
		  log("Sableye Caught: " .. sableyeCounter)
		  log("Darumaka Caught: " .. darumakaCounter)
	elseif stringContains(message, "A Wild ") then
		wildCounter = wildCounter + 1
	end
end

function onPathAction ()
canRun = true
	if advanceSorting() then
		return true
	end
	if leftovers() then
		return true
	end
	
	pkmLevel = getPokemonLevel(1)
	
	if pkmLevel < 45 then
		fatal ("The first pokemon in your team is too weak for this")
	elseif pkmLevel == maxPokeLevel then
		fatal ("The first pokemon in your team reached level 100")
	end
	
	if getMapName() == "Vulcanic Town" and questPart >= 1 then
			local pokeballCount = getItemQuantity("Ultra Ball")
			local money         = getMoney()
			if money >= (buyBallAmount*1200) and pokeballCount < buyBallAmount then
				moveToMap("Pokemart Vulcanic Town")
			end
	elseif getMapName() == "Pokemart Vulcanic Town" then
			buyBalls()
	end
	
	if not isMounted () and hasItem ("Bicycle") and isOutside () and not isSurfing () then
		useItem ("Bicycle")
      	log ("Getting on bicycle")
-----------------------------------------------------------------------------------------
	elseif questPart == 0 then
			if not isOnMap ("Pokecenter Vulcanic Town") and not isOnMap ("Kalijodo Path") and not isOnMap ("Vulcanic Town") and not isOnMap ("Vulcanic Town House 1") and 
			not isOnMap ("Vulcan Forest") and not isOnMap ("Mt. Summer Exterior") and not isOnMap ("Mt. Summer Exterior 2") and not isOnMap ("Vermilion City") and
			not isOnMap ("Vulcan Island shore") and not isOnMap ("Vulcan Path") and not isOnMap ("Vulcanic Town House 1") and not isOnMap ("Kalijodo Path") and
			not isOnMap ("Kalijodo Lake") and not isOnMap ("Kalijodo Cave Entrance") and not isOnMap ("Kalijodo Cave B1F") and not isOnMap ("Kalijodo Cave B2F") and
			not isOnMap ("Mt. Summer 1F 2") and not isOnMap ("Mt. Summer 2F 2") and not isOnMap ("Mt. Summer 3F 2") and not isOnMap ("Mt. Summer Summit 2") and 
			not isOnMap ("Mt. Summer 4F 2") and not isOnMap ("Pokemart Vulcanic Town") then
				log ("cc")
				moveFromAnyToEvent()
			elseif getMapName() == ("Vermilion City") then
					log("verm")
					pushDialogAnswer(1)
				if isNpcOnCell(62,58) then
					talkToNpcOnCell(62,58)
				end
				if not isNpcOnCell(62,58) then
					moveToCell(62,57)
					log("no npc found")
				end
			elseif isOnMap ("Vulcan Island shore") then
				moveToMap("Vulcan Path")
				log ("Vulcan Island shore -> Vulcan Path")
			elseif isOnMap ("Vulcan Path") then
				log ("Vulcan Path -> NPC talk")
				if isNpcOnCell(28,43) then
					talkToNpcOnCell(28,43)
				elseif isNpcOnCell(22,37) then
					talkToNpcOnCell(22,37)
				else
				log("No more NPC's here")
				moveToMap("Vulcan Forest")
				questPart = 1
				end
			-- experimental
			elseif isOnMap ("Vulcan Forest") and questPart == 0 then
				questPart = 1
			elseif isOnMap ("Mt. Summer Exterior 2") and questPart == 0 then
				moveToMap("Vulcan Forest")
				questPart = 1
			elseif isOnMap ("Mt. Summer Exterior") and questPart == 0 then
				moveToMap("Vulcan Forest")
				questPart = 1
			elseif getMapName() == "Kalijodo Cave B2F" and questPart == 0 then
				questPart = 4
			   moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" and questPart == 0 then
				questPart = 4
				moveToMap("Kalijodo Cave Entrance")
			elseif getMapName() == "Kalijodo Cave Entrance" and questPart == 0 then
				questPart = 4
				moveToMap("Kalijodo Lake")
			elseif getMapName() == "Kalijodo Lake" and questPart == 0 then
				questPart = 4
				moveToMap("Kalijodo Path")
			elseif getMapName() == "Kalijodo Path" and questPart == 0 then
				questPart = 4
				moveToMap("Vulcanic Town")
			elseif getMapName() == "Vulcanic Town" and questPart == 0 then
				local pokeballCount = getItemQuantity("Ultra Ball")
				local money         = getMoney()
				if money >= (buyBallAmount*1200) and pokeballCount < buyBallAmount then
					moveToMap("Pokemart Vulcanic Town")
				else
					questPart = 1
					moveToMap("Vulcan Forest")
				end
			elseif getMapName() == "Vulcanic Town Pokemart" and questPart == 0 then
				buyBalls()
			elseif getMapName() == "Pokecenter Vulcanic Town" and questPart == 0 then
				moveToMap("Vulcanic Town")
			elseif isOnMap ("Mt. Summer 1F 2") and questPart == 0 then
				questPart = 17
			elseif isOnMap ("Mt. Summer 2F 2") and questPart == 0 then
				questPart = 17
			elseif isOnMap ("Mt. Summer 3F 2") and questPart == 0 then
				questPart = 17
			elseif isOnMap ("Mt. Summer 4F 2") and questPart == 0 then
				questPart = 17
			elseif isOnMap ("Mt. Summer Summit 2") and questPart == 0 then
				questPart = 17
			elseif isOnMap ("Vulcanic Town House 1") and questPart == 0 then
				questPart = 2
			end
			-- experimental
-----------------------------------------------------------------------------------------
	elseif questPart == 1 then
		if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
					if isOnMap ("Vulcan Forest") then
						if eventTeam == magma then
									log("1 moving to: magma")
									moveToCell(0, 29)
						elseif eventTeam == aqua then
							log("todo: aqua")
						else
							log("no team set")
						end
					elseif isOnMap ("Mt. Summer Exterior") then
						log("ee")
						if isNpcOnCell(48,57) then
							talkToNpcOnCell(48,57)
						else
							--moveToMap("Vulcan Forest")
							moveToCell(48,57)
							questPart = 2
						end
					elseif isOnMap ("Mt. Summer Exterior 2") then
							--moveToGrass()
						if isNpcOnCell(48,57) then
							talkToNpcOnCell(48,57)
						else
							--moveToMap("Vulcan Forest")
							moveToCell(48,57)
							questPart = 2
						end
					elseif isOnMap ("Pokecenter Vulcanic Town") then
						moveToMap("Vulcanic Town")
					elseif isOnMap ("Vulcanic Town") then
						moveToMap("Vulcan Forest")	
					end
		else
			if isOnMap ("Mt. Summer Exterior 2") then
				moveToMap("Vulcan Forest")
			elseif isOnMap ("Mt. Summer Exterior") then
				moveToMap("Vulcan Forest")
			elseif isOnMap ("Vulcan Forest") then
				moveToMap("Vulcanic Town")
			elseif getMapName() == "Vulcanic Town" then
				moveToMap("Pokecenter Vulcanic Town")
			elseif getMapName() == "Pokecenter Vulcanic Town" then
				usePokecenter()
			end
		end
-----------------------------------------------------------------------------------------
	elseif questPart == 2 then
		if isOnMap ("Mt. Summer Exterior 2") then
				moveToMap("Vulcan Forest")
		elseif isOnMap ("Mt. Summer Exterior") then
				moveToMap("Vulcan Forest")
		elseif isOnMap ("Vulcan Forest") then
				moveToMap("Vulcanic Town")
		elseif isOnMap ("Vulcanic Town") then
				moveToMap("Vulcanic Town House 1")				
		elseif isOnMap ("Vulcanic Town House 1") then
			pushDialogAnswer(1)
			talkToNpc("Ahok")
		else
			--moveToMap("Vulcanic Town")
		end
-----------------------------------------------------------------------------------------
	elseif questPart == 3 then
		if isOnMap ("Vulcanic Town House 1") then
				moveToMap("Vulcanic Town")
		elseif isOnMap ("Vulcanic Town") then
				moveToMap("Vulcan Forest")
		elseif isOnMap ("Vulcan Forest") then
			if eventTeam == magma then
					log("3 moving to: magma")
					moveToCell(0, 29)
			elseif eventTeam == aqua then
					log("todo: aqua")
					--moveToCell(0, 29)
			else
					log("no team set")
			end	
		elseif isOnMap ("Mt. Summer Exterior") then
					log("ee")
						if isNpcOnCell(48,57) then
							talkToNpcOnCell(48,57)
						else
							questPart = 4
						end 
		elseif isOnMap ("Mt. Summer Exterior 2") then
							--moveToGrass()
						if isNpcOnCell(48,57) then
							talkToNpcOnCell(48,57)
						else
							--moveToMap("Vulcan Forest")
							moveToCell(48,57)
							questPart = 4
						end
		end
-----------------------------------------------------------------------------------------
	elseif questPart == 4 then
		if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
			if isOnMap ("Mt. Summer Exterior") then
				moveToMap("Vulcan Forest")
			elseif isOnMap ("Mt. Summer Exterior 2") then
				moveToMap("Vulcan Forest")
			elseif isOnMap ("Vulcan Forest") then
				moveToMap("Vulcanic Town")
		    elseif getMapName() == "Pokecenter Vulcanic Town" then
			   moveToMap("Vulcanic Town")
		    elseif getMapName() == "Vulcanic Town" then
			   moveToMap("Kalijodo Path")
		    elseif getMapName() == "Kalijodo Path" then
			   moveToMap("Kalijodo Lake")
			elseif getMapName() == "Kalijodo Lake" then
					if isNpcOnCell(30,27) then
						talkToNpcOnCell(30,27)
					end
					if not isNpcOnCell(30,27) then
						moveToMap("Kalijodo Cave Entrance")
					end
			elseif getMapName() == "Kalijodo Cave Entrance" then
				moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave B2F")
			elseif getMapName() == "Kalijodo Cave B2F" then
				if isNpcOnCell(24,11) then
						talkToNpcOnCell(24,11)
				end
				if not isNpcOnCell(24,11) then
						log("no boss")
						questPart = 5
						moveToMap("Kalijodo Cave B1F")
				end
			end
		else
			if getMapName() == "Kalijodo Cave B2F" then
			   moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave Entrance")
			elseif getMapName() == "Kalijodo Cave Entrance" then
				moveToMap("Kalijodo Lake")
			elseif getMapName() == "Kalijodo Lake" then
				moveToMap("Kalijodo Path")
			elseif getMapName() == "Kalijodo Path" then
				moveToMap("Vulcanic Town")
			elseif getMapName() == "Vulcanic Town" then
				moveToMap("Pokecenter Vulcanic Town")
			elseif getMapName() == "Pokecenter Vulcanic Town" then
				usePokecenter()
			end
		end
-----------------------------------------------------------------------------------------
	elseif questPart == 5 then
			if getMapName() == "Kalijodo Cave B2F" then
			   moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave Entrance")
			elseif getMapName() == "Kalijodo Cave Entrance" then
				moveToMap("Kalijodo Lake")
			elseif getMapName() == "Kalijodo Lake" then
				if isNpcOnCell(30,27) then
						talkToNpcOnCell(30,27)
						questPart = 6
				end
				if not isNpcOnCell(30,27) then
						questPart = 15
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 6 then
			if getMapName() == "Kalijodo Lake" then
					if isNpcOnCell(30,27) then
						talkToNpcOnCell(30,27)
					end
					if not isNpcOnCell(30,27) then
						moveToMap("Kalijodo Cave Entrance")
					end
			elseif getMapName() == "Kalijodo Cave Entrance" then
				moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				if isNpcOnCell(9,3) then
					talkToNpcOnCell(9,3)
					log("going for 1st gem")
				else
					log("no more 1st gem")
					questPart = 7
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 7 then
			if getMapName() == "Kalijodo Cave B1F" then
				if isNpcOnCell(20,13) then
					talkToNpcOnCell(20,13)
					log("going for 2nd gem")
				else
					log("no more 2nd gem")
					questPart = 8
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 8 then
			if getMapName() == "Kalijodo Cave B1F" then
				if isNpcOnCell(40,13) then
					talkToNpcOnCell(40,13)
					log("going for 3nd gem")
				else
					log("no more 3nd gem")
					questPart = 9
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 9 then
			if getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave B2F")
			elseif getMapName() == "Kalijodo Cave B2F" then
				if isNpcOnCell(45,15) then
					talkToNpcOnCell(45,15)
					log("going for 4th gem")
				else
					log("no more 4th gem")
					questPart = 10
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 10 then
			if getMapName() == "Kalijodo Cave B2F" then
				if isNpcOnCell(8,15) then
					talkToNpcOnCell(8,15)
					log("going for 5th gem")
				else
					log("no more 5th gem")
					questPart = 11
				end
			else
			log("something went wrong...")
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 11 then
			if getMapName() == "Kalijodo Cave B2F" then
				if isNpcOnCell(15,11) then
					talkToNpcOnCell(15,11)
					log("going for 6th gem")
				else
					log("no more 6th gem")
					questPart = 12
				end
			else
			log("something went wrong...")
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 12 then
			if getMapName() == "Kalijodo Cave B2F" then
				if isNpcOnCell(40,11) then
					talkToNpcOnCell(40,11)
					log("going for 7th gem")
				else
					log("no more 7th gem")
					questPart = 13
				end
			else
			log("something went wrong...")
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 13 then
			if getMapName() == "Kalijodo Cave B2F" then
			   moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave Entrance")
			elseif getMapName() == "Kalijodo Cave Entrance" then
				if isNpcOnCell(7,3) then
					talkToNpcOnCell(7,3)
					log("going for 8th gem")
				else
					log("no more 8th gem")
					questPart = 14
				end
			else
			log("something went wrong...")
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 14 then
			if getMapName() == "Kalijodo Cave B2F" then
			   moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave Entrance")
			elseif getMapName() == "Kalijodo Cave Entrance" then
				moveToMap("Kalijodo Lake")
			elseif getMapName() == "Kalijodo Lake" then
				if isNpcOnCell(30,27) then
						talkToNpcOnCell(30,27)
						questPart = 15
				end
				if not isNpcOnCell(30,27) then
						questPart = 15
				end
			else
			log("something went wrong...")
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 15 then
			if getMapName() == "Kalijodo Cave B2F" then
			   moveToMap("Kalijodo Cave B1F")
			elseif getMapName() == "Kalijodo Cave B1F" then
				moveToMap("Kalijodo Cave Entrance")
			elseif getMapName() == "Kalijodo Cave Entrance" then
				moveToMap("Kalijodo Lake")
			elseif getMapName() == "Kalijodo Lake" then
				moveToMap("Kalijodo Path")
			elseif getMapName() == "Kalijodo Path" then
				moveToMap("Vulcanic Town")
			elseif getMapName() == "Vulcanic Town" then
					moveToMap("Vulcan Forest")
			elseif getMapName() == "Vulcan Forest" then
					if eventTeam == magma then
						log("15 moving to: magma")
						moveToCell(0, 29)
					elseif eventTeam == aqua then
						log("todo: aqua")
					else
						log("no team set or typo")
					end
			elseif isOnMap ("Mt. Summer Exterior") then
				if isNpcOnCell(48,57) then
					talkToNpcOnCell(48,57)
					questPart = 16
				else 
					questPart = 16
				end
				if not isNpcOnCell(48,57) then
					log("something went wrong...")
				end
			elseif isOnMap ("Mt. Summer Exterior 2") then
				if not isNpcOnCell(48,57) then
					moveToMap("Vulcan Forest")
					questPart = 16
				else 
					talkToNpcOnCell(48,57)
					moveToMap("Vulcan Forest")
					questPart = 16
				end
			else
			log("something went wrong...")
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 16 then
			if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
				if isOnMap ("Pokecenter Vulcanic Town") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Vulcan Island shore") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcan Forest") then
					if eventTeam == magma then
						log("16 moving to: magma")
						moveToCell(0, 29)
					elseif eventTeam == aqua then
						log("todo: aqua")
					else
						log("no team set")
					end
				elseif isOnMap ("Mt. Summer Exterior") then
				log("ee")
						--moveToGrass()
						questPart = 17
				elseif isOnMap ("Mt. Summer Exterior 2") then
						--moveToGrass()
						if isNpcOnCell(48,57) then
							talkToNpcOnCell(48,57)
						else
							--moveToMap("Vulcan Forest")
							if questCompleted and not ignoreTorchic then
								moveToGrass()
							else
								moveToCell(48,57)
								questPart = 17
							end
						end
				end
			else
				if isOnMap ("Mt. Summer Exterior 2") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Mt. Summer Exterior") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Pokecenter Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					usePokecenter()
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 17 then
			if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
				if isOnMap ("Mt. Summer Exterior 2") then
					moveToMap("Mt. Summer 1F 2")
				elseif isOnMap ("Mt. Summer 1F 2") then
					moveToCell(3,3)
				elseif isOnMap ("Mt. Summer 2F 2") then
					moveToCell(53,4)
				elseif isOnMap ("Mt. Summer 3F 2") then
					moveToCell(27,16)
				elseif isOnMap ("Mt. Summer 4F 2") then
					moveToCell(22,30)
				elseif isOnMap ("Mt. Summer Summit 2") then
					talkToNpc("Magma Grunt Leader")
				end
			else
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
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Pokecenter Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					usePokecenter()
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 18 then
			if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
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
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Vulcanic Town House 1")
				elseif isOnMap ("Vulcanic Town House 1") then
					talkToNpc("Ahok")
				end
			else
				if isOnMap ("Mt. Summer Summit 2") then
					moveToMap("Mt. Summer 3F 2")
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
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Pokecenter Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					usePokecenter()
				end
			end
-----------------------------------------------------------------------------------------
	elseif questPart == 19 then
			if questCompleted and ignoreShroomish and ignoreTorchic and ignoreWynaut and ignoreSableye then
				questPart = 21
			end
			if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
				if isOnMap ("Pokecenter Vulcanic Town") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town House 1") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Vulcan Island shore") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcan Forest") then
					if eventTeam == magma then
						if not ignoreShroomish and questCompleted then
									moveToGrass()
								else
									log("19 moving to: magma")
									moveToCell(0, 29)
								end
					elseif eventTeam == aqua then
						log("todo: aqua")
					else
						log("no team set")
					end
				elseif isOnMap ("Mt. Summer Exterior") then
				log("ee")
						--moveToGrass()
						questPart = 17
				elseif isOnMap ("Mt. Summer Exterior 2") then
						--moveToGrass()
						if isNpcOnCell(48,57) then
							talkToNpcOnCell(48,57)
						else
							if questCompleted and not ignoreTorchic then
								moveToGrass()
							else
								log("going for next rare")
								moveToMap("Mt. Summer 1F 2")
							end
						end
				elseif isOnMap ("Mt. Summer 1F 2") then
					moveToCell(54,37)
					questPart = 20
				end
			else
				if isOnMap ("Mt. Summer Exterior 2") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Mt. Summer Exterior") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Pokecenter Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					usePokecenter()
				end
			end
-----------------------------------------------------------------------------------------
elseif questPart == 20 then --not finished
			if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
				if isOnMap ("Mt. Summer Exterior 2") then
					moveToMap("Mt. Summer 1F 2")
				elseif isOnMap ("Mt. Summer 1F 2") then
							if questCompleted and not ignoreSableye then
									moveToRectangle(53, 11, 56, 36)
							else
								log("going for next rare")
								--moveToCell(3,3)
								moveToMap("Mt. Summer Exterior 2")
								questPart = 21
							end	
				elseif isOnMap ("Mt. Summer 2F 2") then
							if questCompleted and not ignoreWynaut then
								moveToRectangle(53, 11, 56, 36)
							else
								log("going for next rare")
								moveToCell(53,4)
								questPart = 21
							end	
				elseif isOnMap ("Mt. Summer 3F 2") then
					moveToCell(27,16)
				elseif isOnMap ("Mt. Summer 4F 2") then
					moveToCell(22,30)
				elseif isOnMap ("Mt. Summer Summit 2") then
					talkToNpc("Magma Grunt Leader")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Vulcan Forest")
				elseif isOnMap ("Vulcan Forest") then
					moveToCell(0, 29)
				end
			else
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
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Pokecenter Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					usePokecenter()
					questPart = 19
				end
			end
-----------------------------------------------------------------------------------------
elseif questPart == 21 then --not 100% finished
			if isPokemonUsable(5) and isPokemonUsable(1) and isPokemonUsable(2) then
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
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					moveToMap("Vulcanic Town")
				elseif getMapName() == "Vulcanic Town" then
					moveToMap("Kalijodo Path")
				elseif getMapName() == "Kalijodo Path" then
					moveToMap("Kalijodo Lake")
				elseif getMapName() == "Kalijodo Lake" then
					if isNpcOnCell(30,27) then
						talkToNpcOnCell(30,27)
						questPart = 5
					end
					if not isNpcOnCell(30,27) then
						moveToMap("Kalijodo Cave Entrance")
					end
				elseif getMapName() == "Kalijodo Cave Entrance" then
					moveToMap("Kalijodo Cave B1F")
				elseif getMapName() == "Kalijodo Cave B1F" then
					moveToMap("Kalijodo Cave B2F")
				elseif getMapName() == "Kalijodo Cave B2F" then
					moveToRectangle(45, 6, 47, 25)
				end
			else
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
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					moveToMap("Pokecenter Vulcanic Town")
				elseif isOnMap ("Pokecenter Vulcanic Town") then
					usePokecenter()
					questPart = 21
				end
			end
-----------------------------------------------------------------------------------------
elseif questPart == 22 then --not 100% finished
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
				elseif isOnMap ("Vulcan Forest") then
					moveToMap("Vulcanic Town")
				elseif isOnMap ("Vulcanic Town") then
					questPart = 19
					ignoreDarumaka = false
				end
-----------------------------------------------------------------------------------------
	end
end
-----------------------------------------------------------------------------------------
function buyBalls()
	local pokeballCount = getItemQuantity("Ultra Ball")
	local money         = getMoney()
	if money >= (buyBallAmount*1200) and pokeballCount < buyBallAmount then
		if not isShopOpen() and not getPlayerX() == 4 and not getPlayerY() == 4 then
			moveToCell(4,4)
		elseif not isShopOpen() and getPlayerX() == 4 and getPlayerY() == 4 then
			return talkToNpcOnCell(3,4)
		else
			local pokeballToBuy = buyBallAmount - pokeballCount
			local maximumBuyablePokeballs = money / 1200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
				return buyItem("Ultra Ball", pokeballToBuy)
		end
	else
		return moveToMap("Vulcanic Town")
	end
end

function onBattleAction()
canRun = true
	if isWildBattle() and isOpponentShiny() then
		if useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") then
			return true
		end
	elseif isWildBattle() and not isAlreadyCaught() then
			if useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") then
				return true
			end
	elseif isWildBattle() and isPokemonInList() then
			if useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") then
				return true
			end
	end	
	-- if we do not try to catch it
	if getTeamSize() == 1 or getUsablePokemonCount() > 1 then
		local opponentLevel = getOpponentLevel()
		local myPokemonLvl  = getPokemonLevel(getActivePokemonNumber())
		if opponentLevel >= myPokemonLvl then
			local requestedId, requestedLevel = game.getMaxLevelUsablePokemon()
			if requestedId ~= nil and requestedLevel > myPokemonLvl then
				return sendPokemon(requestedId)
			end
		end
		return attack() or sendUsablePokemon() or run() or sendAnyPokemon()
	else
		if not canRun then
			return attack() or game.useAnyMove()
		end
		return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
	end
end

function onDialogMessage(message)
	if message == "Please select a Pokemon that knows the Dig technique." then
		pushDialogAnswer(digIndex)
	elseif message == "Reselect a different Pokemon?" then
		fatal ("Failed to Dig")
	elseif sys.stringContains(message, "Please go away, we Team") then
		log("questpart2")
		questPart = 2
	elseif sys.stringContains(message, "I'm relying on you, please") then
		log("questpart3")
		questPart = 3
	elseif stringContains(message, "Not yet") and stringContains(message, "possible") then
		log("questpart3")
		questPart = 3
	elseif sys.stringContains(message, "stop those Aqua Grunts") then
		log("questpart4")
		questPart = 4
	elseif sys.stringContains(message, "Just do what you think is right") then
		log("questpart5")
		questPart = 5
	elseif sys.stringContains(message, "We will be waiting for you there!") then
		log("questpart15")
		questPart = 15
	elseif sys.stringContains(message, "Received 1 Black-Red Summer Clothes.") or sys.stringContains(message, "Thanks to you, we can now enjoy our vacation in this lava surrounded mountain!") then
		log("questpart18")
		questPart = 18
	elseif sys.stringContains(message, "Here, take a souvenir from this island.") or sys.stringContains(message, "Thanks again for your help! I hope you were this city's citizen, man!") then 
		log("Magma Quest Completed, start rare pokemon farm")
		questPart = 19
		questCompleted = true
	elseif stringContains(message, "There you go, take care of them!") then
        healCounter = healCounter + 1
        log("You have visited the PokeCenter ".. healCounter .." times.")
	end
end

------------------------------------
-- Comparison or Checking Function -
------------------------------------
function isOnMap (mapName)
	if getMapName () == mapName then
		return true
	else
		return false
	end
end

function isPokemonInList ()
 	if catchList[1] ~= "" then
 		for i = 1, tableLength (catchList), 1 do
 			if getOpponentName() == catchList[i] then
 				return true
 			end
 		end
 	end
 
 	return false
 end
 
 function tableLength (t)
 	local count = 0
 		for _ in pairs(t) do 
 			count = count + 1 
 		end
 	return count
 end
------------------------
-- Leveling functions --
------------------------

------------------------
-- Movement functions --
------------------------
function moveFromAnyToEvent()
	if not isMounted () and hasItem ("Bicycle") and isOutside () and not isSurfing () then
		useItem ("Bicycle")
      	log ("Getting on bicycle")
		else
		MoveTo("Vermilion City") -- MoveTo is Casensitive 
	end
end
