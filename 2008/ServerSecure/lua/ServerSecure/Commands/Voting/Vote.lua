------------------------------------------------
----[ VOTE ]---------------------------------
------------------------------------------------

local Vote = SS.Commands:New("Vote")

// Votes allowed

Vote.Allowed = {
	"sbox_",
}

// Acceptable vote

function Vote.Acceptable(Command)
	if (string.find(Command, ";")) then
		return false
	end
	
	for K, V in pairs(Vote.Allowed) do
		if string.find(string.lower(Command), string.lower(V)) then
			return true
		end
	end
	
	return false
end

// Vote command

function Vote.Command(Player, Args)
	if not Vote.Acceptable(Args[1]) then
		SS.PlayerMessage(Player, "That command is not acceptable!", 1)
		
		return
	end
	
	local Command = Args[1]
	
	table.remove(Args, 1)
	
	local Value = table.concat(Args, " ")
	
	if (string.find(Value, ";")) then
		SS.PlayerMessage(Player, "That command is not acceptable!", 1)
		
		return
	end
	
	local Panel = SS.Voting:New("Vote", Command..": "..Value, false)
	
	if not Panel then SS.PlayerMessage(Player, "A CVAR vote is already in progress!", 1) return end
	
	Vote.Command = Command
	Vote.Value = Value
	
	Panel:Words("Yes")
	Panel:Words("No")
	
	Panel:Send(20, Vote.Callback)
	
	SS.PlayerMessage(Player, Player:Name().." started a vote for "..Command.." "..Value.."!", 0)
end

// Callback command

function Vote.Callback(Winner, Number, Table)
	if (Winner == "" or Winner == " ") then SS.PlayerMessage(0, "CVAR Vote: No winner!", 0) return end
	
	if Winner == "Yes" then
		SS.PlayerMessage(0, "CVAR Vote: "..Vote.Command.." changed to "..Vote.Value.."!", 0)
		
		SS.Lib.ConCommand(Vote.Command, Vote.Value)
	else
		SS.PlayerMessage(0, "CVAR Vote: Not enough votes to change "..Vote.Command.." to "..Vote.Value.."!", 0)
	end
end

Vote:Create(Vote.Command, {"basic"}, "Vote for a console variable", "<Command> <Value>", 1, " ")