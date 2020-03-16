------------------------------------------------
----[ COMMANDS ]------------------------
------------------------------------------------

local Commands = SS.Commands:New("Commands")

// Commands command

function Commands.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Commands")
	
	for K, V in pairs(SS.Commands.List) do
		if (SS.Flags.PlayerHas(Player, V.Restrict)) then
			Panel:Button(SS.Commands.Prefix()..K, 'ss commandscommand "'..K..'"')
		end
	end
	
	Panel:Send()
end

// View command

function Commands.View(Player, Args)
	for K, V in pairs(SS.Commands.List) do
		if (K == Args[1]) then
			local Panel = SS.Panel:New(Player, SS.Commands.Prefix()..K)
			
			Panel:Words("Help: "..V.Help)
			Panel:Words("Syntax: "..V.Syntax)
			
			Panel:Send()
			
			return
		end
	end
	
	SS.PlayerMessage(Player, "No command found: '"..Args[1].."'", 1)
end

SS.ConsoleCommand.Simple("commandscommand", Commands.View, 1)

Commands:Create(Commands.Command, {"basic"}, "View commands you can do")

SS.Adverts.Add("Type "..SS.Commands.Prefix().."commands to see what commands you can do")