name = "Catch pokemon from a list at Dragon den"
author = "PotatoBlood"
description = [[Catch pokemon from a list at Dragons Den, uses leftovers, teamsorting and pathfinding]]

catchList = {"Electabuzz", "Charmander", "Abra", "Dratini", "Dragonair", "Snorlax"}
-- Max level - set to 100 to stop at 100, 101 to keep going
maxPokeLevel = 101
--    Please make sure that you have CUT AND SURF
--------------------------------------------------------------
-- Only touch the code below if you know what you are doing --
--------------------------------------------------------------
local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"
local PathFinder = require "Pathfinder/Maps_Pathfind"


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

function onStart()
    pcVisits = 0
    shinyCounter = 0
    wildCounter = 0
	catchCounter = 0
	dragonairCounter = 0
    log("Start botting.")
end

function onPause()
    log("Shinies Caught: " .. shinyCounter)
    log("Pokemons encountered: " .. wildCounter)
	log("Pokemons caught: " .. catchCounter)
	log("Dragonairs caught: " .. dragonairCounter)
    log("You have visited the PokeCenter ".. pcVisits .." times.")
    log("*********************************************************************************************")
end

function onDestination()
	if getMapName() == "Pokecenter Blackthorn" or getMapName() == "Blackthorn City" or getMapName() == "Dragons Den Entrance" or getMapName() == "Dragons Den" or 
	getMapName() == "Blackthorn City Pokemart" then
		return true
	else
		return false
	end
end

function onPathAction()
	if advanceSorting() then
		return true
	end
	if leftovers() then
		return true
	end
	if not isMounted() and hasItem("Bicycle") and isOutside() and not isSurfing() then
		useItem ("Bicycle")
      	log ("Getting on bicycle")
	elseif not onDestination() then
		PathFinder.MoveTo("Blackthorn City")
	else
		farmDragonsDen()
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

function onBattleMessage(message)
	if stringContains(message, "You can not run away!") or sys.stringContains(message, "You failed to run away!") then
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

function farmDragonsDen()
	if isPokemonUsable(4) then
			if getMapName() == "Pokecenter Blackthorn" then
                moveToMap("Blackthorn City")
            elseif getMapName() == "Blackthorn City" then
                    moveToMap("Dragons Den Entrance")
            elseif getMapName() == "Dragons Den Entrance" then
                moveToMap("Dragons Den")
            elseif getMapName() == "Dragons Den" then
                moveToWater()
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

local hmMoves = {
	"cut",
	"surf",
	"flash"
}

function chooseForgetMove(moveName, pokemonIndex) -- Calc the WrostAbility ((Power x PP)*(Accuract/100))
	local ForgetMoveName
	local ForgetMoveTP = 9999
	for moveId=1, 4, 1 do
		local MoveName = getPokemonMoveName(pokemonIndex, moveId)
		if MoveName == nil or MoveName == "cut" or MoveName == "surf" or MoveName == "rock smash" or MoveName == "dive" or (MoveName == "sleep powder" and not hasItem("Plain Badge")) then
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

function onlearningMove(moveName, pokemonIndex)
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