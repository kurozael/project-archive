--[[
Name: "sh_weapon_rpg.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "RPG";
ITEM.cost = 2500;
ITEM.model = "models/weapons/w_rocket_launcher.mdl";
ITEM.weight = 6;
ITEM.uniqueID = "weapon_rpg";
ITEM.business = true;
ITEM.vocations = {VOC_OTA_EOW, VOC_OTA_OWC};
ITEM.description = "A large green weapon, you'd better hope it doesn't backfire.";
ITEM.assembleTime = 6;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.disassembleTime = 6;

-- Register the item.
kuroScript.item.Register(ITEM);