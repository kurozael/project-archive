--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to make a player exit their stance.
function MOUNT:MakePlayerExitStance(player, keepPosition)
	if (player.previousPosition and !keepPosition) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v != player and v:GetPos():Distance(player.previousPosition) <= 32) then
				nexus.player.Notify(player, "Another character is blocking this position!");
				
				return;
			end;
		end;
		
		nexus.player.SetSafePosition(player, player.previousPosition);
	end;
	
	player:SetForcedAnimation(false);
	player.previousPosition = nil;
	player:SetSharedVar( "sh_StancePosition", Vector(0, 0, 0) );
	player:SetSharedVar( "sh_StanceAngles", Angle(0, 0, 0) );
	player:SetSharedVar( "sh_StanceIdle", false );
end;