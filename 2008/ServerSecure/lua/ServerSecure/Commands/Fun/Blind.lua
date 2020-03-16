------------------------------------------------
----[ BLIND PLAYER ]------------------
------------------------------------------------

local Blind = SS.Commands:New("Blind")

// Branch flag

SS.Flags.Branch("Fun", "Blind")

// Blind command

function Blind.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		TVAR.New(Person, "Blinded", false)
		
		if (TVAR.Request(Person, "Blinded")) then
			TVAR.Update(Person, "Blinded", false)
			
			SS.PlayerMessage(0, Player:Name().." has unblinded "..Person:Name().."!", 0)
		else
			TVAR.Update(Person, "Blinded", true)
			
			SS.PlayerMessage(0, Player:Name().." has blinded "..Person:Name().."!", 0)
		end
		
		SS.Lib.PlayerBlind(Person, TVAR.Request(Person, "Blinded"))
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Blind:Create(Blind.Command, {"administrator", "fun", "blind"}, "Blind a person", "<Player>", 1, " ")