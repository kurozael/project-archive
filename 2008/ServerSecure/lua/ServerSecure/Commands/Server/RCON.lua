------------------------------------------------
----[ RCON COMMAND ]-----------------
------------------------------------------------

local RCON = SS.Commands:New("RCON")

// Branch flag

SS.Flags.Branch("Server", "RCON")

// RCON command

function RCON.Command(Player, Args)
	Args = table.concat(Args, " ")
	
	game.ConsoleCommand(Args.."\n")
end

RCON:Create(RCON.Command, {"rcon", "server"}, "Run a command on the server", "<Command>", 1, " ")