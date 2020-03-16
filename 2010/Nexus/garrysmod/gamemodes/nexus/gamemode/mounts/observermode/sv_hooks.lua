--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when a player attempts to NoClip.
function MOUNT:PlayerNoClip(player)
	nexus.player.RunNexusCommand(player, "Observer");
	
	return false;
end;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if (!player:InVehicle() and !player:IsRagdolled() and !player:IsBeingHeld()
	and player:Alive() and player:GetMoveType() == MOVETYPE_NOCLIP) then
		local r, g, b, a = player:GetColor();
		
		player:DrawWorldModel(false);
		player:DrawShadow(false);
		player:SetColor(r, g, b, 0);
	elseif (player.observerMode) then
		if (!player.observerResetting) then
			MOUNT:MakePlayerExitObserverMode(player)
		end;
	end;
end;