name = "Level your whole PC to 100"
author = "PotatoBlood"
description = [[Levels your whole PC to the maxPokeLevel, Catch uncaught pokemon, shinies and the catchList, farm at different places, randomized with a timer. Uses leftovers, teamsorting, automatic movelearner and pathfinding. Automatically buys TM's and learns HMs and TMs to unusable pokemon]]
----------------------------------------------------------------
-- TODO: 
-- auto evolve off before lvl for evo 1 and lvl for evo 2 that ppl choose 66 on, 67 off, 80 on
-- pokeball buyer
-- lvls / hour & pokedollars / hour
-- check the levels , then change the pokes lvl 100 and withdraw until 6pokes and then try the move thing and go farm
----------------------------------------------------------------
catchList = {"Electabuzz", "Charmander", "Abra", "Dratini", "Dragonair", "Snorlax", "Natu", "Ralts"}
-- Max level - set to 90 to change pokes at lvl 90, set to 100 to change pokes at lvl 100, 101 to keep farming at level 100
maxPokeLevel = 100
--------------------------------------------------------------
-- Only touch the code below if you know what you are doing --
--------------------------------------------------------------
local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"
local PathFinder = require "Pathfinder/Maps_Pathfind"

zoneExp = 1
timeSeed = 0
minuteZones = 45
lowteam = false
pokemonCutId = 1
pokemonSurfId = 1
pokemonDiveId = 1
allUsable = false
route4Start = 0
timerRoot = os.time()
timerSwitch = false
canRun = true
nrTM = 1
allMaxed = false
gobuy = false
buyAmount = 5
money = getMoney()
showDebug = false
startMoney = getMoney()

function changeZoneExp()
	if os.clock() > (timeSeed + (minuteZones * 60)) then
		timeSeed = os.clock()
			if hasItem("Rising Badge") then
				zoneExp = math.random(1,4)
			else
				zoneExp = math.random(1,2)
			end
		log("LOG:  Changing to Zone N*: " .. zoneExp)
		return false
	end
	return false
end

function leftovers()
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = game.getFirstUsablePokemon()
	local PokemonWithLeftovers = game.getPokemonIdWithItem(ItemName)

	if getTeamSize() > 0 then
		if PokemonWithLeftovers > 0 then
			if PokemonNeedLeftovers == PokemonWithLeftovers  then
				return false -- now leftovers is on rightpokemon
			else
				takeItemFromPokemon(PokemonWithLeftovers)
				return true
			end
		else

			if hasItem(ItemName) and PokemonNeedLeftovers ~= 0 then
				giveItemToPokemon(ItemName,PokemonNeedLeftovers)
				return true
			else
				return false-- don't have leftovers in bag and is not on pokemons
			end
		end
	else
		return false
	end
end

function advanceSorting()
	local pokemonsUsable = game.getTotalUsablePokemonCount()
	for pokemonId=1, pokemonsUsable, 1 do
		if not isPokemonUsable(pokemonId) and not allMaxed then --Move it at bottom of the Team
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

function onStart()
	PathFinder.DisableDigPath()
	startime = os.time()
    pcVisits = 0
    shinyCounter = 0
    wildCounter = 0
	catchCounter = 0
	dragonairCounter = 0
	if hasItem("Rising Badge") then
			log("*********************************************************************************************")
			log("Leveling all your pokes from your PC to " .. maxPokeLevel .. ". All 4 Farm Zones, Rising Badge found.")
			log("*********************************************************************************************")
	else
			log("*********************************************************************************************")
			log("Leveling all your pokes from your PC to " .. maxPokeLevel .. ". Farm in Victory Road, no Rising Badge found.")
			log("*********************************************************************************************")
	end
end

function onPause()
	log("*********************************************************************************************")
    log("Shinies Caught: " .. shinyCounter)
    log("Pokemons encountered: " .. wildCounter)
	log("Pokemons caught: " .. catchCounter)
	log("Zone N*: " .. zoneExp)
    log("You have visited the PokeCenter ".. pcVisits .." times.")
	log("Pokedollars earned: " .. tostring(getMoney() - startMoney))
	endtime = os.time()
	log(string.format("Bot running time: %.2f", os.difftime(endtime,startime)/3600 ).. " hours")
    log("or")
    log(string.format("Bot running time: %.2f", os.difftime(endtime,startime)/60 ).. " minutes")
    log("*********************************************************************************************")
	if showDebug then
	log("*********************************************************************************************")
							for pokemon=1, getTeamSize() do
								pcMove1 = tostring(getPokemonMoveName(pokemon,1))
								pcMove2 = tostring(getPokemonMoveName(pokemon,2))
								pcMove3 = tostring(getPokemonMoveName(pokemon,3))
								pcMove4 = tostring(getPokemonMoveName(pokemon,4))
								log("Pokemon:"  .. pokemon ..  " - move 1: " .. pcMove1 ..  " - move 2: " .. pcMove2 ..  " - move 3: " .. pcMove3 ..  " - move 4: " .. pcMove4 .. "")
							end
	log("allUsable:" .. tostring(allUsable) .. "")
	log("nrTM:" .. tostring(nrTM) .. "")
	log("max lvl:" .. tostring(count100s()) .. "")
	log("allmax:" .. tostring(allMaxed) .. "")
	log("gobuy: ".. tostring(gobuy) .. "")
    log("*********************************************************************************************")
	end
end

function onStop()
	if showDebug then
	log("*********************************************************************************************")
							for pokemon=1, getTeamSize() do
								pcMove1 = tostring(getPokemonMoveName(pokemon,1))
								pcMove2 = tostring(getPokemonMoveName(pokemon,2))
								pcMove3 = tostring(getPokemonMoveName(pokemon,3))
								pcMove4 = tostring(getPokemonMoveName(pokemon,4))
								log("Pokemon:"  .. pokemon ..  " - move 1: " .. pcMove1 ..  " - move 2: " .. pcMove2 ..  " - move 3: " .. pcMove3 ..  " - move 4: " .. pcMove4 .. "")
							end
	log("allUsable:" .. tostring(allUsable) .. "")
	log("nrTM:" .. tostring(nrTM) .. "")
	log("max lvl:" .. tostring(count100s()) .. "")
	log("allmax:" .. tostring(allMaxed) .. "")
	log("gobuy: ".. tostring(gobuy) .. "")
    log("*********************************************************************************************")
	end
end

function onDestination1()
	if getMapName() == "Pokecenter Blackthorn" or getMapName() == "Blackthorn City" or getMapName() == "Dragons Den Entrance" or getMapName() == "Dragons Den" or 
	getMapName() == "Blackthorn City Pokemart" then
		return true
	else
		return false
	end
end

function onDestination2()
	if getMapName() == "Indigo Plateau" or getMapName() == "Indigo Plateau Center" or getMapName() == "Victory Road Kanto 3F" or getMapName() == "Victory Road Kanto 2F" or 
	getMapName() == "Victory Road Kanto 1F" then
		return true
	else
		return false
	end
end

function nearRoute4()
	if isOnMap ("Route 4") or isOnMap ("Cerulean City") or isOnMap ("Pokecenter Cerulean") then
		return true
	else
		return false
	end
end

function nearRoute1()
	if isOnMap ("Route 1") or isOnMap ("Viridian City") or isOnMap ("Route 1 Stop House") or isOnMap ("Pokecenter Viridian") then
		return true
	else
		return false
	end
end

function nearRoute10()
	if isOnMap ("Route 10") or isOnMap ("Pokecenter Route 10") then
		return true
	else
		return false
	end
end

function nearDigletts()
	if isOnMap ("Digletts Cave Entrance 2") or isOnMap ("Route 11") or isOnMap ("Vermilion City") or isOnMap ("Pokecenter Vermilion") then
		return true
	else
		return false
	end
end

function nearRoute13()
	if isOnMap ("Berry Tower Reception Kanto") or isOnMap ("Route 13") then
		return true
	else
		return false
	end
end

function inCeladonMart()
	if isOnMap ("Celadon City") or isOnMap ("Celadon Mart 1") or isOnMap ("Celadon Mart 2") or isOnMap ("Celadon Mart 3") or isOnMap ("Celadon Mart 4") or isOnMap ("Celadon Mart 5") or isOnMap ("Celadon Mart 6") or isOnMap ("Celadon Mart Elevator") then
		return true
	else
		return false
	end
end

function hasSurf(pokinr)
	if getPokemonMoveName(pokinr,1) == "surf" or
		getPokemonMoveName(pokinr,2) == "surf" or
		getPokemonMoveName(pokinr,3) == "surf" or
		getPokemonMoveName(pokinr,4) == "surf" then
		return true
	else
	return false
	end
end

function hasCut(pokinr)
	if getPokemonMoveName(pokinr,1) == "cut" or
		getPokemonMoveName(pokinr,2) == "cut" or
		getPokemonMoveName(pokinr,3) == "cut" or
		getPokemonMoveName(pokinr,4) == "cut" then
		return true
	else
	return false
	end
end

function teamHas100()
	if getPokemonLevel(1) >= maxPokeLevel and getPokemonLevel(2) >= maxPokeLevel and getPokemonLevel(3) >= maxPokeLevel and getPokemonLevel(4) >= maxPokeLevel and getPokemonLevel(5) >= maxPokeLevel and getPokemonLevel(6) >= maxPokeLevel then
		log("All Pokemon are lvl " .. maxPokeLevel .. " or more.")
		allMaxed = true
	end
end

function rdyForIt(pokinr)
	if getPokemonLevel(pokinr) < maxPokeLevel or (getPokemonLevel(pokinr) < maxPokeLevel and hasCut(pokinr)) or (getPokemonLevel(pokinr) < maxPokeLevel and hasSurf(pokinr)) then
		return true
	else
		return false
	end
end

function allLow()
	if rdyForIt(1) and
		rdyForIt(2) and 
		rdyForIt(3) and 
		rdyForIt(4) and 
		rdyForIt(5) and 
		rdyForIt(6) then
		--log("All Pokemon are lower than " .. maxPokeLevel .. " or have surf or cut.")
		allMaxed = false
	end
end

function teamReady()
	if game.hasPokemonWithMove("Cut") and game.hasPokemonWithMove("Surf") then
		return true
	else
		return false
	end
end


function goBuy()
	if not inCeladonMart() then
		log("!!!!Cant learn any of the moves you own!!!!! going to buy TMs")
		PathFinder.MoveTo("Celadon City")
	else
		log("arrived in celadon, going to market")
		buyTM()
	end
end

function countItemz(item)
	if hasItem(item) then
		return getItemQuantity(item)
	else
		return 0
	end
end

function needLearning(pokinr)
	if not isPokemonUsable(pokinr) and getPokemonHealthPercent(pokinr) > 80 then
		return true
	else
		return false
	end
end

function onPathAction()
	if not teamReady() and not allMaxed then
	learnCutAndSurf()
	elseif advanceSorting() then
		return true
	elseif leftovers() then
		return true
	elseif teamHas100() then
	elseif allLow() then
	elseif gobuy then
	goBuy()
	elseif allMaxed then
		if stringContains(getMapName(), "Pokecenter") then
			if not isTeamSortedByLevelAscending() then
				sortTeamByLevelAscending()
			elseif getPokemonLevel(6) >= maxPokeLevel and not lowteam then
				if isPCOpen() then
					if isCurrentPCBoxRefreshed() then
						if getCurrentPCBoxSize() ~= 0 then
							for pokemon=1, getCurrentPCBoxSize() do
								if getPokemonLevelFromPC(getCurrentPCBoxId(), pokemon) < maxPokeLevel and getPokemonNameFromPC(getCurrentPCBoxId(), pokemon) ~= "Metapod" and getPokemonNameFromPC(getCurrentPCBoxId(), pokemon) ~= "Kakuna" and getPokemonNameFromPC(getCurrentPCBoxId(), pokemon) ~= "Magikarp" then
								return swapPokemonFromPC(getCurrentPCBoxId(),pokemon,6) 	
								end
							end
							return openPCBox(getCurrentPCBoxId()+1)
						else
							lowteam = true
							return
						end
					else
						return
					end
				else
					return usePC()
				end
			else
				log("oink")
				lowteam = false
			end
		else
			PathFinder.MoveToPC()
		end
	else	
		if not isMounted() and hasItem("Bicycle") and isOutside() and not isSurfing() and not gobuy then
			useItem ("Bicycle")
			log ("Getting on bicycle")
		elseif getMapName() == "Ice Path 1F" and getPlayerX() == 50 and getPlayerY() == 15 then
				moveToCell(51,17)
		elseif not allUsable and teamReady() then
				if needLearning(1) then
					learnSomething(1)
				elseif needLearning(2) then
					learnSomething(2)
				elseif needLearning(3) then
					learnSomething(3)
				elseif needLearning(4) then
					learnSomething(4)
				elseif needLearning(5) then
					learnSomething(5)
				elseif needLearning(6) then
					learnSomething(6)
				else
					allUsable = true
					gobuy = false
				end
		elseif getMapName() == "Celadon Mart 3" or getMapName() == "Celadon Mart 2" or getMapName() == "Celadon Mart 1" then
		log("ee")
			if getMapName() == "Celadon Mart 3" then
				moveToMap("Celadon Mart 2")
			elseif getMapName() == "Celadon Mart 2" then
				moveToMap("Celadon Mart 1")
			elseif getMapName() == "Celadon Mart 1" then
				moveToMap("Celadon City")
			end
		elseif teamReady() then
				--log("Starting leveling")
				if getPokemonLevel(1) < 10 or getPokemonLevel(2) < 10 or getPokemonLevel(3) < 10 or getPokemonLevel(4) < 10 or getPokemonLevel(5) < 10 or getPokemonLevel(6) < 10 then
					if not nearRoute1() then
						PathFinder.MoveTo("Route 1")
					else
						levelOnRouteOne()
					end
				elseif getPokemonLevel(1) < 18 or getPokemonLevel(2) < 18 or getPokemonLevel(3) < 18 or getPokemonLevel(4) < 18 or getPokemonLevel(5) < 18 or getPokemonLevel(6) < 18 then
					if not nearRoute4() then
						PathFinder.MoveTo("Route 4")
					else
						levelOnRouteFour()
					end
				elseif getPokemonLevel(1) < 26 or getPokemonLevel(2) < 26 or getPokemonLevel(3) < 26 or getPokemonLevel(4) < 26 or getPokemonLevel(5) < 26 or getPokemonLevel(6) < 26 then
					if not nearRoute10() then
						PathFinder.MoveTo("Route 10")
					else
						levelOnRouteTen()
					end
				elseif getPokemonLevel(1) < 35 or getPokemonLevel(2) < 35 or getPokemonLevel(3) < 35 or getPokemonLevel(4) < 35 or getPokemonLevel(5) < 35 or getPokemonLevel(6) < 35 then
					if not nearDigletts() then
						PathFinder.MoveTo("Digletts Cave Entrance 2")
					else
						levelOnDiglettsCave()
					end
				elseif getPokemonLevel(1) < 55 or getPokemonLevel(2) < 55 or getPokemonLevel(3) < 55 or getPokemonLevel(4) < 55 or getPokemonLevel(5) < 55 or getPokemonLevel(6) < 55 then
					if not nearRoute13() then
						PathFinder.MoveTo("Route 13")
					else
						levelOnRouteThirteen()
					end
				elseif getPokemonLevel(1) >= 55 and getPokemonLevel(2) >= 55 and getPokemonLevel(3) >= 55 and getPokemonLevel(4) >= 55 and getPokemonLevel(5) >= 55 and getPokemonLevel(6) >= 55 then	
					if changeZoneExp() == false then
						if zoneExp == 1 then -- Victory Road Kanto 3F
							if not onDestination2() then
								PathFinder.MoveTo("Indigo Plateau")
							else
								farmVRK3F()
							end
						elseif zoneExp == 2 then -- Victory Road Kanto 1F
							if not onDestination2() then
								PathFinder.MoveTo("Indigo Plateau")
							else
								farmVRK1F()
							end
						elseif zoneExp == 3 then --Dragons Den Surf
							if not onDestination1() then
								PathFinder.MoveTo("Blackthorn City")
							else
								farmDragonsDen()
							end
						elseif zoneExp == 4 then --Dragons Den walk
							if not onDestination1() then
								PathFinder.MoveTo("Blackthorn City")
							else
								farmDragonsDen()
							end
						end
					else
							fatal("Error zone exp")
					end
				else
					fatal("Error Level detection, or u dont have cut or surf")
				end
		else
		end
	end
end

function onBattleAction()
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
		return attack() or sendUsablePokemon() or run() or sendAnyPokemon()
	else
		if not canRun then
			return attack() or run()
		end
		return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
	end
end

function onBattleMessage(message)
	if stringContains(message, "You can not run away!") or stringContains(message, "You failed to run away!") then
		canRun = false
	elseif stringContains(message, "A wild") then
		canRun = true
		wildCounter = wildCounter + 1
	elseif stringContains(message, "You can not switch this Pokemon!") then
		fatal("Cant switch pokemon, restarting bot, be sure auto reconnect is on") -- not the ideal fix
	elseif stringContains(message, "A Wild SHINY ") then
		shinyCounter = shinyCounter + 1
		wildCounter = wildCounter + 1
	elseif stringContains(message, "Success!") and stringContains(message, "Dragonair") then
		dragonairCounter = dragonairCounter + 1
		catchCounter = catchCounter + 1
	elseif stringContains(message, "Success! You caught ") then
		catchCounter = catchCounter + 1
	end
end

function onDialogMessage(message)
	if stringContains(message, "There you go, take care of them!") then
        pcVisits = pcVisits + 1
        log("You have visited the PokeCenter ".. pcVisits .." times.")
	end
end

function count100s()
	local count = 0
	for i = 1, getTeamSize() do
		if getPokemonLevel(i) >= maxPokeLevel then
			count = count + 1
		end
	end
	return count
end

function returnWhen()
	if count100s() == 5 then
		return 6
	elseif count100s() == 4 then
		return 5
	else
		return 4
	end
	return 6
end

function learnCutAndSurf()
			if not game.hasPokemonWithMove("Cut") then
				if pokemonCutId <= getTeamSize() then					
					useItemOnPokemon("HM01 - Cut", pokemonCutId)
					log("Pokemon: " .. pokemonCutId .. " Try Learning: HM01 - Cut")
					pokemonCutId = pokemonCutId + 1
				else
					log("No pokemon in this team can learn - Cut, taking any pokemon with cut from pc")
					if isPCOpen() then
						if isCurrentPCBoxRefreshed() then
							if getCurrentPCBoxSize() ~= 0 then
								for pokemon=1, getCurrentPCBoxSize() do
									pcMove1 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,1))
									pcMove2 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,2))
									pcMove3 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,3))
									pcMove4 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,4))
									if pcMove1 == "cut" or pcMove2 == "cut" or pcMove3 == "cut" or pcMove4 == "cut" then
										return swapPokemonFromPC(getCurrentPCBoxId(),pokemon,6) 	
									else
										log("No pokemon with cut found in pc at" .. getCurrentPCBoxId() .. " " .. pcMove1 .. " " .. pcMove2 .. " " .. pcMove3 .. " " .. pcMove4 .. " ")
									end
								end
								return openPCBox(getCurrentPCBoxId()+1)
							else
								lowteam = true
								return
							end
						else
							return
						end
					else
						return usePC()
					end
				end
			elseif not game.hasPokemonWithMove("Surf") and game.hasPokemonWithMove("Cut") then
				if pokemonSurfId <= getTeamSize() then					
					useItemOnPokemon("HM03 - Surf", pokemonSurfId)
					log("Pokemon: " .. pokemonSurfId .. " Try Learning: HM03 - Surf")
					pokemonSurfId = pokemonSurfId + 1
				else
					log("No pokemon in this team can learn - Surf, taking any pokemon with surf from pc")
					if isPCOpen() then
						if isCurrentPCBoxRefreshed() then
							if getCurrentPCBoxSize() ~= 0 then
								for pokemon=1, getCurrentPCBoxSize() do
									if getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,1) == "surf" or getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,2) == "surf" or getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,3) == "surf" or getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,4) == "surf" then
										log("Pokemon with surf found in pc")
										return swapPokemonFromPC(getCurrentPCBoxId(),pokemon,5)
									else
										pcMove1 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,1))
										pcMove2 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,2))
										pcMove3 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,3))
										pcMove4 = tostring(getPokemonMoveNameFromPC(getCurrentPCBoxId(),pokemon,4))
										log("No pokemon with surf found in pc at" .. getCurrentPCBoxId() .. " " .. pcMove1 .. " " .. pcMove2 .. " " .. pcMove3 .. " " .. pcMove4 .. " ")
									end
								end
								return openPCBox(getCurrentPCBoxId()+1)
							else
								lowteam = true
								return
							end
						else
							return
						end
					else
						return usePC()
					end
				end
			--elseif not game.hasPokemonWithMove("Dive") and hasItem("Rising Badge") and game.hasPokemonWithMove("Cut") and game.hasPokemonWithMove("Surf") then
				--if pokemonDiveId <= getTeamSize() then					
					--useItemOnPokemon("HM06 - Dive", pokemonDiveId)
					--log("Pokemon: " .. pokemonDiveId .. " Try Learning: HM06 - Dive")
					--pokemonDiveId = pokemonDiveId + 1
				--else
					--fatal("No pokemon in this team can learn - Dive")
				--end
			end
