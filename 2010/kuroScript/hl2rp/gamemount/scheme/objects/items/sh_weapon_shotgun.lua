--[[
Name: "sh_weapon_shotgun.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Shotgun";
ITEM.cost = 1200;
ITEM.model = "models/weapons/w_shotgun.mdl";
ITEM.weight = 4;
ITEM.uniqueID = "weapon_shotgun";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.description = "A moderately sized weapon coated in a dull grey.";
ITEM.assembleTime = 3;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.disassembleTime = 3;

-- Register the item.
kuroScript.item.Register(ITEM);