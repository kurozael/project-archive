------------------------------------------------
----[ WARN PLAYER ]---------------------
------------------------------------------------

local GiveWarning = SS.Commands:New("GiveWarning")

// Branch flag

SS.Flags.Branch("Administrator", "GiveWarning")

// Give warning command

function GiveWarning.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Warnings = Args[2]
		
		if not Warnings or Warnings <= 0 then SS.PlayerMessage(Player, "Amount too small!", 1) return end
		
		local Reason = table.concat(Args, " ", 3)
		
		SS.Warnings.Warn(Person, Warnings, Reason)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

GiveWarning:Create(GiveWarning.Command, {"administrator", "givewarning"}, "Give somebody a warning", "<Player> <Amount> <Reason>", 3, " ")