------------------------------------------------
----[ VOTEKICK ]--------------------------
------------------------------------------------

local VoteKick = SS.Commands:New("VoteKick")

// Config

VoteKick.Limit  = 60 // Seconds before can votekick again

// Variables

VoteKick.Check  = {} // Leave this
VoteKick.Player = "None" // Leave this

// Kick command

function VoteKick.Command(Player, Args)
	local Cur = CurTime()
	
	if (VoteKick.Check[Player]) then
		if (VoteKick.Check[Player] > Cur) then
			SS.PlayerMessage(Player, "You cannot do another votekick so soon!", 1)
			
			return
		end
	end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Vote = SS.Voting:New("Kick", "Kick "..Person:Name(), false)
		
		if (Vote) then
			VoteKick.Player = Person
			
			Vote:Words("Yes")
			Vote:Words("No")
			
			Vote:Send(20, VoteKick.End)
		else
			SS.PlayerMessage(Player, "Kick vote already in progress!", 1)
		end
		
		VoteKick.Check[Player] = Cur + VoteKick.Limit
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

// End kick command

function VoteKick.End(Winner, Number, Table)
	if (Winner == "" or Winner == " ") then SS.PlayerMessage(0, "Kick Vote: No winner!", 0) return end
	
	if not VoteKick.Player:IsPlayer() then SS.PlayerMessage(0, "Kick Vote: Player no longer connected!", 0) return end
	
	if (Winner == "Yes") then
		SS.PlayerMessage(0, "Kick Vote: "..VoteKick.Player:Name().." vote-kicked!", 0)
		
		game.ConsoleCommand("kickid "..VoteKick.Player:SteamID().." Vote-Kicked\n")
	else
		SS.PlayerMessage(0, "Kick Vote: Not enough votes to kick "..VoteKick.Player:Name(), 0)
	end
end

VoteKick:Create(VoteKick.Command, {"basic"}, "Start a vote to kick a player", "<Player>", 1, " ")

SS.Adverts.Add("You can start a votekick by typing "..SS.Commands.Prefix().."votekick <Name>")