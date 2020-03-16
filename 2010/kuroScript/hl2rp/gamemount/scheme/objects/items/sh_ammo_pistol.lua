--[[
Name: "sh_ammo_pistol.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "9mm Pistol Bullets";
ITEM.cost = 25;
ITEM.model = "models/items/boxsrounds.mdl";
ITEM.weight = 1;
ITEM.access = "V";
ITEM.uniqueID = "ammo_pistol";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 20;
ITEM.description = "A container filled with bullets and 9mm printed on the side.";

-- Register the item.
kuroScript.item.Register(ITEM);