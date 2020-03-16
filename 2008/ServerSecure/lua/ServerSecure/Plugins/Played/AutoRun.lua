local Plugin = SS.Plugins:New("Played")

// When players GUI is updated

function Plugin.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Time", string.format("Time Played: %02d:%02d", CVAR.Request(Player, "PlayingHours"), CVAR.Request(Player, "PlayingMinutes")))
end

Plugin:Create()