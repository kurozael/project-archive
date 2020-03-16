--[[
Name: "cl_auto.lua".
Product: "blueprint".
--]]

BLUEPRINT:IncludePrefixed("sh_auto.lua");

-- Called each frame.
function ENT:Think()
	local dayAndNight = blueprint.plugin.Get("Day and Night");
	
	if (dayAndNight) then
		dayAndNight:CalculateSkyColor();
	end;
end;