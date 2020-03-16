--[[
Name: "sh_golden_crowbar.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "weapon_base";
ITEM.name = "Golden Crowbar";
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.color = Color(200, 200, 0, 255);
ITEM.weight = 1;
ITEM.material = "models/debug/debugwhite";
ITEM.uniqueID = "golden_crowbar";
ITEM.weaponClass = "weapon_crowbar";
ITEM.description = "Your average crowbar, but it is colored gold.";
ITEM.meleeWeapon = true;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);

-- Called when the item is spawned.
function ITEM:OnSpawned(entity)
	entity:SetColor(200, 200, 0, 255);
	entity:SetMaterial("models/shiny");
end;

-- Register the item.
kuroScript.item.Register(ITEM);