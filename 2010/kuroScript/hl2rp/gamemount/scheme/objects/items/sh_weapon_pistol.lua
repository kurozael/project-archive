--[[
Name: "sh_weapon_pistol.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "9mm Pistol";
ITEM.cost = 450;
ITEM.model = "models/weapons/w_pistol.mdl";
ITEM.weight = 1.5;
ITEM.access = "V";
ITEM.uniqueID = "weapon_pistol";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A small pistol coated in a dull grey.";
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);

-- Register the item.
kuroScript.item.Register(ITEM);