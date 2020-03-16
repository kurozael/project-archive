------------------------------------------------
----[ VOTEMAP ]---------------------------
------------------------------------------------

local VoteMap = SS.Commands:New("VoteMap")

// Map command

function VoteMap.Command(Player, Args)
	local Vote = SS.Voting:New("VoteMap", "Map vote", false)
	
	if not Vote then SS.PlayerMessage(Player, "Vote map already in progress!", 1) return end
	
	local Files = file.Find("../Maps/*.bsp")
	
	for K, V in pairs(Files) do
		V = string.gsub(V, ".bsp", "")
		
		Vote:Words(V)
	end
	
	Vote:Send(30, VoteMap.End)
end

// End map command

function VoteMap.End(Winner, Number, Table)
	if (Winner == "" or Winner == " ") then SS.PlayerMessage(0, "Map vote: No winner!", 0) return end
	
	local Enough, Amount = SS.Lib.VotesNeeded(Number)
	
	if (Enough) then
		SS.PlayerMessage(0, "Changing map to "..Winner.." in 5 seconds!", 0)
		
		timer.Simple(5, game.ConsoleCommand, "changelevel "..Winner.."\n")
	else
		SS.PlayerMessage(0, "Not enough votes for "..Winner..", "..Number.."/"..Amount.."!", 0)
	end
end

VoteMap:Create(VoteMap.Command, {"basic"}, "Start a vote for a map")