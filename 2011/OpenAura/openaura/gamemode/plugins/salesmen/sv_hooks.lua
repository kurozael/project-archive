--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	self:LoadSalesmen();
end;

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SaveSalesmen();
end;

-- Called when a player attempts to use a salesman.
function PLUGIN:PlayerCanUseSalesman(player, entity)
	local numFactions = table.Count(entity.Factions);
	local numClasses = table.Count(entity.Classes);
	local disallowed = nil;
	
	if (numFactions > 0) then
		if ( !entity.Factions[ player:QueryCharacter("faction") ] ) then
			disallowed = true;
		end;
	end;
	
	if (numClasses > 0) then
		if ( !entity.Classes[ _team.GetName( player:Team() ) ] ) then
			disallowed = true;
		end;
	end;
	
	if (disallowed) then
		entity:TalkToPlayer(player, entity.Text.noSale or "I cannot trade my inventory with you!");
		
		return false;
	end;
end;

-- Called when a player uses a salesman.
function PLUGIN:PlayerUseSalesman(player, entity)
	openAura:StartDataStream( player, "Salesmenu", {
		buyInShipments = entity.BuyInShipments,
		priceScale = entity.PriceScale,
		factions = entity.Factions,
		buyRate = entity.BuyRate,
		classes = entity.Classes,
		entity = entity,
		stock = entity.Stock,
		sells = entity.Sells,
		cash = entity.Cash,
		text = entity.Text,
		buys = entity.Buys,
		name = entity:GetSharedVar("name")
	} );
end;