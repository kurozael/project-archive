--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "alcohol_base";
ITEM.name = "Beer";
ITEM.cost = 5;
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl";
ITEM.weight = 0.6;
ITEM.classes = {CLASS_CATERER};
ITEM.business = true;
ITEM.attributes = {Strength = 10};
ITEM.description = "A glass bottle filled with liquid, it has a funny smell.";

-- Called when a player drinks the item.
function ITEM:OnDrink(player)
	player:SetCharacterData( "thirst", math.Clamp(player:GetCharacterData("thirst") - 75, 0, 100) );
end;

openAura.item:Register(ITEM);