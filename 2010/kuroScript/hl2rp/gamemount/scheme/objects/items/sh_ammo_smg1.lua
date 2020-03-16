--[[
Name: "sh_ammo_smg1.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "SMG Bullets";
ITEM.cost = 50;
ITEM.model = "models/items/boxmrounds.mdl";
ITEM.weight = 2;
ITEM.access = "V";
ITEM.uniqueID = "ammo_smg1";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.ammoClass = "smg1";
ITEM.ammoAmount = 30;
ITEM.description = "A heavy container filled with a lot of bullets.";

-- Register the item.
kuroScript.item.Register(ITEM);