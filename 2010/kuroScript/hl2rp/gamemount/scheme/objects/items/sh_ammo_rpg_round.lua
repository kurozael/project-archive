
--[[
Name: "sh_ammo_rpg_round.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "ammo_base";
ITEM.name = "RPG Missile";
ITEM.cost = 150;
ITEM.model = "models/weapons/w_missile_launch.mdl";
ITEM.weight = 2;
ITEM.uniqueID = "ammo_rpg_round";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.ammoClass = "rpg_round";
ITEM.ammoAmount = 1;
ITEM.description = "A orange and white colored rocket, what would happen if I dropped this?";

-- Register the item.
kuroScript.item.Register(ITEM);