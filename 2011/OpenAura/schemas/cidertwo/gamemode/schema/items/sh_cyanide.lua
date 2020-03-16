--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Cyanide";
ITEM.cost = 8;
ITEM.model = "models/props_junk/garbage_plasticbottle002a.mdl";
ITEM.weight = 0.6;
ITEM.classes = {CLASS_MERCHANT};
ITEM.useText = "Drinks";
ITEM.business = true;
ITEM.description = "A bottle of cyanide, warnings are plastered all over it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData( "thirst", math.Clamp(player:GetCharacterData("thirst") - 25, 0, 100) );
	
	local function drinkCyanide(player)
		if ( IsValid(player) and player:Alive() ) then
			player:TakeDamage(500, player, player);
			
			if ( player:Health() > 0 and player:Alive() ) then
				timer.Simple(1, drinkCyanide, player);
			end;
		end;
	end;
	
	timer.Simple(1, drinkCyanide, player);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);