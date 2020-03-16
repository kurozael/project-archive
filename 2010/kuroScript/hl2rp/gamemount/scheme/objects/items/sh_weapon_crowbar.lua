--[[
Name: "sh_weapon_crowbar.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Crowbar";
ITEM.cost = 75;
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.weight = 1;
ITEM.access = "V";
ITEM.uniqueID = "weapon_crowbar";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.description = "Your average crowbar, good for cracking a few skulls.";
ITEM.meleeWeapon = true;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);

-- Register the item.
kuroScript.item.Register(ITEM);