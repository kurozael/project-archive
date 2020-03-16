--[[
Name: "sh_flashlight.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Flashlight";
ITEM.cost = 30;
ITEM.model = "models/props_c17/light_cagelight02_on.mdl";
ITEM.weight = 0.8;
ITEM.access = "i1";
ITEM.category = "Perpetuities"
ITEM.uniqueID = "ks_flashlight";
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.meleeWeapon = true;
ITEM.description = "A ceiling light, a button has been wired on to it.";
ITEM.canUseAmmoless = true;

-- Register the item.
kuroScript.item.Register(ITEM);