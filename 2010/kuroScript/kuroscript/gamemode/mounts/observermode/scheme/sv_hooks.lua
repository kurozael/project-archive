--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player attempts to NoClip.
function MOUNT:PlayerNoClip(player)
	kuroScript.player.RunKuroScriptCommand(player, "observer");
	
	-- Return false to break the function.
	return false;
end;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if (!player:InVehicle() and !player:IsRagdolled() and !player:IsBeingHeld()
	and player:Alive() and player:GetMoveType() == MOVETYPE_NOCLIP) then
		local r, g, b, a = player:GetColor();
		
		-- Set some information.
		player:DrawWorldModel(false);
		player:DrawShadow(false);
		player:SetColor(r, g, b, 0);
	elseif (player._ObserverMode) then
		MOUNT:MakePlayerExitObserverMode(player)
		
		-- Set some information.
		player:DrawWorldModel(true);
		player:DrawShadow(true);
	end;
end;