end

function farmDragonsDen()
	if isPokemonUsable(returnWhen()) then
			if getMapName() == "Pokecenter Blackthorn" then
                moveToMap("Blackthorn City")
            elseif getMapName() == "Blackthorn City" then
                    moveToMap("Dragons Den Entrance")
            elseif getMapName() == "Dragons Den Entrance" then
                moveToMap("Dragons Den")
            elseif getMapName() == "Dragons Den" then
				if zoneExp == 4 then
					moveToRectangle(35,23,55,24)
				elseif zoneExp == 3 then
					moveToWater()
				else
					log("Zone error on 4 or 3")
				end
			end
	else
			if getMapName() == "Dragons Den" then
				moveToMap("Dragons Den Entrance")
			elseif getMapName() == "Dragons Den Entrance" then
				moveToMap("Blackthorn City")
			elseif getMapName() == "Blackthorn City" then
				moveToMap("Pokecenter Blackthorn")
			elseif getMapName() == "Pokecenter Blackthorn" then
				usePokecenter()
			end
	end
end

function farmVRK1F()
	if isPokemonUsable(returnWhen()) then
		if getMapName() == "Indigo Plateau Center" then
			moveToMap("Indigo Plateau")
		elseif getMapName() == "Indigo Plateau" then
			moveToMap("Victory Road Kanto 3F")
		elseif getMapName() == "Victory Road Kanto 3F" then
			moveToCell(29,17)
		elseif getMapName() == "Victory Road Kanto 2F" then
			moveToMap("Victory Road Kanto 1F")
		elseif getMapName() == "Victory Road Kanto 1F" then
			moveToRectangle(36,36,42,41)
		end
	else
		if getMapName() == "Victory Road Kanto 1F" then
			moveToMap("Victory Road Kanto 2F")
		elseif getMapName() == "Victory Road Kanto 2F" then
			moveToMap("Victory Road Kanto 3F")
		elseif getMapName() == "Victory Road Kanto 3F" then
			moveToMap("Indigo Plateau")
		elseif getMapName() == "Indigo Plateau" then
			moveToMap("Indigo Plateau Center")
		elseif getMapName() == "Indigo Plateau Center" then
			talkToNpcOnCell(4, 22)
		end
	end
