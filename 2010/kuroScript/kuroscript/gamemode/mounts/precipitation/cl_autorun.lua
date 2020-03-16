--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Add some settings.
kuroScript.setting.AddCheckBox("kuroScript", "Rain Effects", "ks_raineffects", "Whether or not to render the rain effects.");

-- A function to calculate the map height.
function MOUNT:CalculateMapHeight(position)
	local position = position or ( g_LocalPlayer:EyePos() + Vector(0, 0, 64) );
	local trace = util.TraceLine( {
		endpos = position + Vector(0, 0, 32768),
		start = position,
		mask = MASK_NPCWORLDSTATIC
	} );
	
	-- Check if a statement is true.
	if (trace.HitSky) then
		return trace.HitPos.z - 256;
	else
		return trace.HitPos.z + 512;
	end;
end;