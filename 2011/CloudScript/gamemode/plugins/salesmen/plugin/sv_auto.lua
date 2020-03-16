--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript:HookDataStream("SalesmanDone", function(player, data)
	local entity = data;
	
	if (IsValid(entity) and entity:GetClass() == "cloud_salesman") then
		entity:TalkToPlayer(player, entity.Text.doneBusiness or "Thanks for doing business, see you soon!");
	end;
end);

CloudScript:HookDataStream("Salesmenu", function(player, data)
	local entity = data.entity;
	local uniqueID = data.uniqueID;
	local tradeType = data.tradeType;
	local itemTable = CloudScript.item:Get(uniqueID);
	
	if (itemTable and entity:GetClass() == "cloud_salesman") then
		if (player:GetPos():Distance( entity:GetPos() ) < 196) then
			if ( tradeType == "Sells" and !itemTable.isBaseItem and entity.Sells[itemTable.uniqueID] ) then
				itemTable = table.Copy(itemTable);
				CloudScript.plugin:Call("PlayerAdjustOrderItemTable", player, itemTable);
				
				if (entity.Stock[itemTable.uniqueID] == 0) then
					entity:TalkToPlayer(player, entity.Text.noStock or "I do not have that item in stock!");
					
					return;
				end;
				
				local amount = 1;
				local cost = itemTable.cost;
				
				if (type( entity.Sells[itemTable.uniqueID] ) == "number") then
					cost = entity.Sells[itemTable.uniqueID];
				end;
				
				if (entity.PriceScale) then
					cost = cost * entity.PriceScale;
				end;
				
				if ( CloudScript.plugin:Call("PlayerCanOrderShipment", player, itemTable) ) then
					if (entity.BuyInShipments) then
						amount = itemTable.batch;
					end;
					
					if ( !CloudScript.inventory:CanHoldWeight(player, itemTable.weight * amount) ) then
						CloudScript.player:Notify(player, "You do not have enough inventory space!");
						
						return;
					end;
					
					if ( CloudScript.player:CanAfford(player, cost * amount) ) then
						if (itemTable.CanOrder and itemTable:CanOrder(player, v) == false) then
							return;
						end;
						
						if ( player:UpdateInventory(itemTable.uniqueID, amount) ) then
							if (amount > 1) then
								CloudScript.player:GiveCash(player, -(cost * amount), amount.." "..itemTable.plural);
								CloudScript.player:Notify(player, "You have purchased "..amount.." "..itemTable.plural.." from "..entity:GetSharedVar("name")..".");
								CloudScript:PrintLog(4, player:Name().." has ordered "..amount.." "..itemTable.plural..".");
							else
								CloudScript.player:GiveCash(player, -(cost * amount), amount.." "..itemTable.name);
								CloudScript.player:Notify(player, "You have purchased "..amount.." "..itemTable.name.." from "..entity:GetSharedVar("name")..".");
								CloudScript:PrintLog(4, player:Name().." has ordered "..amount.." "..itemTable.name..".");
							end;
							
							if (itemTable.OnOrder) then
								itemTable:OnOrder(player, entity);
							end;
							
							CloudScript.plugin:Call("PlayerOrderShipment", player, itemTable, entity);
							
							entity.Cash = entity.Cash + cost;
							
							umsg.Start("cloud_SalesmenuRebuild", player);
								umsg.Long(entity.Cash);
							umsg.End();
							
							if ( entity.Stock[itemTable.uniqueID] ) then
								entity.Stock[itemTable.uniqueID] = entity.Stock[itemTable.uniqueID] - 1;
							end;
						end;
					else
						local cashRequired = (cost * amount) - CloudScript.player:GetCash(player);
						
						entity:TalkToPlayer(player, entity.Text.needMore or "You need another "..FORMAT_CASH(cashRequired, nil, true).."!");
					end;
				end;
			elseif ( tradeType == "Buys" and !itemTable.isBaseItem and entity.Buys[itemTable.uniqueID] ) then
				if (CloudScript.plugin:Call("PlayerCanSellItem", entity, itemTable) != false) then
					if ( player:HasItem(itemTable.uniqueID) ) then
						local cost = itemTable.cost;
						
						if (type( entity.Buys[itemTable.uniqueID] ) == "number") then
							cost = entity.Buys[itemTable.uniqueID];
						end;
						
						if (entity.BuyRate) then
							cost = cost * (entity.BuyRate / 100);
						end;
						
						if (entity.Cash == -1 or entity.Cash >= cost) then
							if ( player:UpdateInventory(itemTable.uniqueID, -1) ) then
								if (entity.Cash != -1) then
									entity.Cash = entity.Cash - cost;
								end;
								
								CloudScript.player:GiveCash(player, cost, "1 "..itemTable.name);
								CloudScript.player:Notify(player, "You have sold 1 "..itemTable.name.." to "..entity:GetSharedVar("name")..".");
							end;
						else
							entity:TalkToPlayer(player, entity.Text.cannotAfford or "I can't afford to buy that item from you!");
						end;
						
						umsg.Start("cloud_SalesmenuRebuild", player);
							umsg.Long(entity.Cash);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end);