end

function farmVRK3F()
	if isPokemonUsable(returnWhen()) then
		if getMapName() == "Indigo Plateau Center" then
			moveToMap("Indigo Plateau")
		elseif getMapName() == "Indigo Plateau" then
			moveToMap("Victory Road Kanto 3F")
		elseif getMapName() == "Victory Road Kanto 1F" then
			moveToMap("Victory Road Kanto 2F")
		elseif getMapName() == "Victory Road Kanto 2F" then
			moveToMap("Victory Road Kanto 3F")
		elseif getMapName() == "Victory Road Kanto 3F" then
			moveToRectangle(46,14,47,22)
		end
	else
		if getMapName() == "Victory Road Kanto 1F" then
			moveToMap("Victory Road Kanto 2F")
		elseif getMapName() == "Victory Road Kanto 2F" then
			moveToMap("Victory Road Kanto 3F")
		elseif getMapName() == "Victory Road Kanto 3F" then
			moveToMap("Indigo Plateau")
		elseif getMapName() == "Indigo Plateau" then
			moveToMap("Indigo Plateau Center")
		elseif getMapName() == "Indigo Plateau Center" then
			talkToNpcOnCell(4, 22)
		end
	end
end

function levelOnRouteOne()
	if isPokemonUsable(6) then
		if getMapName() == "Pokecenter Viridian" then
			moveToMap("Viridian City")
		elseif getMapName() == "Viridian City" then
			moveToMap("Route 1 Stop House")
		elseif getMapName() == "Route 1 Stop House" then
			moveToMap("Route 1")
		elseif getMapName() == "Route 1" then
			moveToGrass()
		end
	else
		if getMapName() == "Route 1" then
			moveToMap("Route 1 Stop House")
		elseif getMapName() == "Route 1 Stop House" then
			moveToMap("Viridian City")
		elseif getMapName() == "Viridian City" then
			moveToMap("Pokecenter Viridian")
		elseif getMapName() == "Pokecenter Viridian" then
			usePokecenter()
		end
	end
