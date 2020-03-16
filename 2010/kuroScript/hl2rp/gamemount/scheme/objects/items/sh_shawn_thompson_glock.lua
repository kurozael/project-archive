--[[
Name: "sh_shawn_thompson_glock.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Shawn Thompson's Glock";
ITEM.model = "models/weapons/w_pist_glock18.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "shawn_thompson_glock";
ITEM.weaponClass = "weapon_glock";
ITEM.description = "A small pistol with Shawn Thompson engraved into the side.";

-- Register the item.
kuroScript.item.Register(ITEM);