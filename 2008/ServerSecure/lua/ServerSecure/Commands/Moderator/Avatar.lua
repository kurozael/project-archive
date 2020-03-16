------------------------------------------------
----[ AVATAR COMMAND ]-------------
------------------------------------------------

local Avatar = SS.Commands:New("Avatar")

// Branch flag

SS.Flags.Branch("Moderator", "Avatar")

// Avatar command

function Avatar.Command(Player, Args)
	Args = table.concat(Args, " ")
	
	CVAR.Update(Player, "Avatar", Args)
	
	SS.PlayerMessage(Player, "Avatar URL set to "..Args.."!", 0)
end

Avatar:Create(Avatar.Command, {"moderator", "Avatar"}, "Set your avatar URL", "<URL>", 1, " ")