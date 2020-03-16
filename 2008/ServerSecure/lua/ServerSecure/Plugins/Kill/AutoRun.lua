local Plugin = SS.Plugins:New("Kill")

// When player dies

function Plugin.PlayerDeath(Player, Attacker, Player)
	local Check = Attacker:IsPlayer()
	
	if (Check) then
		if (Attacker != Player) then
			local Error = SS.Player.Immune(Player, Attacker)
			
			if not (Error) then
				SS.Warnings.Warn(Attacker, 1, "This is not deathmatch!")
			end
		end
	end
end

Plugin:Create()