end

function levelOnRouteFour()
	if isPokemonUsable(6) then
		if getMapName() == "Pokecenter Cerulean" then
			moveToMap("Cerulean City")
		elseif getMapName() == "Cerulean City" then
			moveToMap("Route 4")
		elseif getMapName() == "Route 4" and not getPlayerX() == "75" and not getPlayerX() == "19" then
			route4Start = 0
		elseif getMapName() == "Route 4" and route4Start == 0 then
			moveToCell(75,19)
			route4Start = 1
		elseif getMapName() == "Route 4" and route4Start == 1 then
			moveToGrass()
		end
	else
		if getMapName() == "Route 4" and not getPlayerX() == "75" and not getPlayerX() == "19" then
			route4Start = 0
		elseif getMapName() == "Route 4" and route4Start == 0 then
			moveToCell(75,19)
			route4Start = 1
		elseif getMapName() == "Route 4" and route4Start == 1 then
			moveToMap("Cerulean City")
		elseif getMapName() == "Cerulean City" then
			moveToMap("Pokecenter Cerulean")
		elseif getMapName() == "Pokecenter Cerulean" then
			usePokecenter()
		end
	end
end

function levelOnRouteTen ()
	if isPokemonUsable (6) then
		if getMapName () == "Pokecenter Route 10" then
			moveToMap ("Route 10")
		elseif getMapName () == "Route 10" then
			moveToGrass ()
		end
	else
		if getMapName () == "Route 10" then
			moveToMap ("Pokecenter Route 10")
		elseif getMapName () == "Pokecenter Route 10" then
			usePokecenter ()
		end
	end
