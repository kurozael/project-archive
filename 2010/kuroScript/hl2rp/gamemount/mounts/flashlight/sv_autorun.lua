--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Add some hints.
kuroScript.hint.Add("Battery Item", "Does your flashlight power drain too quickly? Get yourself a battery.");
kuroScript.hint.Add("Flashlight Item", "If it's dark outside and you can't see, invest in a flashlight.");
kuroScript.hint.Add("Flashlight Weapons", "Some weapons have a flashlight built into them.");

-- A function to get whether a player has a flashlight.
function MOUNT:PlayerHasFlashlight(player)
	local weaponClass = kuroScript.player.GetWeaponClass(player);
	
	-- Check if a statement is true.
	if (weaponClass == "ks_flashlight" or weaponClass == "weapon_ar2"
	or weaponClass == "weapon_smg1" or weaponClass == "weapon_shotgun") then
		return true;
	end;
end;