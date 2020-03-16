------------------------------------------------
----[ MUTE A PLAYER ]------------------
------------------------------------------------

local Mute = SS.Commands:New("Mute")

// Branch flag

SS.Flags.Branch("Fun", "Mute")

// Mute command

function Mute.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		TVAR.New(Person, "Muted", false)
		
		local Bool = SS.Lib.StringBoolean(Args[2])
		
		TVAR.Update(Person, "Muted", Bool)
		
		if (Args[2] == 1) then
			SS.PlayerMessage(0, Player:Name().." has muted "..Person:Name().."!", 0)
		else
			SS.PlayerMessage(0, Player:Name().." has unmuted "..Person:Name().."!", 0)
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

// Player says something

function Mute.PlayerTypedText(Player, Text)
	if (TVAR.Request(Player, "Muted")) then
		Player:SetTextReturn("", 5)
	end
end

SS.Hooks.Add("Mute.PlayerTypedText", "PlayerTypedText", Mute.PlayerTypedText)

Mute:Create(Mute.Command, {"administrator", "fun", "mute"}, "Mute somebody", "<Player> <1|0>", 2, " ")