end

function levelOnDiglettsCave ()
	if isPokemonUsable (6) then
		if getMapName () == "Pokecenter Vermilion" then
			moveToMap ("Vermilion City")
		elseif getMapName () == "Vermilion City" then
			moveToMap ("Route 11")
		elseif getMapName () == "Route 11" then
			moveToMap ("Digletts Cave Entrance 2")
		elseif getMapName () == "Digletts Cave Entrance 2" then
			moveToRectangle (15, 26, 25, 27)
		end
	else
		if getMapName () == "Digletts Cave Entrance 2" then
			moveToMap ("Route 11")
		elseif getMapName () == "Route 11" then
			moveToMap ("Vermilion City")
		elseif getMapName () == "Vermilion City" then
			moveToMap ("Pokecenter Vermilion")
		elseif getMapName () == "Pokecenter Vermilion" then
			usePokecenter ()
		end
	end
end

function levelOnRouteThirteen ()
	if isPokemonUsable(6) then
		if getMapName() == "Berry Tower Reception Kanto" then
			moveToMap("Route 13")
		elseif getMapName() == "Route 13" then
			moveToGrass ()
		end
	else
		if getMapName() == "Route 13" then
			moveToMap("Berry Tower Reception Kanto")
		elseif getMapName() == "Berry Tower Reception Kanto" then
			talkToNpcOnCell(4, 12)
		end
	end
