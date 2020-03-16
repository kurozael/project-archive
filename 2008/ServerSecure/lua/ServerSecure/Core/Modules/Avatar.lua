--------[ AVATAR ]------------

SS.Avatar = {} -- Avatar table

// PlayerUpdateGUI hook

function SS.Avatar.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Avatar", CVAR.Request(Player, "Avatar"))
end

// Hook into player update GUI

SS.Hooks.Add("SS.Avatar.PlayerUpdateGUI", "PlayerUpdateGUI", SS.Avatar.PlayerUpdateGUI)

// PlayerSetVariables

function SS.Avatar.PlayerSetVariables(Player)
	CVAR.New(Player, "Avatar", "Avatar", "http://conna.vs-hs.com/GMA/Images/Avatar.png")
end

// Hook into player set variables

SS.Hooks.Add("SS.Avatar.PlayerSetVariables", "PlayerSetVariables", SS.Avatar.PlayerSetVariables)