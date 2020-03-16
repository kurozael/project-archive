--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.salesmenu = {};

-- A function to get whether the salesmenu is open.
function CloudScript.salesmenu:IsSalesmenuOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) and panel:IsVisible() ) then
		return true;
	end;
end;

-- A function to get whether the items are bought shipments.
function CloudScript.salesmenu:BuyInShipments()
	return self.buyInShipments;
end;

-- A function to get the salesmenu price scale.
function CloudScript.salesmenu:GetPriceScale()
	return self.priceScale;
end;

-- A function to get the salesmenu buy rate.
function CloudScript.salesmenu:GetBuyRate()
	return self.buyRate;
end;

-- A function to get the salesmenu classes.
function CloudScript.salesmenu:GetClasses()
	return self.classes;
end;

-- A function to get the salesmenu factions.
function CloudScript.salesmenu:GetFactions()
	return self.factions;
end;

-- A function to get the salesmenu stock.
function CloudScript.salesmenu:GetStock()
	return self.stock;
end;

-- A function to get the salesmenu cash.
function CloudScript.salesmenu:GetCash()
	return self.cash;
end;

-- A function to get the salesmenu text.
function CloudScript.salesmenu:GetText()
	return self.text;
end;

-- A function to get the salesmenu entity.
function CloudScript.salesmenu:GetEntity()
	return self.entity;
end;

-- A function to get the salesmenu buys.
function CloudScript.salesmenu:GetBuys()
	return self.buys;
end;

-- A function to get the salesmenu sels.
function CloudScript.salesmenu:GetSells()
	return self.sells;
end;

-- A function to get the salesmenu panel.
function CloudScript.salesmenu:GetPanel()
	return self.panel;
end;

-- A function to get the salesmenu name.
function CloudScript.salesmenu:GetName()
	return self.name;
end;