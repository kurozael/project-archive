--[[
Name: "sh_ricardo_smg1.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Ricardo's SMG";
ITEM.model = "models/weapons/w_smg1.mdl";
ITEM.weight = 2.5;
ITEM.uniqueID = "ricardo_smg1";
ITEM.weaponClass = "weapon_smg1";
ITEM.description = "A compact weapon with Ricardo engraved into the side.";
ITEM.assembleTime = 1;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.disassembleTime = 1;

-- Register the item.
kuroScript.item.Register(ITEM);