end

function learnSomething(pokinr)
--eletric = thunderbolt
--ghost = Shadow Ball/claw
--Fire = Flamethrower
--ground = earthquake
--grass = SolarBeam
--water = Water Gun/Water pulse/Aqua tail
--psychic = Psyshock
--dark = Payday
--flying = razor wing
--poison = sludge bomb
--ice = blizzard/ice beam
--steel = iron head/steel wing
--bug =signal beam/u-turn
--normal = covet/endeavor/hyper beam
--fighting = Brick Break/Submission
--rock = rock slide
--Dragon = dragon claw
local pokeMove1 = tostring(getPokemonMoveName(pokinr,1))
local pokeMove2 = tostring(getPokemonMoveName(pokinr,2))
local pokeMove3 = tostring(getPokemonMoveName(pokinr,3))
local pokeMove4 = tostring(getPokemonMoveName(pokinr,4))

	if getPokemonHealthPercent(pokinr) < 80 or getRemainingPowerPoints(pokinr,pokeMove1) == 0 then
		if stringContains(getMapName(), "Pokecenter") then
			usePokecenter()
		else
		PathFinder.MoveToPC()
		end
	elseif getPokemonHealthPercent(pokinr) == 100 then
		if nrTM == 0 then
			if hasItem("TM13") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM13")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM13", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 1 then
			if hasItem("TM18") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM18")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM18", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 2 then
			if hasItem("TM19") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM19")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM19", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 3 then
			if hasItem("TM22") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM22")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM22", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 4 then
			if hasItem("TM46") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM46")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM46", pokinr)
			else
				nrTM = nrTM + 1
			end
			
		end
		if nrTM == 5 then
			if hasItem("TM64") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM62")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM62", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 6 then
			if hasItem("TM02") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM02")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM02", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 7 then
			if money >= (buyAmount*35000) and getItemQuantity("TM01") == 0 or getItemQuantity("TM02") == 0 or getItemQuantity("TM05") == 0 or getItemQuantity("TM08") == 0 or getItemQuantity("TM09") == 0 or 
				getItemQuantity("TM17") == 0 or getItemQuantity("TM28") == 0 or getItemQuantity("TM39") == 0 or getItemQuantity("TM52") == 0 or getItemQuantity("TM53") == 0 then
					--gobuy = true
					return goBuy()
			elseif money < (buyAmount*35000) then
				log("Not enough money to buy TM's")
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 8 then
			if hasItem("TM01") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM01")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM01", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 9 then
			if hasItem("TM05") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM05")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM05", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 10 then
			if hasItem("TM08") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM08")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM08", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 11 then
			if hasItem("TM09") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM09")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM09", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 12 then
			if hasItem("TM17") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM17")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM17", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 13 then
			if hasItem("TM28") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM28")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM28", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 14 then
			if hasItem("TM39") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM39")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM39", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 15 then
			if hasItem("TM52") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM52")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM52", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 16 then
			if hasItem("TM53") then
				log("Pokemon: " .. pokinr .. " Try Learning: TM53")
				log("nrTM:" .. tostring(nrTM) .. "")
				nrTM = nrTM + 1
				return useItemOnPokemon("TM53", pokinr)
			else
				nrTM = nrTM + 1
			end
		end
		if nrTM == 17 then
			log("!!!!can't learn any moves!!!!")
		end
	else
		fatal("!!!!a weird error happened!!!!")
	end
