--[[
Name: "sh_weapon_ar2.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Pulse-Rifle";
ITEM.cost = 1000;
ITEM.model = "models/weapons/w_irifle.mdl";
ITEM.weight = 4;
ITEM.uniqueID = "weapon_ar2";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.description = "A weapon which does not seem to have been crafted on Earth.";
ITEM.assembleTime = 4;
ITEM.disassembleTime = 4;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);

-- Register the item.
kuroScript.item.Register(ITEM);