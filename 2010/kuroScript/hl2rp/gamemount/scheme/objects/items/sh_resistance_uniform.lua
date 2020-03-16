--[[
Name: "sh_resistance_uniform.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "clothes_base";
ITEM.name = "Resistance Uniform";
ITEM.model = "models/bloocobalt/clothes/rebel_kevlar.mdl";
ITEM.cost = 50;
ITEM.group = "group03";
ITEM.weight = 3;
ITEM.access = "m";
ITEM.business = true;
ITEM.protection = 0.1;
ITEM.description = "A resistance uniform with a yellow symbol on the sleeve.";

-- Called when a replacement is needed for a player.
function ITEM:GetReplacement(player)
	if (string.lower( player:GetModel() ) == "models/humans/group01/jasona.mdl") then
		return "models/humans/group03/male_02.mdl";
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);