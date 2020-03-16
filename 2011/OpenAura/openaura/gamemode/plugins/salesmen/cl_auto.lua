--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura:HookDataStream("Salesmenu", function(data)
	openAura.salesmenu.buyInShipments = data.buyInShipments;
	openAura.salesmenu.priceScale = data.priceScale;
	openAura.salesmenu.factions = data.factions;
	openAura.salesmenu.buyRate = data.buyRate;
	openAura.salesmenu.classes = data.classes;
	openAura.salesmenu.entity = data.entity;
	openAura.salesmenu.sells = data.sells;
	openAura.salesmenu.stock = data.stock;
	openAura.salesmenu.cash = data.cash;
	openAura.salesmenu.text = data.text;
	openAura.salesmenu.buys = data.buys;
	openAura.salesmenu.name = data.name;
	
	openAura.salesmenu.panel = vgui.Create("aura_Salesmenu");
	openAura.salesmenu.panel:Rebuild();
	openAura.salesmenu.panel:MakePopup();
end);

usermessage.Hook("aura_SalesmenuRebuild", function(msg)
	local cash = msg:ReadLong();
	
	if ( openAura.salesmenu:IsSalesmenuOpen() ) then
		openAura.salesmenu.cash = cash;
		openAura.salesmenu.panel:Rebuild();
	end;
end);

usermessage.Hook("aura_SalesmanAdd", function(msg)
	if ( openAura.salesman:IsSalesmanOpen() ) then
		CloseDermaMenus();
		
		openAura.salesman.panel:Close();
		openAura.salesman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want the salesman's name to be?", "", function(text)
		openAura.salesman.name = text;
		
		gui.EnableScreenClicker(true);
		
		openAura.salesman.showChatBubble = true;
		openAura.salesman.buyInShipments = true;
		openAura.salesman.priceScale = 1;
		openAura.salesman.physDesc = "";
		openAura.salesman.factions = {};
		openAura.salesman.buyRate = 100;
		openAura.salesman.classes = {};
		openAura.salesman.stock = -1;
		openAura.salesman.sells = {};
		openAura.salesman.model = "";
		openAura.salesman.items = {};
		openAura.salesman.cash = -1;
		openAura.salesman.text = {};
		openAura.salesman.buys = {};
		openAura.salesman.name = openAura.salesman.name;
		
		for k, v in pairs( openAura.item:GetAll() ) do
			if (!v.isBaseItem) then
				openAura.salesman.items[k] = v;
			end;
		end;
		
		openAura.salesman.panel = vgui.Create("aura_Salesman");
		openAura.salesman.panel:Rebuild();
		openAura.salesman.panel:MakePopup();
	end);
end);

openAura:HookDataStream("SalesmanEdit", function(data)
	if ( openAura.salesman:IsSalesmanOpen() ) then
		CloseDermaMenus();
		
		openAura.salesman.panel:Close();
		openAura.salesman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want to change the salesman's name to?", data.name, function(text)
		openAura.salesman.showChatBubble = data.showChatBubble;
		openAura.salesman.buyInShipments = data.buyInShipments;
		openAura.salesman.priceScale = data.priceScale;
		openAura.salesman.factions = data.factions;
		openAura.salesman.physDesc = data.physDesc;
		openAura.salesman.buyRate = data.buyRate;
		openAura.salesman.classes = data.classes;
		openAura.salesman.stock = -1;
		openAura.salesman.sells = data.sells;
		openAura.salesman.model = data.model;
		openAura.salesman.items = {};
		openAura.salesman.cash = data.cash;
		openAura.salesman.text = data.text;
		openAura.salesman.buys = data.buys;
		openAura.salesman.name = text;
		
		for k, v in pairs( openAura.item:GetAll() ) do
			if (!v.isBaseItem) then
				openAura.salesman.items[k] = v;
			end;
		end;
		
		gui.EnableScreenClicker(true);
		
		local scrW = ScrW();
		local scrH = ScrH();
		
		openAura.salesman.panel = vgui.Create("aura_Salesman");
		openAura.salesman.panel:SetSize(scrW * 0.5, scrH * 0.75);
		openAura.salesman.panel:SetPos(
			(scrW / 2) - (openAura.salesman.panel:GetWide() / 2),
			(scrH / 2) - (openAura.salesman.panel:GetTall() / 2)
		);
		openAura.salesman.panel:Rebuild();
		openAura.salesman.panel:MakePopup();
	end);
end);