CloudScript:HookDataStream("SalesmanAdd", function(player, data)
	local PLUGIN = CloudScript.plugin:Get("Salesmen");
	
	if (player.settingUpSalesman) then
		local varTypes = {
			["showChatBubble"] = "boolean",
			["buyInShipments"] = "boolean",
			["priceScale"] = "number",
			["factions"] = "table",
			["physDesc"] = "string",
			["buyRate"] = "number",
			["classes"] = "table",
			["model"] = "string",
			["sells"] = "table",
			["stock"] = "number",
			["text"] = "table",
			["cash"] = "number",
			["buys"] = "table",
			["name"] = "string"
		};
		
		for k, v in pairs(varTypes) do
			if (data[k] == nil or type( data[k] ) != v) then
				return;
			end;
		end;
		
		for k, v in pairs(data.sells) do
			if (type(k) == "string") then
				local itemTable = CloudScript.item:Get(k);
				
				if (itemTable and !itemTable.isBaseItem) then
					if (type(v) == "number") then
						data.sells[k] = v;
					else
						data.sells[k] = true;
					end;
				end;
			end;
		end;
		
		for k, v in pairs(data.buys) do
			if (type(k) == "string") then
				local itemTable = CloudScript.item:Get(k);
				
				if (itemTable and !itemTable.isBaseItem) then
					if (type(v) == "number") then
						data.buys[k] = v;
					else
						data.buys[k] = true;
					end;
				end;
			end;
		end;
		
		local salesman = ents.Create("cloud_salesman");
		local angles = player:GetAngles();
		
		angles.pitch = 0; angles.roll = 0;
		angles.yaw = angles.yaw + 180;
	
		salesman:SetPos(player.salesmanPosition or player.salesmanHitPos);
		salesman:SetAngles(player.salesmanAngles or angles);
		salesman:SetModel(data.model);
		salesman:Spawn();
		
		salesman.Stock = {};
		
		if (data.stock != -1) then
			for k, v in pairs(data.sells) do
				salesman.Stock[k] = data.stock;
			end;
		end;
		
		salesman.Buys = data.buys;
		salesman.Sells = data.sells;
		salesman.Text = data.text;
		salesman.Cash = data.cash;
		salesman.Classes = data.classes;
		salesman.BuyRate = data.buyRate;
		salesman.Factions = data.factions;
		salesman.PriceScale = data.priceScale;
		salesman.BuyInShipments = data.buyInShipments;
		salesman:SetupSalesman(data.name, data.physDesc, player.salesmanAnimation, data.showChatBubble);
		
		CloudScript.entity:MakeSafe(salesman, true, true);
		PLUGIN.salesmen[#PLUGIN.salesmen + 1] = salesman;
	end;
	
	player.salesmanAnimation = nil;
	player.settingUpSalesman = nil;
	player.salesmanPosition = nil;
	player.salesmanAngles = nil;
	player.salesmanHitPos = nil;
end);

-- A function to load the salesmen.
function PLUGIN:LoadSalesmen()
	self.salesmen = CloudScript:RestoreSchemaData( "plugins/salesmen/"..game.GetMap() );
	
	for k, v in pairs(self.salesmen) do
		if (v.buys and v.sells) then
			local salesman = ents.Create("cloud_salesman");
			
			salesman:SetPos(v.position);
			salesman:SetModel(v.model);
			salesman:SetAngles(v.angles);
			salesman:Spawn();
			
			salesman.Buys = v.buys;
			salesman.Sells = v.sells;
			salesman.Text = v.text;
			salesman.Cash = v.cash;
			salesman.Stock = v.stock;
			salesman.Classes = v.classes;
			salesman.BuyRate = v.buyRate;
			salesman.Factions = v.factions;
			salesman.PriceScale = v.priceScale;
			salesman.BuyInShipments = v.buyInShipments;
			salesman:SetupSalesman(v.name, v.physDesc, v.animation, v.showChatBubble);
			
			CloudScript.entity:MakeSafe(salesman, true, true);
			
			self.salesmen[k] = salesman;
		end;
	end;
end;

-- A function to get a salesman table from an entity.
function PLUGIN:GetTableFromEntity(entity)
	return {
		name = entity:GetSharedVar("name"),
		buys = entity.Buys,
		sells = entity.Sells,
		text = entity.Text,
		cash = entity.Cash,
		stock = entity.Stock,
		model = entity:GetModel(),
		angles = entity:GetAngles(),
		buyRate = entity.BuyRate,
		factions = entity.Factions,
		classes = entity.Classes,
		position = entity:GetPos(),
		physDesc = entity:GetSharedVar("physDesc"),
		animation = entity.Animation,
		priceScale = entity.PriceScale,
		buyInShipments = entity.BuyInShipments,
		showChatBubble = IsValid( entity:GetChatBubble() )
	};
end;

-- A function to save the salesmen.
function PLUGIN:SaveSalesmen()
	local salesmen = {};
	
	for k, v in pairs(self.salesmen) do
		if ( IsValid(v) ) then
			salesmen[#salesmen + 1] = self:GetTableFromEntity(v);
		end;
	end;
	
	CloudScript:SaveSchemaData("plugins/salesmen/"..game.GetMap(), salesmen);
end;