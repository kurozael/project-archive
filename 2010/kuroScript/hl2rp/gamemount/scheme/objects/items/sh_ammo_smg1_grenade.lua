
--[[
Name: "sh_ammo_smg1_grenade.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "SMG Grenade";
ITEM.cost = 125;
ITEM.model = "models/items/ar2_grenade.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_smg1_grenade";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "smg1_grenade";
ITEM.ammoAmount = 1;
ITEM.description = "A large bullet shaped item, you'll figure it out.";

-- Register the item.
kuroScript.item.Register(ITEM);