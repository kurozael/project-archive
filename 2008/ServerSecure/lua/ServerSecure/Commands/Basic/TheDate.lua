------------------------------------------------
----[ SHOW THE DATE]-----------------
------------------------------------------------

local Date = SS.Commands:New("TheDate")

// The date

function Date.Command(Player, Args)
	SS.PlayerMessage(Player, "The date is "..os.date("%x")..".", 0)
end

Date:Create(Date.Command, {"basic"}, "View the date")