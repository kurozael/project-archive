------------------------------------------------
----[ GIMP PLAYER ]---------------------
------------------------------------------------

local Gimp = SS.Commands:New("Gimp")

// Branch flag

SS.Flags.Branch("Fun", "Gimp")

// Tables

Gimp.Phrases = {}

// Phrases

Gimp.Phrases[1] = "A gimp is for life, not just for christmas :)"
Gimp.Phrases[2] = "Baaaaaaaaaaaaaaaaaa!"
Gimp.Phrases[3] = "I am an annoying faggot :D"
Gimp.Phrases[4] = "The Server Administrator owns me :)"

// Gimp command

function Gimp.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		TVAR.New(Person, "Gimped", false)
		
		local Bool = SS.Lib.StringBoolean(Args[2])
		
		TVAR.Update(Person, "Gimped", Bool)
		
		if (Args[2] == 1) then
			SS.PlayerMessage(0, Player:Name().." has gimped "..Person:Name().."!", 0)
		else
			SS.PlayerMessage(0, Player:Name().." has ungimped "..Person:Name().."!", 0)
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

// Player says something

function Gimp.PlayerTypedText(Player, Text)
	if (TVAR.Request(Player, "Gimped")) then
		local Random = SS.Lib.RandomTableEntry(Gimp.Phrases)
		
		Player:SetTextReturn(Random, 5)
	end
end

SS.Hooks.Add("Gimp.PlayerTypedText", "PlayerTypedText", Gimp.PlayerTypedText)

Gimp:Create(Gimp.Command, {"administrator", "fun", "Gimp"}, "Gimp somebody", "<Player> <1-0>", 2, " ")