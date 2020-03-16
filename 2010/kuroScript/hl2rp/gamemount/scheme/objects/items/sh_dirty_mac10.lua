--[[
Name: "sh_dirty_mac10.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Dirty MAC-10";
ITEM.model = "models/weapons/w_smg_mac10.mdl";
ITEM.weight = 2.5;
ITEM.uniqueID = "dirty_mac10";
ITEM.weaponClass = "weapon_mac10";
ITEM.description = "A dirty light grey weapon with something engraved into the side.";
ITEM.assembleTime = 2;
ITEM.disassembleTime = 2;

-- Register the item.
kuroScript.item.Register(ITEM);