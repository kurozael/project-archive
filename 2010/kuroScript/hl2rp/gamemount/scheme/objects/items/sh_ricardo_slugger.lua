--[[
Name: "sh_ricardo_slugger.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Ricardo's Slugger";
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ricardo_slugger";
ITEM.weaponClass = "weapon_crowbar";
ITEM.description = "Your average crowbar, but with Ricardo engraved into the side.";
ITEM.meleeWeapon = true;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);

-- Register the item.
kuroScript.item.Register(ITEM);