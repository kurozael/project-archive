------------------------------------------------
----[ CEXEC ]--------------------------------
------------------------------------------------

local CEXEC = SS.Commands:New("CEXEC")

// Branch flag

SS.Flags.Branch("Administrator", "CEXEC")

// CEXEC command

function CEXEC.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Command = table.concat(Args, " ", 2)
		
		Command = string.Replace(Command, ":", "\"")
		
		Person:ConCommand(Command.."\n")
		
		SS.PlayerMessage(Player, Command.." executed on "..Person:Name().."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

CEXEC:Create(CEXEC.Command, {"administrator", "cexec"}, "Run a command on somebody (Use : to put a quote)", "<Player> <Command>", 2, " ")

// Branch flag

SS.Flags.Branch("Administrator", "CEXECALL")

// CEXECALL command

local CEXECALL = SS.Commands:New("CEXECALL")

function CEXECALL.Command(Player, Args)
	local Command = table.concat(Args, " ")
	
	Command = string.Replace(Command, ":", "\"")
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Error = SS.Player.Immune(Player, V)
		
		if not (Error) then
			V:ConCommand(Command.."\n")
		end
	end
	
	SS.PlayerMessage(Player, Command.." executed on everybody!", 0)
end

CEXECALL:Create(CEXECALL.Command, {"administrator", "cexec"}, "Run a command on everybody (Use @ to put a section in quotes)", "<Command>", 1, " ")