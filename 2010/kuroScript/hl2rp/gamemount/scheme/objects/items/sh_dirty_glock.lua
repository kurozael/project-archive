--[[
Name: "sh_dirty_glock.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Dirty Glock";
ITEM.model = "models/weapons/w_pist_glock18.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "dirty_glock";
ITEM.weaponClass = "weapon_glock";
ITEM.description = "A small dirty pistol with something engraved into the side.";

-- Register the item.
kuroScript.item.Register(ITEM);