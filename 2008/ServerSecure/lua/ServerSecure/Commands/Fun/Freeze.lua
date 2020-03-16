------------------------------------------------
----[ FREEZE PLAYER ]------------------
------------------------------------------------

local Frozen = SS.Commands:New("Freeze")

// Branch flag

SS.Flags.Branch("Fun", "Freeze")

// Freeze command

function Frozen.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Bool = SS.Lib.StringBoolean(Args[2])
		
		if (Bool) then
			SS.PlayerMessage(0, Player:Name().." has frozen "..Person:Name().."!", 0)
		else
			SS.PlayerMessage(0, Player:Name().." has unfrozen "..Person:Name().."!", 0)
		end
		
		SS.Lib.PlayerFreeze(Person, Bool)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Frozen:Create(Frozen.Command, {"administrator", "fun", "freeze"}, "Freeze somebody", "<Player> <1|0>", 2, " ")