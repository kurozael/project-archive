--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Storage";
MOUNT.author = "kuromeku";
MOUNT.containers = {};

-- Set some information.
MOUNT.containers["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {8, "Closet"};
MOUNT.containers["models/props_wasteland/controlroom_storagecloset001b.mdl"] = {15, "Closet"};
MOUNT.containers["models/props_wasteland/controlroom_filecabinet001a.mdl"] = {4, "File Cabinet"};
MOUNT.containers["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {8, "File Cabinet"};
MOUNT.containers["models/props_c17/suitcase_passenger_physics.mdl"] = {5, "Suitcase"};
MOUNT.containers["models/props_junk/wood_crate001a_damagedmax.mdl"] = {8, "Wooden Crate"};
MOUNT.containers["models/props_junk/wood_crate001a_damaged.mdl"] = {8, "Wooden Crate"};
MOUNT.containers["models/props_interiors/furniture_desk01a.mdl"] = {4, "Desk"};
MOUNT.containers["models/props_c17/furnituredresser001a.mdl"] = {10, "Dresser"};
MOUNT.containers["models/props_c17/furnituredrawer001a.mdl"] = {8, "Drawer"};
MOUNT.containers["models/props_c17/furnituredrawer002a.mdl"] = {4, "Drawer"};
MOUNT.containers["models/props_c17/furniturefridge001a.mdl"] = {8, "Fridge"};
MOUNT.containers["models/props_c17/furnituredrawer003a.mdl"] = {8, "Drawer"};
MOUNT.containers["models/weapons/w_suitcase_passenger.mdl"] = {5, "Suitcase"};
MOUNT.containers["models/props_junk/trashdumpster01a.mdl"] = {15, "Dumpster"};
MOUNT.containers["models/props_junk/wood_crate001a.mdl"] = {8, "Wooden Crate"};
MOUNT.containers["models/props_junk/wood_crate002a.mdl"] = {10, "Wooden Crate"};
MOUNT.containers["models/items/ammocrate_rockets.mdl"] = {15, "Ammo Crate"};
MOUNT.containers["models/props_lab/filecabinet02.mdl"] = {8, "File Cabinet"};
MOUNT.containers["models/items/ammocrate_grenade.mdl"] = {15, "Ammo Crate"};
MOUNT.containers["models/props_junk/trashbin01a.mdl"] = {10, "Trash Bin"};
MOUNT.containers["models/props_c17/suitcase001a.mdl"] = {8, "Suitcase"};
MOUNT.containers["models/items/item_item_crate.mdl"] = {4, "Item Crate"};
MOUNT.containers["models/props_c17/oildrum001.mdl"] = {8, "Oildrum"};
MOUNT.containers["models/items/ammocrate_smg1.mdl"] = {15, "Ammo Crate"};
MOUNT.containers["models/items/ammocrate_ar2.mdl"] = {15, "Ammo Crate"};

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");