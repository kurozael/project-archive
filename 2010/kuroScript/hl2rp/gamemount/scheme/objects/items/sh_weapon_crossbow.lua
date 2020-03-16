--[[
Name: "sh_weapon_crossbow.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Crossbow";
ITEM.cost = 1250;
ITEM.model = "models/weapons/w_crossbow.mdl";
ITEM.weight = 5;
ITEM.uniqueID = "weapon_crossbow";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.description = "A weapon constructed from various scrap materials.";
ITEM.assembleTime = 5;
ITEM.disassembleTime = 5;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);

-- Register the item.
kuroScript.item.Register(ITEM);