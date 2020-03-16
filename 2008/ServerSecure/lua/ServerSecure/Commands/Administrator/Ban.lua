------------------------------------------------
----[ BAN ]----------------------------------
------------------------------------------------

local Ban = SS.Commands:New("Ban")

// Branch flag

SS.Flags.Branch("Administrator", "Ban")

// Ban command

function Ban.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	local Reason = table.concat(Args, " ", 3)
	
	if (Person) then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Seconds = Args[2] * 60
		
		local Formatted = string.FormattedTime(Seconds)
		
		if (Args[2] > 60) then
			Formatted.h = math.floor(Formatted.h)
			
			Formatted.m = math.Clamp(Formatted.m, 0, 60)
			
			SS.PlayerMessage(0, Person:Name().." banned for "..Formatted.h.." hour(s) and "..Formatted.m.." minute(s) ("..Reason..")!", 0)
		else
			SS.PlayerMessage(0, Person:Name().." banned for "..Args[2].." minute(s) ("..Reason..")!", 0)
		end
		
		SS.Lib.PlayerBan(Person, Args[2], Reason)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Ban:Create(Ban.Command, {"administrator", "ban"}, "Ban a specific player", "<Player> <Time> <Reason>", 3, " ")