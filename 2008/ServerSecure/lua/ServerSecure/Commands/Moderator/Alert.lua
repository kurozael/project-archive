------------------------------------------------
----[ CREATE AN ALERT ]---------------
------------------------------------------------

local Alert = SS.Commands:New("Alert")

// Branch flag

SS.Flags.Branch("Moderator", "Alert")

// Alert command

function Alert.Command(Player, Args)
	Args = table.concat(Args, " ")
	
	SS.PlayerMessage(0, Player:Name()..": "..Args, 4)
end

Alert:Create(Alert.Command, {"moderator", "alert"}, "Create an alert", "<Message>", 1, " ")