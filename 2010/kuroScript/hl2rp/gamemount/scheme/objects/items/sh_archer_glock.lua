--[[
Name: "sh_archer_glock.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Archer's Glock";
ITEM.model = "models/weapons/w_pist_glock18.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "archer_glock";
ITEM.weaponClass = "weapon_glock";
ITEM.description = "A small pistol with Archer engraved into the side.";

-- Register the item.
kuroScript.item.Register(ITEM);