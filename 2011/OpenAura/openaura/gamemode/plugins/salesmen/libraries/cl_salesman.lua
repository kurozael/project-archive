--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.salesman = {};

-- A function to get whether the salesman is open.
function openAura.salesman:IsSalesmanOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) and panel:IsVisible() ) then
		return true;
	end;
end;

-- A function to get whether the items are bought shipments.
function openAura.salesman:BuyInShipments()
	return self.buyInShipments;
end;

-- A function to get the salesman price scale.
function openAura.salesman:GetPriceScale()
	return self.priceScale;
end;

-- A function to get whether the salesman's chat bubble is shown.
function openAura.salesman:GetShowChatBubble()
	return self.showChatBubble;
end;

-- A function to get the salesman stock.
function openAura.salesman:GetStock()
	return self.stock;
end;

-- A function to get the salesman cash.
function openAura.salesman:GetCash()
	return self.cash;
end;

-- A function to get the salesman buy rate.
function openAura.salesman:GetBuyRate()
	return self.buyRate;
end;

-- A function to get the salesman classes.
function openAura.salesman:GetClasses()
	return self.classes;
end;

-- A function to get the salesman factions.
function openAura.salesman:GetFactions()
	return self.factions;
end;

-- A function to get the salesman text.
function openAura.salesman:GetText()
	return self.text;
end;

-- A function to get what the salesman sells.
function openAura.salesman:GetSells()
	return self.sells;
end;

-- A function to get what the salesman buys.
function openAura.salesman:GetBuys()
	return self.buys;
end;

-- A function to get the salesman items.
function openAura.salesman:GetItems()
	return self.items;
end;

-- A function to get the salesman panel.
function openAura.salesman:GetPanel()
	return self.panel;
end;

-- A function to get the salesman model.
function openAura.salesman:GetModel()
	return self.model;
end;

-- A function to get the salesman name.
function openAura.salesman:GetName()
	return self.name;
end;