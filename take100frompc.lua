name = "take lvl 100s From PC"
author = "PotatoBlood"

description = [[This will grab the first 6 lvl 100s on your pc]]

local PathFinder = require "Pathfinder/Maps_Pathfind" -- requesting table with methods


function onStart()
end

function onPathAction()
		if stringContains(getMapName(), "Pokecenter") then
			if not isTeamSortedByLevelAscending() then
				sortTeamByLevelAscending()
			elseif getPokemonLevel(1) <= 99 and not highteam then
				if isPCOpen() then
					if isCurrentPCBoxRefreshed() then
						if getCurrentPCBoxSize() ~= 0 then
							for pokemon=1, getCurrentPCBoxSize() do
								if getPokemonLevelFromPC(getCurrentPCBoxId(), pokemon) == 100 then
								return swapPokemonFromPC(getCurrentPCBoxId(),pokemon,1) 	
								end
							end
							return openPCBox(getCurrentPCBoxId()+1)
						else
							highteam = true
							return
						end
					else
						return
					end
				else
					return usePC()
				end
			else
				fatal("oink")
			end
		else
			PathFinder.MoveToPC()
		end
end


function onBattleAction()
	return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
end

function onDialogMessage(message)
	PathFinder.SolveDialog(message, PathFinder) -- this needs to be there
end

function onStop()
	PathFinder.ResetPath()
end