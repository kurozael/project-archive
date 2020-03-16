--[[
Name: "sh_camo_mp5.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Camouflage MP5";
ITEM.model = "models/weapons/w_smg_mp5.mdl";
ITEM.weight = 2.5;
ITEM.uniqueID = "camo_mp5";
ITEM.weaponClass = "weapon_mp5";
ITEM.description = "A compact weapon with desert camouflage.";
ITEM.assembleTime = 2;
ITEM.disassembleTime = 2;

-- Register the item.
kuroScript.item.Register(ITEM);