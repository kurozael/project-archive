--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when the top text is needed.
function MOUNT:GetTopText(topText)
	local beingDragged = g_LocalPlayer:GetSharedVar("sh_BeingDragged");
	
	if (g_LocalPlayer:IsRagdolled() and beingDragged) then
		topText:Add("BEING_DRAGGED", "You are being dragged");
	end;
end;

-- Called when the local player attempts to get up.
function MOUNT:PlayerCanGetUp()
	local beingDragged = g_LocalPlayer:GetSharedVar("sh_BeingDragged");
	
	if (beingDragged) then
		return false;
	end;
end;

timer.Simple(1, function()
	local SWEP = weapons.GetStored("nx_hands");

	if (SWEP) then
		SWEP.Instructions = "Reload: Drop\n"..SWEP.Instructions;
		
		SWEP.Instructions = string.Replace(SWEP.Instructions, "Knock.", "Knock/Pickup.");
		SWEP.Instructions = string.Replace(SWEP.Instructions, "Punch.", "Punch/Throw.");
	end;
end);