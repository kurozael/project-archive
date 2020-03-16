--[[
Name: "sh_weapon_smg1.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "SMG";
ITEM.cost = 800;
ITEM.model = "models/weapons/w_smg1.mdl";
ITEM.weight = 2.5;
ITEM.access = "V";
ITEM.uniqueID = "weapon_smg1";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A compact weapon coated in a dark grey, it has a convenient handle.";
ITEM.assembleTime = 2;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.disassembleTime = 2;

-- Register the item.
kuroScript.item.Register(ITEM);