end

function buyTM()
	if getMapName() == "Celadon City" then
			moveToMap("Celadon Mart 1")
	elseif getMapName() == "Celadon Mart 1" then
			moveToMap("Celadon Mart 2")
	elseif getMapName() == "Celadon Mart 2" then
			moveToMap("Celadon Mart 3")
	elseif getMapName() == "Celadon Mart 3" then
		if not isShopOpen() then
			pushDialogAnswer(1)
			return talkToNpcOnCell(10,10)
		else
			if not hasItem("TM01") then
				log("Buying TM01 x " .. buyAmount)
				return buyItem("TM01", buyAmount)
			elseif not hasItem("TM02") then
				log("Buying TM02 x " .. buyAmount)
				return buyItem("TM02", buyAmount)
			elseif not hasItem("TM05") then
				log("Buying TM05 x " .. buyAmount)
				return buyItem("TM05", buyAmount)
			elseif not hasItem("TM08") then
				log("Buying TM08 x " .. buyAmount)
				return buyItem("TM08", buyAmount)
			elseif not hasItem("TM09") then
				log("Buying TM09 x " .. buyAmount)
				return buyItem("TM09", buyAmount)
			elseif not hasItem("TM17") then
				log("Buying TM17 x " .. buyAmount)
				return buyItem("TM17", buyAmount)
			elseif not hasItem("TM28") then
				log("Buying TM28 x " .. buyAmount)
				return buyItem("TM28", buyAmount)
			elseif not hasItem("TM39") then
				log("Buying TM39 x " .. buyAmount)
				return buyItem("TM39", buyAmount)
			elseif not hasItem("TM52") then
				log("Buying TM52 x " .. buyAmount)
				return buyItem("TM52", buyAmount)
			elseif not hasItem("TM53") then
				log("Buying TM53 x " .. buyAmount)
				return buyItem("TM53", buyAmount)
			else
			 log("Bought everything")
			end
		end
	end
