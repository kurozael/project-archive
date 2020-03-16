-----------------------------------------
-----[ PROPSECURE ]---------------
-----------------------------------------

local Plugin = SS.Plugins:New("PropSecure")

// Prop secure command

local Command = SS.Commands:New("PropSecure")

function Command.Command(Player, Args)
	if (PropSecure) then
		Player:ConCommand("PropSecure.Menu\n")
	else
		SS.PlayerMessage(Player, "PropSecure is not installed on this server!", 1)
	end
end

Command:Create(Command.Command, {"basic"}, "View the PropSecure menu")

Plugin:Create()