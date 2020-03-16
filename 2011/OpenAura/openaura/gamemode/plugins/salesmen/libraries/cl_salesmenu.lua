--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.salesmenu = {};

-- A function to get whether the salesmenu is open.
function openAura.salesmenu:IsSalesmenuOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) and panel:IsVisible() ) then
		return true;
	end;
end;

-- A function to get whether the items are bought shipments.
function openAura.salesmenu:BuyInShipments()
	return self.buyInShipments;
end;

-- A function to get the salesmenu price scale.
function openAura.salesmenu:GetPriceScale()
	return self.priceScale;
end;

-- A function to get the salesmenu buy rate.
function openAura.salesmenu:GetBuyRate()
	return self.buyRate;
end;

-- A function to get the salesmenu classes.
function openAura.salesmenu:GetClasses()
	return self.classes;
end;

-- A function to get the salesmenu factions.
function openAura.salesmenu:GetFactions()
	return self.factions;
end;

-- A function to get the salesmenu stock.
function openAura.salesmenu:GetStock()
	return self.stock;
end;

-- A function to get the salesmenu cash.
function openAura.salesmenu:GetCash()
	return self.cash;
end;

-- A function to get the salesmenu text.
function openAura.salesmenu:GetText()
	return self.text;
end;

-- A function to get the salesmenu entity.
function openAura.salesmenu:GetEntity()
	return self.entity;
end;

-- A function to get the salesmenu buys.
function openAura.salesmenu:GetBuys()
	return self.buys;
end;

-- A function to get the salesmenu sels.
function openAura.salesmenu:GetSells()
	return self.sells;
end;

-- A function to get the salesmenu panel.
function openAura.salesmenu:GetPanel()
	return self.panel;
end;

-- A function to get the salesmenu name.
function openAura.salesmenu:GetName()
	return self.name;
end;