--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local salesmanName = CloudScript.salesman:GetName();
	
	self:SetTitle(salesmanName);
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		self:Close(); self:Remove();
		
		CloudScript:StartDataStream( "SalesmanAdd", {
			showChatBubble = CloudScript.salesman.showChatBubble,
			buyInShipments = CloudScript.salesman.buyInShipments,
			priceScale = CloudScript.salesman.priceScale,
			factions = CloudScript.salesman.factions,
			physDesc = CloudScript.salesman.physDesc,
			buyRate = CloudScript.salesman.buyRate,
			classes = CloudScript.salesman.classes,
			stock = CloudScript.salesman.stock,
			model = CloudScript.salesman.model,
			sells = CloudScript.salesman.sells,
			cash = CloudScript.salesman.cash,
			text = CloudScript.salesman.text,
			buys = CloudScript.salesman.buys,
			name = CloudScript.salesman.name
		} );
		
		CloudScript.salesman.priceScale = nil;
		CloudScript.salesman.factions = nil;
		CloudScript.salesman.classes = nil;
		CloudScript.salesman.physDesc = nil;
		CloudScript.salesman.buyRate = nil;
		CloudScript.salesman.stock = nil;
		CloudScript.salesman.model = nil;
		CloudScript.salesman.sells = nil;
		CloudScript.salesman.buys = nil;
		CloudScript.salesman.items = nil;
		CloudScript.salesman.text = nil;
		CloudScript.salesman.cash = nil;
		CloudScript.salesman.name = nil;
		
		gui.EnableScreenClicker(false);
	end;
	
	self.sellsPanel = vgui.Create("DPanelList");
 	self.sellsPanel:SetPadding(2);
 	self.sellsPanel:SetSpacing(3);
 	self.sellsPanel:SizeToContents();
	self.sellsPanel:EnableVerticalScrollbar();
	
	self.buysPanel = vgui.Create("DPanelList");
 	self.buysPanel:SetPadding(2);
 	self.buysPanel:SetSpacing(3);
 	self.buysPanel:SizeToContents();
	self.buysPanel:EnableVerticalScrollbar();
	
	self.itemsPanel = vgui.Create("DPanelList");
 	self.itemsPanel:SetPadding(2);
 	self.itemsPanel:SetSpacing(3);
 	self.itemsPanel:SizeToContents();
	self.itemsPanel:EnableVerticalScrollbar();
	
	self.settingsPanel = vgui.Create("DPanelList");
 	self.settingsPanel:SetPadding(2);
 	self.settingsPanel:SetSpacing(3);
 	self.settingsPanel:SizeToContents();
	self.settingsPanel:EnableVerticalScrollbar();
	
	self.settingsForm = vgui.Create("DForm");
	self.settingsForm:SetPadding(4);
	self.settingsForm:SetName("Settings");
	self.settingsPanel:AddItem(self.settingsForm);
	
	self.showChatBubble = self.settingsForm:CheckBox("Show chat bubble.");
	self.buyInShipments = self.settingsForm:CheckBox("Buy items in shipments.");
	self.priceScale = self.settingsForm:TextEntry("What amount to scale prices by.");
	self.physDesc = self.settingsForm:TextEntry("The physical description of the salesman.");
	self.buyRate = self.settingsForm:NumSlider("Percentage of price loss from selling.", nil, 1, 100, 0);
	self.stock = self.settingsForm:NumSlider("The default stock of each item (-1 for infinite stock).", nil, -1, 100, 0);
	self.model = self.settingsForm:TextEntry("The model of the salesman.");
	self.cash = self.settingsForm:NumSlider("Starting cash of the salesman (-1 for infinite cash).", nil, -1, 1000000, 0);
	
	self.showChatBubble:SetValue(CloudScript.salesman.showChatBubble == true);
	self.buyInShipments:SetValue(CloudScript.salesman.buyInShipments == true);
	self.priceScale:SetValue(CloudScript.salesman.priceScale);
	self.physDesc:SetValue(CloudScript.salesman.physDesc);
	self.buyRate:SetValue(CloudScript.salesman.buyRate);
	self.stock:SetValue(CloudScript.salesman.stock);
	self.model:SetValue(CloudScript.salesman.model);
	self.cash:SetValue(CloudScript.salesman.cash);
	
	self.responsesForm = vgui.Create("DForm");
	self.responsesForm:SetPadding(4);
	self.responsesForm:SetName("Responses");
	self.settingsForm:AddItem(self.responsesForm);
	
	self.noSaleText = self.responsesForm:TextEntry("When the player cannot trade with them.");
	self.noStockText = self.responsesForm:TextEntry("When the salesman does not have an item in stock.");
	self.needMoreText = self.responsesForm:TextEntry("When the player cannot afford the item.");
	self.cannotAffordText = self.responsesForm:TextEntry("When the salesman cannot afford the item.");
	self.doneBusinessText = self.responsesForm:TextEntry("When the player is done doing trading.");
	
	if (!CloudScript.salesman.text.noSale) then
		self.noSaleText:SetValue("I cannot trade my inventory with you!");
	else
		self.noSaleText:SetValue(CloudScript.salesman.text.noSale);
	end;
	
	if (!CloudScript.salesman.text.noStock) then
		self.noStockText:SetValue("I do not have that item in stock!");
	else
		self.noStockText:SetValue(CloudScript.salesman.text.noStock);
	end;
	
	if (!CloudScript.salesman.text.needMore) then
		self.needMoreText:SetValue("You can't afford to buy that from me!");
	else
		self.needMoreText:SetValue(CloudScript.salesman.text.needMore);
	end;
	
	if (!CloudScript.salesman.text.cannotAfford) then
		self.cannotAffordText:SetValue("I can't afford to buy that item from you!");
	else
		self.cannotAffordText:SetValue(CloudScript.salesman.text.cannotAfford);
	end;
	
	if (!CloudScript.salesman.text.doneBusiness) then
		self.doneBusinessText:SetValue("Thanks for doing business, see you soon!");
	else
		self.doneBusinessText:SetValue(CloudScript.salesman.text.doneBusiness);
	end;
	
	self.factionsForm = vgui.Create("DForm");
	self.factionsForm:SetPadding(4);
	self.factionsForm:SetName("Factions");
	self.settingsForm:AddItem(self.factionsForm);
	self.factionsForm:Help("Leave these unchecked to allow all factions to buy and sell.");
	
	self.classesForm = vgui.Create("DForm");
	self.classesForm:SetPadding(4);
	self.classesForm:SetName("Classes");
	self.settingsForm:AddItem(self.classesForm);
	self.classesForm:Help("Leave these unchecked to allow all classes to buy and sell.");
	
	self.classBoxes = {};
	self.factionBoxes = {};
	
	for k, v in pairs(CloudScript.faction.stored) do
		self.factionBoxes[k] = self.factionsForm:CheckBox(v.name);
		self.factionBoxes[k].OnChange = function(checkBox)
			if ( checkBox:GetChecked() ) then
				CloudScript.salesman.factions[k] = true;
			else
				CloudScript.salesman.factions[k] = nil;
			end;
		end;
		
		if ( CloudScript.salesman.factions[k] ) then
			self.factionBoxes[k]:SetValue(true);
		end;
	end;
	
	for k, v in pairs(CloudScript.class.stored) do
		self.classBoxes[k] = self.classesForm:CheckBox(v.name);
		self.classBoxes[k].OnChange = function(checkBox)
			if ( checkBox:GetChecked() ) then
				CloudScript.salesman.classes[k] = true;
			else
				CloudScript.salesman.classes[k] = nil;
			end;
		end;
		
		if ( CloudScript.salesman.classes[k] ) then
			self.factionBoxes[k]:SetValue(true);
		end;
	end;
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:AddSheet("Sells", self.sellsPanel, "gui/silkicons/box", nil, nil, "View items that "..salesmanName.." sells.");
	self.propertySheet:AddSheet("Buys", self.buysPanel, "gui/silkicons/add", nil, nil, "View items that "..salesmanName.." buys.");
	self.propertySheet:AddSheet("Items", self.itemsPanel, "gui/silkicons/application_view_tile", nil, nil, "View possible items for trading.");
	self.propertySheet:AddSheet("Settings", self.settingsPanel, "gui/silkicons/check_on", nil, nil, "View possible items for trading.");
	
	CloudScript:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panel, typeName, inventory)
	panel:Clear(true);
	panel.typeName = typeName;
	panel.inventory = inventory;
	
	CloudScript.plugin:Call("PlayerSalesmanRebuilding", panel);
	
	local categories = {};
	local items = {};
	
	for k, v in pairs(panel.inventory) do
		local itemTable = CloudScript.item:Get(k);
		
		if (itemTable) then
			local category = itemTable.category;
			
			if (category) then
				items[category] = items[category] or {};
				items[category][#items[category] + 1] = {k, v};
			end;
		end;
	end;
	
	for k, v in pairs(items) do
		categories[#categories + 1] = {
			category = k,
			items = v
		};
	end;
	
	CloudScript.plugin:Call("PlayerSalesmanRebuilt", panel, categories);
	
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local categoryForm = vgui.Create("DForm", panel);
				categoryForm:SetName(v.category);
				categoryForm:SetPadding(4);
			panel:AddItem(categoryForm);
			
			local panelList = vgui.Create("DPanelList", panel);
				panelList:SetAutoSize(true);
				panelList:SetPadding(4);
				panelList:SetSpacing(4);
			categoryForm:AddItem(panelList);
			
			table.sort(v.items, function(a, b)
				return CloudScript.item.stored[ a[1] ].name < CloudScript.item.stored[ b[1] ].name;
			end);
			
			for k2, v2 in pairs(v.items) do
				panel.currentItem = v2[1];
				panelList:AddItem( vgui.Create("cloud_SalesmanItem", panel) );
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel( self.sellsPanel, "Sells",
		CloudScript.salesman:GetSells()
	);
	
	self:RebuildPanel( self.buysPanel, "Buys",
		CloudScript.salesman:GetBuys()
	);
	
	self:RebuildPanel( self.itemsPanel, "Items",
		CloudScript.salesman:GetItems()
	);
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	CloudScript.salesman.text.doneBusiness = self.doneBusinessText:GetValue();
	CloudScript.salesman.text.cannotAfford = self.cannotAffordText:GetValue();
	CloudScript.salesman.text.needMore = self.needMoreText:GetValue();
	CloudScript.salesman.text.noStock = self.noStockText:GetValue();
	CloudScript.salesman.text.noSale = self.noSaleText:GetValue();
	CloudScript.salesman.showChatBubble = (self.showChatBubble:GetChecked() == true);
	CloudScript.salesman.buyInShipments = (self.buyInShipments:GetChecked() == true);
	CloudScript.salesman.physDesc = self.physDesc:GetValue();
	CloudScript.salesman.buyRate = self.buyRate:GetValue();
	CloudScript.salesman.stock = self.stock:GetValue();
	CloudScript.salesman.model = self.model:GetValue();
	CloudScript.salesman.cash = self.cash:GetValue();
	
	local priceScale = self.priceScale:GetValue();
	CloudScript.salesman.priceScale = tonumber(priceScale) or 1;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.propertySheet:StretchToParent(4, 28, 4, 4);
	self.settingsPanel:StretchToParent(0, 0, 0, 0);
	self.sellsPanel:StretchToParent(0, 0, 0, 0);
	self.itemsPanel:StretchToParent(0, 0, 0, 0);
	self.buysPanel:StretchToParent(0, 0, 0, 0);
	
	derma.SkinHook("Layout", "Frame", self);
end;

vgui.Register("cloud_Salesman", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(32, 32);
	
	self.typeName = self:GetParent().typeName;
	self.itemTable = table.Copy( CloudScript.item:Get(self:GetParent().currentItem) );
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "SALESMAN");
	end;

	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = CloudScript:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.itemTable.color);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.itemTable.OnPanelSelected) then
			self.itemTable:OnPanelSelected(self, "SALESMAN");
		end;
		
		if (self.typeName == "Items") then
			if ( self.itemTable.cost == 0 and CloudScript.config:Get("cash_enabled"):Get() ) then
				local cashName = CloudScript.option:GetKey("name_cash");
				
				CloudScript:AddMenuFromData( nil, {
					["Buys"] = function()
						Derma_StringRequest(cashName, "How much do you want the item to be bought for?", "", function(text)
							CloudScript.salesman.buys[self.itemTable.uniqueID] = tonumber(text) or true;
							CloudScript.salesman:GetPanel():Rebuild();
						end);
					end,
					["Sells"] = function()
						Derma_StringRequest(cashName, "How much do you want the item to sell for?", "", function(text)
							CloudScript.salesman.sells[self.itemTable.uniqueID] = tonumber(text) or true;
							CloudScript.salesman:GetPanel():Rebuild();
						end);
					end,
					["Both"] = function()
						Derma_StringRequest(cashName, "How much do you want the item to sell for?", "", function(sellPrice)
							Derma_StringRequest(cashName, "How much do you want the item to be bought for?", "", function(buyPrice)
								CloudScript.salesman.sells[self.itemTable.uniqueID] = tonumber(sellPrice) or true;
								CloudScript.salesman.buys[self.itemTable.uniqueID] = tonumber(buyPrice) or true;
								CloudScript.salesman:GetPanel():Rebuild();
							end);
						end);
					end
				} );
			else
				CloudScript:AddMenuFromData( nil, {
					["Buys"] = function()
						CloudScript.salesman.buys[self.itemTable.uniqueID] = true;
						CloudScript.salesman:GetPanel():Rebuild();
					end,
					["Sells"] = function()
						CloudScript.salesman.sells[self.itemTable.uniqueID] = true;
						CloudScript.salesman:GetPanel():Rebuild();
					end,
					["Both"] = function()
						CloudScript.salesman.sells[self.itemTable.uniqueID] = true;
						CloudScript.salesman.buys[self.itemTable.uniqueID] = true;
						CloudScript.salesman:GetPanel():Rebuild();
					end
				} );
			end;
		elseif (self.typeName == "Sells") then
			CloudScript.salesman.sells[self.itemTable.uniqueID] = nil;
			CloudScript.salesman:GetPanel():Rebuild();
		elseif (self.typeName == "Buys") then
			CloudScript.salesman.buys[self.itemTable.uniqueID] = nil;
			CloudScript.salesman:GetPanel():Rebuild();
		end;
	end;
	
	local model, skin = CloudScript.item:GetIconInfo(self.itemTable);
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	local description = self.itemTable.description;
	local priceScale = 1;
	local toolTip = "";
	local amount = 0;
	
	if (self.typeName == "Sells") then
		if ( CloudScript.salesman:BuyInShipments() ) then
			amount = self.itemTable.batch;
		else
			amount = 1;
		end;
		
		priceScale = CloudScript.salesman:GetPriceScale();
	elseif (self.typeName == "Buys") then
		priceScale = CloudScript.salesman:GetBuyRate() / 100;
	end;
	
	local actualAmount = math.max(amount, 1);
	local cashInfo = "Unset";
	local name = self.itemTable.name;
	
	if (amount > 1) then
		name = amount.." "..self.itemTable.plural;
	elseif (amount == 1) then
		name = amount.." "..name;
	end;
	
	if (self.typeName == "Sells" and CloudScript.salesman.stock != -1) then
		name = "["..CloudScript.salesman.stock.."] "..name;
	end;
	
	if ( CloudScript.config:Get("cash_enabled"):Get() ) then
		if (self.itemTable.cost != 0) then
			cashInfo = FORMAT_CASH( (self.itemTable.cost * priceScale) * actualAmount );
		else
			cashInfo = "Free";
		end;
		
		local overrideCash = CloudScript.salesman.sells[self.itemTable.uniqueID];
		
		if (type(overrideCash) == "number") then
			cashInfo = FORMAT_CASH(overrideCash * actualAmount);
		end;
	else
		cashInfo = "Free";
	end;
	
	if (self.itemTable.OnPanelThink) then
		self.itemTable:OnPanelThink(self, "SALESMAN");
	end;
	
	if (self.itemTable.GetClientSideName) then
		if ( self.itemTable:GetClientSideName() ) then
			name = actualAmount.." "..self.itemTable:GetClientSideName();
		end;
	end;
	
	if (self.itemTable.GetClientSideDescription) then
		if ( self.itemTable:GetClientSideDescription() ) then
			description = self.itemTable:GetClientSideDescription();
		end;
	end;
	
	if (self.itemTable.toolTip) then
		self.spawnIcon:SetToolTip( CloudScript.config:Parse(description).."\n"..CloudScript.config:Parse(self.itemTable.toolTip) );
	else
		self.spawnIcon:SetToolTip( CloudScript.config:Parse(description) );
	end;
	
	self.nameLabel:SetText(name);
	self.nameLabel:SizeToContents();
	self.infoLabel:SetText(cashInfo);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("cloud_SalesmanItem", PANEL, "DPanel");