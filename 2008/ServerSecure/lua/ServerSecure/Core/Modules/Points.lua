--------[ POINTS ]------------

SS.Points = {} -- Points table

// Gain points

function SS.Points.Gain(Player, Amount)
	CVAR.Update(Player, "Points", CVAR.Request(Player, "Points") + Amount)

	SS.Hooks.Run("PlayerGivenPoints", Player, Amount)
end

// Deduct points

function SS.Points.Deduct(Player, Amount)
	CVAR.Update(Player, "Points", CVAR.Request(Player, "Points") - Amount)
	
	SS.Hooks.Run("PlayerTakenPoints", Player, Amount)
end

// PlayerUpdateGUI hook

function SS.Points.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Points", SS.Config.Request("Points")..": "..CVAR.Request(Player, "Points"))
	Player:SetNetworkedString("Timer", SS.Config.Request("Points").." Timer: "..CVAR.Request(Player, "Timer"))
end

// Hook into player update GUI

SS.Hooks.Add("SS.Points.PlayerUpdateGUI", "PlayerUpdateGUI", SS.Points.PlayerUpdateGUI)

// PlayerSetVariables

function SS.Points.PlayerSetVariables(Player)
	CVAR.New(Player, "Points", function() return SS.Config.Request("Points") end, 0)
	CVAR.New(Player, "Timer", function() return SS.Config.Request("Points").." Timer" end, SS.Config.Request("Points Timer"))
end

// Hook into player set variables

SS.Hooks.Add("SS.Points.PlayerSetVariables", "PlayerSetVariables", SS.Points.PlayerSetVariables)

// ServerMinute hook

function SS.Points.Minute()
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Ready = V:IsReady()
		
		if (Ready) then
			CVAR.Update(V, "Timer", CVAR.Request(V, "Timer") - 1)
			
			if CVAR.Request(V, "Timer") <= 0 then
				CVAR.Update(V, "Timer", SS.Config.Request("Points Timer"))
				
				local Message = SS.Config.Request("Points Message")
				
				local Amount = tostring(SS.Config.Request("Points Given"))
				
				Message = string.Replace(Message, "%N", SS.Config.Request("Points"))
				
				Message = string.Replace(Message, "%A", Amount)
				
				SS.PlayerMessage(V, Message, 0)
				
				SS.Points.Gain(V, SS.Config.Request("Points Given"))
			end
			
			CVAR.Save(V)
		end
	end
end

// Hook into ServerMinute

SS.Hooks.Add("SS.Points.Minute", "ServerMinute", SS.Points.Minute)