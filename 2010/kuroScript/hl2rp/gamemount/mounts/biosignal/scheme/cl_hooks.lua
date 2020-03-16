--[[
Name: "sv_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when a player attempts to see the owner of an entity.
function MOUNT:PlayerCanSeeOwner(entity, owner, class)
	if ( kuroScript.game:PlayerIsCombine(g_LocalPlayer) ) then
		if ( owner:GetSharedVar("ks_Biosignal") ) then
			return true;
		end;
	end;
end;