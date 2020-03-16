local Plugin = SS.Plugins:New("AFK")

// Time

Plugin.Time = 120 -- Time idle to be put into AFK mode

// When players values get set

function Plugin.PlayerSetVariables(Player)
	TVAR.New(Player, "AFK", "")
	
	Plugin.Reset(Player)
end

// AFK

function Plugin.AFK(Player)
	if (Player and Player:IsConnected()) then
		TVAR.Update(Player, "AFK", "AFK")
		
		// Usermessage
		
		umsg.Start("SS.AFK", Player) umsg.Bool(true) umsg.End()
		
		SS.PlayerMessage(Player, "Your status is set to AFK!", 0)
		
		SS.Player.PlayerUpdateGUI(Player)
	end
end

// Reset

function Plugin.Reset(Player)
	if (TVAR.Request(Player, "AFK") == "AFK") then
		umsg.Start("SS.AFK", Player) umsg.Bool(false) umsg.End()
	end
	
	TVAR.Update(Player, "AFK", "")
	
	timer.Create("AFK: "..Player:UniqueID(), Plugin.Time, 1, Plugin.AFK, Player)
end

// When players GUI is updated

function Plugin.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("AFK", TVAR.Request(Player, "afk"))
end

// Chat command

local AFK = SS.Commands:New("AFK")

function AFK.Command(Player, Args)
	Plugin.AFK(Player)
end

AFK:Create(AFK.Command, {"basic"}, "Set your status to AFK")

// Keypress

function Plugin.PlayerKeyPress(Player)
	Plugin.Reset(Player)
	
	SS.Player.PlayerUpdateGUI(Player)
end

// Finish plugin

Plugin:Create()

SS.Adverts.Add("Type "..SS.Commands.Prefix().."AFK if you are going away for a while!")