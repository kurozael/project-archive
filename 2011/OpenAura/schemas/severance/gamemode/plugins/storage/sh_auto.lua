--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

PLUGIN.containers = {};
PLUGIN.containers["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {8, "Closet"};
PLUGIN.containers["models/props_wasteland/controlroom_storagecloset001b.mdl"] = {15, "Closet"};
PLUGIN.containers["models/props_wasteland/controlroom_filecabinet001a.mdl"] = {4, "File Cabinet"};
PLUGIN.containers["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {8, "File Cabinet"};
PLUGIN.containers["models/props_c17/suitcase_passenger_physics.mdl"] = {5, "Suitcase"};
PLUGIN.containers["models/props_junk/wood_crate001a_damagedmax.mdl"] = {8, "Wooden Crate"};
PLUGIN.containers["models/props_junk/wood_crate001a_damaged.mdl"] = {8, "Wooden Crate"};
PLUGIN.containers["models/props_interiors/furniture_desk01a.mdl"] = {4, "Desk"};
PLUGIN.containers["models/props_c17/furnituredresser001a.mdl"] = {10, "Dresser"};
PLUGIN.containers["models/props_c17/furnituredrawer001a.mdl"] = {8, "Drawer"};
PLUGIN.containers["models/props_c17/furnituredrawer002a.mdl"] = {4, "Drawer"};
PLUGIN.containers["models/props_c17/furniturefridge001a.mdl"] = {8, "Fridge"};
PLUGIN.containers["models/props_c17/furnituredrawer003a.mdl"] = {8, "Drawer"};
PLUGIN.containers["models/weapons/w_suitcase_passenger.mdl"] = {5, "Suitcase"};
PLUGIN.containers["models/props_junk/trashdumpster01a.mdl"] = {15, "Dumpster"};
PLUGIN.containers["models/props_junk/wood_crate001a.mdl"] = {8, "Wooden Crate"};
PLUGIN.containers["models/props_junk/wood_crate002a.mdl"] = {10, "Wooden Crate"};
PLUGIN.containers["models/items/ammocrate_rockets.mdl"] = {15, "Ammo Crate"};
PLUGIN.containers["models/props_lab/filecabinet02.mdl"] = {8, "File Cabinet"};
PLUGIN.containers["models/items/ammocrate_grenade.mdl"] = {15, "Ammo Crate"};
PLUGIN.containers["models/props_junk/trashbin01a.mdl"] = {10, "Trash Bin"};
PLUGIN.containers["models/props_c17/suitcase001a.mdl"] = {8, "Suitcase"};
PLUGIN.containers["models/items/item_item_crate.mdl"] = {4, "Item Crate"};
PLUGIN.containers["models/props_c17/oildrum001.mdl"] = {8, "Oildrum"};
PLUGIN.containers["models/items/ammocrate_smg1.mdl"] = {15, "Ammo Crate"};
PLUGIN.containers["models/items/ammocrate_ar2.mdl"] = {15, "Ammo Crate"};

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");