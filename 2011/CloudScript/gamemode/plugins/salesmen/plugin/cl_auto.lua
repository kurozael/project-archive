--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript:HookDataStream("Salesmenu", function(data)
	CloudScript.salesmenu.buyInShipments = data.buyInShipments;
	CloudScript.salesmenu.priceScale = data.priceScale;
	CloudScript.salesmenu.factions = data.factions;
	CloudScript.salesmenu.buyRate = data.buyRate;
	CloudScript.salesmenu.classes = data.classes;
	CloudScript.salesmenu.entity = data.entity;
	CloudScript.salesmenu.sells = data.sells;
	CloudScript.salesmenu.stock = data.stock;
	CloudScript.salesmenu.cash = data.cash;
	CloudScript.salesmenu.text = data.text;
	CloudScript.salesmenu.buys = data.buys;
	CloudScript.salesmenu.name = data.name;
	
	CloudScript.salesmenu.panel = vgui.Create("cloud_Salesmenu");
	CloudScript.salesmenu.panel:Rebuild();
	CloudScript.salesmenu.panel:MakePopup();
end);

usermessage.Hook("cloud_SalesmenuRebuild", function(msg)
	local cash = msg:ReadLong();
	
	if ( CloudScript.salesmenu:IsSalesmenuOpen() ) then
		CloudScript.salesmenu.cash = cash;
		CloudScript.salesmenu.panel:Rebuild();
	end;
end);

usermessage.Hook("cloud_SalesmanAdd", function(msg)
	if ( CloudScript.salesman:IsSalesmanOpen() ) then
		CloseDermaMenus();
		
		CloudScript.salesman.panel:Close();
		CloudScript.salesman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want the salesman's name to be?", "", function(text)
		CloudScript.salesman.name = text;
		
		gui.EnableScreenClicker(true);
		
		CloudScript.salesman.showChatBubble = true;
		CloudScript.salesman.buyInShipments = true;
		CloudScript.salesman.priceScale = 1;
		CloudScript.salesman.physDesc = "";
		CloudScript.salesman.factions = {};
		CloudScript.salesman.buyRate = 100;
		CloudScript.salesman.classes = {};
		CloudScript.salesman.stock = -1;
		CloudScript.salesman.sells = {};
		CloudScript.salesman.model = "";
		CloudScript.salesman.items = {};
		CloudScript.salesman.cash = -1;
		CloudScript.salesman.text = {};
		CloudScript.salesman.buys = {};
		CloudScript.salesman.name = CloudScript.salesman.name;
		
		for k, v in pairs( CloudScript.item:GetAll() ) do
			if (!v.isBaseItem) then
				CloudScript.salesman.items[k] = v;
			end;
		end;
		
		CloudScript.salesman.panel = vgui.Create("cloud_Salesman");
		CloudScript.salesman.panel:Rebuild();
		CloudScript.salesman.panel:MakePopup();
	end);
end);

CloudScript:HookDataStream("SalesmanEdit", function(data)
	if ( CloudScript.salesman:IsSalesmanOpen() ) then
		CloseDermaMenus();
		
		CloudScript.salesman.panel:Close();
		CloudScript.salesman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want to change the salesman's name to?", data.name, function(text)
		CloudScript.salesman.showChatBubble = data.showChatBubble;
		CloudScript.salesman.buyInShipments = data.buyInShipments;
		CloudScript.salesman.priceScale = data.priceScale;
		CloudScript.salesman.factions = data.factions;
		CloudScript.salesman.physDesc = data.physDesc;
		CloudScript.salesman.buyRate = data.buyRate;
		CloudScript.salesman.classes = data.classes;
		CloudScript.salesman.stock = -1;
		CloudScript.salesman.sells = data.sells;
		CloudScript.salesman.model = data.model;
		CloudScript.salesman.items = {};
		CloudScript.salesman.cash = data.cash;
		CloudScript.salesman.text = data.text;
		CloudScript.salesman.buys = data.buys;
		CloudScript.salesman.name = text;
		
		for k, v in pairs( CloudScript.item:GetAll() ) do
			if (!v.isBaseItem) then
				CloudScript.salesman.items[k] = v;
			end;
		end;
		
		gui.EnableScreenClicker(true);
		
		local scrW = ScrW();
		local scrH = ScrH();
		
		CloudScript.salesman.panel = vgui.Create("cloud_Salesman");
		CloudScript.salesman.panel:SetSize(scrW * 0.5, scrH * 0.75);
		CloudScript.salesman.panel:SetPos(
			(scrW / 2) - (CloudScript.salesman.panel:GetWide() / 2),
			(scrH / 2) - (CloudScript.salesman.panel:GetTall() / 2)
		);
		CloudScript.salesman.panel:Rebuild();
		CloudScript.salesman.panel:MakePopup();
	end);
end);