end

local hmMoves = {
	"cut",
	"surf",
	"flash"
}

function chooseForgetMove(moveName, pokemonIndex)
	local ForgetMoveName
	local ForgetMoveTP = 9999
	for moveId=1, 4, 1 do
		local MoveName = getPokemonMoveName(pokemonIndex, moveId)
		if MoveName == nil or MoveName == "cut" or MoveName == "surf" or MoveName == "rock smash" or MoveName == "dive" or MoveName == "sleep powder" or MoveName == "false swipe" then
		else
		local CalcMoveTP = math.modf((getPokemonMaxPowerPoints(pokemonIndex,moveId) * getPokemonMovePower(pokemonIndex,moveId))*(math.abs(getPokemonMoveAccuracy(pokemonIndex,moveId)) / 100))
			if CalcMoveTP < ForgetMoveTP then
				ForgetMoveTP = CalcMoveTP
				ForgetMoveName = MoveName
			end
		end
	end
	log("[Learning Move: " .. moveName .. "  -->  Forget Move: " .. ForgetMoveName .. "]")
	return ForgetMoveName
end

function onLearningMove(moveName, pokemonIndex)
	return forgetMove(chooseForgetMove(moveName, pokemonIndex))
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
 
 function timer(seconds)
    local timerCountdown = os.time()
    if os.difftime(timerCountdown, timerRoot) >= seconds then
        timerRoot = timerRoot + seconds
        timerSwitch = true
    end
end

 function SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

function toInteger(number)
    if number == "" or number == "nil" or number == "nill" then
		return 0
	else
		return number
	end
end