------------------------------------------------
----[ KICK ]----------------------------------
------------------------------------------------

local Kick = SS.Commands:New("Kick")

// Branch flag

SS.Flags.Branch("Moderator", "Kick")

// Kick command

function Kick.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	local Reason = table.concat(Args, " ", 2)
	
	if (Person) then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		SS.PlayerMessage(0, Player:Name().." has kicked "..Person:Name().." ("..Reason..")!", 0)
		
		SS.Lib.PlayerKick(Person, Reason)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Kick:Create(Kick.Command, {"moderator", "kick"}, "Kick a specific player", "<Player> <Reason>", 2, " ")