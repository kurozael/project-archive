--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.salesman = {};

-- A function to get whether the salesman is open.
function CloudScript.salesman:IsSalesmanOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) and panel:IsVisible() ) then
		return true;
	end;
end;

-- A function to get whether the items are bought shipments.
function CloudScript.salesman:BuyInShipments()
	return self.buyInShipments;
end;

-- A function to get the salesman price scale.
function CloudScript.salesman:GetPriceScale()
	return self.priceScale;
end;

-- A function to get whether the salesman's chat bubble is shown.
function CloudScript.salesman:GetShowChatBubble()
	return self.showChatBubble;
end;

-- A function to get the salesman stock.
function CloudScript.salesman:GetStock()
	return self.stock;
end;

-- A function to get the salesman cash.
function CloudScript.salesman:GetCash()
	return self.cash;
end;

-- A function to get the salesman buy rate.
function CloudScript.salesman:GetBuyRate()
	return self.buyRate;
end;

-- A function to get the salesman classes.
function CloudScript.salesman:GetClasses()
	return self.classes;
end;

-- A function to get the salesman factions.
function CloudScript.salesman:GetFactions()
	return self.factions;
end;

-- A function to get the salesman text.
function CloudScript.salesman:GetText()
	return self.text;
end;

-- A function to get what the salesman sells.
function CloudScript.salesman:GetSells()
	return self.sells;
end;

-- A function to get what the salesman buys.
function CloudScript.salesman:GetBuys()
	return self.buys;
end;

-- A function to get the salesman items.
function CloudScript.salesman:GetItems()
	return self.items;
end;

-- A function to get the salesman panel.
function CloudScript.salesman:GetPanel()
	return self.panel;
end;

-- A function to get the salesman model.
function CloudScript.salesman:GetModel()
	return self.model;
end;

-- A function to get the salesman name.
function CloudScript.salesman:GetName()
	return self.name;
end;