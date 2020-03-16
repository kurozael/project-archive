------------------------------------------------
----[ EQUIP ]-------------------------------
------------------------------------------------

local Equip = SS.Commands:New("Equip")

// Branch flag

SS.Flags.Branch("Fun", "Equip")

// Equip command

function Equip.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		Person:Give(Args[2])
		
		SS.PlayerMessage(Player, "You gave "..Person:Name().." "..Args[2].."!", 0)
		
		if (Person == Player) then return end
		
		SS.PlayerMessage(Player, "You were given "..Args[2].." by "..Player:Name().."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Equip:Create(Equip.Command, {"administrator", "fun", "equip"}, "Equip a player", "<Player> <Item>", 2, " ")