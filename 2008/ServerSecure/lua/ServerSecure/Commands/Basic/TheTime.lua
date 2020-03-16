------------------------------------------------
----[ SHOW THE TIME ]-----------------
------------------------------------------------

local Time = SS.Commands:New("TheTime")

// The time

function Time.Command(Player, Args)
	SS.PlayerMessage(Player, "The time is "..os.date("%X")..".", 0)
end

Time:Create(Time.Command, {"basic"}, "View the time")