--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Whether or not to remove map physics entities.
kuroScript.config.Add("remove_map_physics", false, nil, nil, nil, nil, true);

-- Set some information.
MOUNT.removeEntities = {
	"item_healthcharger",
	"item_suitcharger",
	"weapon_*"
};