--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- Whether or not to remove map physics entities.
nexus.config.Add("remove_map_physics", false, nil, nil, nil, nil, true);

MOUNT.removeEntities = {
	"item_healthcharger",
	"item_suitcharger",
	"weapon_*"
};