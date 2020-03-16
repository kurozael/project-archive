------------------------------------------------
----[ SLAY ]----------------------------------
------------------------------------------------

local Slay = SS.Commands:New("Slay")

// Branch flag

SS.Flags.Branch("Fun", "Slay")

// Slay command

function Slay.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		SS.PlayerMessage(0, Player:Name().." has slayed "..Person:Name().."!", 0)
		
		SS.Lib.PlayerSlay(Person)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Slay:Create(Slay.Command, {"slay", "administrator", "fun"}, "Slay a specific person", "<Player>", 1, " ")