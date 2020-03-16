--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player attempts to NoClip.
function PLUGIN:PlayerNoClip(player)
	openAura.player:RunOpenAuraCommand(player, "Observer");
	
	return false;
end;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	if (!player:InVehicle() and !player:IsRagdolled() and !player:IsBeingHeld()
	and player:Alive() and player:GetMoveType() == MOVETYPE_NOCLIP) then
		local r, g, b, a = player:GetColor();
		
		player:DrawWorldModel(false);
		player:DrawShadow(false);
		player:SetColor(r, g, b, 0);
	elseif (player.observerMode) then
		if (!player.observerResetting) then
			PLUGIN:MakePlayerExitObserverMode(player)
		end;
	end;
end;