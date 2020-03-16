------------------------------------------------
----[ GRAVITY ]----------------------------
------------------------------------------------

local Gravity = SS.Commands:New("Gravity")

// Branch flag

SS.Flags.Branch("Fun", "Gravity")

function Gravity.Command(Player, Args)
	local Gravity = 0.01 * Args[2]
	
	Gravity = math.Clamp(Gravity, 0.1, 1)
	
	local Trace = Player:TraceLine()
	
	if not (Trace.Entity) then SS.PlayerMessage(Player, "You need to aim at a valid entity!", 1) return end
	
	Trace.Entity:SetGravity(Gravity)
	
	SS.PlayerMessage(Player, "Entities gravity set to "..Args[2].."%!", 0)
end

Gravity:Create(Gravity.Command, {"administrator", "fun", "gravity"}, "Set gravity of targeted entity", "<Percent>", 1, " ")