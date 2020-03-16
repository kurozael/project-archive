------------------------------------------------
----[ CRASH ]-------------------------------
------------------------------------------------

local Command = SS.Commands:New("Crash")

// Branch flag

SS.Flags.Branch("Server", "Crash")

// Crash command

function Command.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		Person:SendLua("while true do end")
		
		SS.Lib.PlayerKick(Person, "Crashed by "..Player:Name())
		
		SS.PlayerMessage(Player, Person:Name().." successfully crashed!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Command:Create(Command.Command, {"crash", "server"}, "Crash a specific player's Garry's Mod", "<Player>", 1, " ")