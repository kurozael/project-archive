--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:Add("remove_map_physics", false, nil, nil, nil, nil, true);

PLUGIN.removeEntities = {
	"item_healthcharger",
	"item_suitcharger",
	"weapon_*"
};