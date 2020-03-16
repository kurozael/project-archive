--[[
Name: "cl_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when the top text is needed.
function MOUNT:GetTopText(topText)
	local beingDragged = g_LocalPlayer:GetSharedVar("ks_BeingDragged");
	
	-- Check if a statement is true.
	if (g_LocalPlayer:IsRagdolled() and beingDragged) then
		topText:Add("BEING_DRAGGED", "-", "You are being dragged");
	end;
end;

-- Called when the local player attempts to get up.
function MOUNT:PlayerCanGetUp()
	local beingDragged = g_LocalPlayer:GetSharedVar("ks_BeingDragged");
	
	-- Check if a statement is true.
	if (beingDragged) then
		return false;
	end;
end;

-- Set some information.
timer.Simple(1, function()
	local SWEP = weapons.GetStored("ks_hands");

	-- Check if a statement is true.
	if (SWEP) then
		SWEP.Instructions = "Reload: Drop\n"..SWEP.Instructions;
		
		-- Set some information.
		SWEP.Instructions = string.Replace(SWEP.Instructions, "Knock.", "Knock/Pickup.");
		SWEP.Instructions = string.Replace(SWEP.Instructions, "Punch.", "Punch/Throw.");
	end;
end);