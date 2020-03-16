------------------------------------------------
----[ UNWARN PLAYER ]----------------
------------------------------------------------

local TakeWarning = SS.Commands:New("TakeWarning")

// Branch flag

SS.Flags.Branch("Administrator", "TakeWarning")

// Take warning command

function TakeWarning.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Warnings = Args[2]
		
		table.remove(Args, 1)
		table.remove(Args, 1)
		
		local Reason = table.concat(Args, " ")
		
		SS.Warnings.Deduct(Person, Warnings, Reason)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

TakeWarning:Create(TakeWarning.Command, {"administrator", "takewarning"}, "Take a warning from somebody", "<Player> <Amount> <Reason>", 3, " ")