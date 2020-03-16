--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called to get whether the local player can see the admin ESP.
function MOUNT:PlayerCanSeeAdminESP()
	if ( !nexus.player.IsNoClipping(g_LocalPlayer) ) then
		return false;
	end;
end;

-- Called when a player attempts to NoClip.
function MOUNT:PlayerNoClip(player)
	return false;
end;