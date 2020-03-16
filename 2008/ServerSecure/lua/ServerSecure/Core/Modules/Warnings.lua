------------------------------------------------
----[ WARNINGS ]-----------------------
------------------------------------------------

SS.Warnings = {} -- Warnings

// Gain warn

function SS.Warnings.Warn(Player, Amount, Reason)
	CVAR.Update(Player, "Warnings", CVAR.Request(Player, "Warnings") + Amount)
	
	local Warnings = CVAR.Request(Player, "Warnings")
	
	if Warnings < SS.Config.Request("Warnings") then
		SS.PlayerMessage(0, Player:Name().." has gained "..Amount.." warnings, "..Warnings.."/"..SS.Config.Request("Warnings").." remain! (Reason: "..Reason..")", 1)
	else
		local Time = SS.Config.Request("Warnings Ban")
		
		SS.PlayerMessage(0, Player:Name().." has been banned for "..Time.." minutes!", 1)
		
		CVAR.Update(Player, "Warnings", 0)
		
		SS.Lib.PlayerBan(Player, Time)
	end
end

// Deduct warning

function SS.Warnings.Deduct(Player, Amount, Reason)
	CVAR.Update(Player, "Warnings", math.max(CVAR.Request(Player, "Warnings") - Amount, 0))
	
	local Warnings = CVAR.Request(Player, "Warnings")
	
	SS.PlayerMessage(0, Player:Name().." has had "..Amount.." warnings deducted "..Warnings.."/"..SS.Config.Request("Warnings").."! (Reason: "..Reason..")", 1)
end

// PlayerSetVariables hook

function SS.Warnings.PlayerSetVariables(Player)
	CVAR.New(Player, "Warnings", "Warnings", 0)
end

// Hook into player set variables

SS.Hooks.Add("SS.Warnings.PlayerSetVariables", "PlayerSetVariables", SS.Warnings.PlayerSetVariables)

// PlayerUpdateGUI hook

function SS.Warnings.PlayerUpdateGUI(Player)
	Player:SetNetworkedString(Player, "Warnings", "Warnings: "..CVAR.Request(Player, "Warnings"))
end

// Hook into player set variables

SS.Hooks.Add("SS.Warnings.PlayerUpdateGUI", "PlayerUpdateGUI", SS.Warnings.PlayerUpdateGUI)