--[[
Name: "cl_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when the top bars are needed.
function MOUNT:GetTopBars(topBars)
	local oxygen = g_LocalPlayer:GetSharedVar("ks_Oxygen");
	
	-- Check if a statement is true.
	if (!self.oxygen) then
		self.oxygen = oxygen;
	else
		self.oxygen = math.Approach(self.oxygen, oxygen, 1);
	end;
	
	-- Check if a statement is true.
	if (self.oxygen < 90) then
		topBars:Add("+", "OXYGEN", "Oxygen", self.oxygen, 100, self.oxygen < 10);
	end;
end;