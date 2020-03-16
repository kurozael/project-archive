--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the top text is needed.
function PLUGIN:GetTopText(topText)
	local beingDragged = CloudScript.Client:GetSharedVar("beingDragged");
	
	if (CloudScript.Client:IsRagdolled() and beingDragged) then
		topText:Add("BEING_DRAGGED", "You are being dragged");
	end;
end;

-- Called when the local player attempts to get up.
function PLUGIN:PlayerCanGetUp()
	local beingDragged = CloudScript.Client:GetSharedVar("beingDragged");
	
	if (beingDragged) then
		return false;
	end;
end;

timer.Simple(1, function()
	local SWEP = weapons.GetStored("cloud_hands");

	if (SWEP) then
		SWEP.Instructions = "Reload: Drop\n"..SWEP.Instructions;
		
		SWEP.Instructions = CloudScript:Replace(SWEP.Instructions, "Knock.", "Knock/Pickup.");
		SWEP.Instructions = CloudScript:Replace(SWEP.Instructions, "Punch.", "Punch/Throw.");
	end;
end);