--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "alcohol_base";
ITEM.name = "Whiskey";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.weight = 1.2;
ITEM.classes = {CLASS_CATERER};
ITEM.business = true;
ITEM.attributes = {Stamina = 10};
ITEM.description = "A brown colored whiskey bottle, be careful!";

-- Called when a player drinks the item.
function ITEM:OnDrink(player)
	player:SetCharacterData( "thirst", math.Clamp(player:GetCharacterData("thirst") - 75, 0, 100) );
end;

openAura.item:Register(ITEM);