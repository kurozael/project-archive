--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called to get whether the local player can see the admin ESP.
function PLUGIN:PlayerCanSeeAdminESP()
	if ( !CloudScript.player:IsNoClipping(CloudScript.Client) ) then
		return false;
	end;
end;

-- Called when a player attempts to NoClip.
function PLUGIN:PlayerNoClip(player)
	return false;
end;