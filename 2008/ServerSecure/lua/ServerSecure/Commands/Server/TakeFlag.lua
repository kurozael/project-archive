------------------------------------------------
----[ TAKE FLAG ]-------------------------
------------------------------------------------

local TakeFlag = SS.Commands:New("TakeFlag")

// Branch flag

SS.Flags.Branch("Server", "TakeFlag")

// Take flag command

function TakeFlag.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Flag = SS.Flags.PlayerTake(Person, Args[2])
		
		if not Flag then SS.PlayerMessage(Player, "Player doesn't have flag "..Args[2].."!", 1) return end
		
		SS.PlayerMessage(Player, "You have taken the "..Args[2].." flag from "..Person:Name().."!", 0)
		
		SS.PlayerMessage(Person, "The "..Args[2].." flag was taken from you by "..Player:Name().."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

TakeFlag:Create(TakeFlag.Command, {"takeflag", "server"}, "Take a flag from somebody", "<Player> <Flag>", 2, " ")