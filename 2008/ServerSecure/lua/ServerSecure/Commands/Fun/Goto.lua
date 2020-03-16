------------------------------------------------
----[ GOTO PLAYER ]---------------------
------------------------------------------------

local Goto = SS.Commands:New("Goto")

// Branch flag

SS.Flags.Branch("Fun", "Goto")

// Goto command

function Goto.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		Player:SetPos(Person:GetPos())
		
		SS.PlayerMessage(Player, "You have teleported to "..Person:Name().."!", 1)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Goto:Create(Goto.Command, {"administrator", "fun", "goto"}, "Goto somebody", "<Player>", 1, " ")