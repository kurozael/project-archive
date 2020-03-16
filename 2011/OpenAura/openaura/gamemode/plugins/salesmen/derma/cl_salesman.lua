--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local salesmanName = openAura.salesman:GetName();
	
	self:SetTitle(salesmanName);
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		self:Close(); self:Remove();
		
		openAura:StartDataStream( "SalesmanAdd", {
			showChatBubble = openAura.salesman.showChatBubble,
			buyInShipments = openAura.salesman.buyInShipments,
			priceScale = openAura.salesman.priceScale,
			factions = openAura.salesman.factions,
			physDesc = openAura.salesman.physDesc,
			buyRate = openAura.salesman.buyRate,
			classes = openAura.salesman.classes,
			stock = openAura.salesman.stock,
			model = openAura.salesman.model,
			sells = openAura.salesman.sells,
			cash = openAura.salesman.cash,
			text = openAura.salesman.text,
			buys = openAura.salesman.buys,
			name = openAura.salesman.name
		} );
		
		openAura.salesman.priceScale = nil;
		openAura.salesman.factions = nil;
		openAura.salesman.classes = nil;
		openAura.salesman.physDesc = nil;
		openAura.salesman.buyRate = nil;
		openAura.salesman.stock = nil;
		openAura.salesman.model = nil;
		openAura.salesman.sells = nil;
		openAura.salesman.buys = nil;
		openAura.salesman.items = nil;
		openAura.salesman.text = nil;
		openAura.salesman.cash = nil;
		openAura.salesman.name = nil;
		
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
	
	self.showChatBubble:SetValue(openAura.salesman.showChatBubble == true);
	self.buyInShipments:SetValue(openAura.salesman.buyInShipments == true);
	self.priceScale:SetValue(openAura.salesman.priceScale);
	self.physDesc:SetValue(openAura.salesman.physDesc);
	self.buyRate:SetValue(openAura.salesman.buyRate);
	self.stock:SetValue(openAura.salesman.stock);
	self.model:SetValue(openAura.salesman.model);
	self.cash:SetValue(openAura.salesman.cash);
	
	self.responsesForm = vgui.Create("DForm");
	self.responsesForm:SetPadding(4);
	self.responsesForm:SetName("Responses");
	self.settingsForm:AddItem(self.responsesForm);
	
	self.noSaleText = self.responsesForm:TextEntry("When the player cannot trade with them.");
	self.noStockText = self.responsesForm:TextEntry("When the salesman does not have an item in stock.");
	self.needMoreText = self.responsesForm:TextEntry("When the player cannot afford the item.");
	self.cannotAffordText = self.responsesForm:TextEntry("When the salesman cannot afford the item.");
	self.doneBusinessText = self.responsesForm:TextEntry("When the player is done doing trading.");
	
	if (!openAura.salesman.text.noSale) then
		self.noSaleText:SetValue("I cannot trade my inventory with you!");
	else
		self.noSaleText:SetValue(openAura.salesman.text.noSale);
	end;
	
	if (!openAura.salesman.text.noStock) then
		self.noStockText:SetValue("I do not have that item in stock!");
	else
		self.noStockText:SetValue(openAura.salesman.text.noStock);
	end;
	
	if (!openAura.salesman.text.needMore) then
		self.needMoreText:SetValue("You can't afford to buy that from me!");
	else
		self.needMoreText:SetValue(openAura.salesman.text.needMore);
	end;
	
	if (!openAura.salesman.text.cannotAfford) then
		self.cannotAffordText:SetValue("I can't afford to buy that item from you!");
	else
		self.cannotAffordText:SetValue(openAura.salesman.text.cannotAfford);
	end;
	
	if (!openAura.salesman.text.doneBusiness) then
		self.doneBusinessText:SetValue("Thanks for doing business, see you soon!");
	else
		self.doneBusinessText:SetValue(openAura.salesman.text.doneBusiness);
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
	
	for k, v in pairs(openAura.faction.stored) do
		self.factionBoxes[k] = self.factionsForm:CheckBox(v.name);
		self.factionBoxes[k].OnChange = function(checkBox)
			if ( checkBox:GetChecked() ) then
				openAura.salesman.factions[k] = true;
			else
				openAura.salesman.factions[k] = nil;
			end;
		end;
		
		if ( openAura.salesman.factions[k] ) then
			self.factionBoxes[k]:SetValue(true);
		end;
	end;
	
	for k, v in pairs(openAura.class.stored) do
		self.classBoxes[k] = self.classesForm:CheckBox(v.name);
		self.classBoxes[k].OnChange = function(checkBox)
			if ( checkBox:GetChecked() ) then
				openAura.salesman.classes[k] = true;
			else
				openAura.salesman.classes[k] = nil;
			end;
		end;
		
		if ( openAura.salesman.classes[k] ) then
			self.factionBoxes[k]:SetValue(true);
		end;
	end;
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:AddSheet("Sells", self.sellsPanel, "gui/silkicons/box", nil, nil, "View items that "..salesmanName.." sells.");
	self.propertySheet:AddSheet("Buys", self.buysPanel, "gui/silkicons/add", nil, nil, "View items that "..salesmanName.." buys.");
	self.propertySheet:AddSheet("Items", self.itemsPanel, "gui/silkicons/application_view_tile", nil, nil, "View possible items for trading.");
	self.propertySheet:AddSheet("Settings", self.settingsPanel, "gui/silkicons/check_on", nil, nil, "View possible items for trading.");
	
	openAura:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panel, typeName, inventory)
	panel:Clear(true);
	panel.typeName = typeName;
	panel.inventory = inventory;
	
	openAura.plugin:Call("PlayerSalesmanRebuilding", panel);
	
	local categories = {};
	local items = {};
	
	for k, v in pairs(panel.inventory) do
		local itemTable = openAura.item:Get(k);
		
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
	
	openAura.plugin:Call("PlayerSalesmanRebuilt", panel, categories);
	
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
				return openAura.item.stored[ a[1] ].name < openAura.item.stored[ b[1] ].name;
			end);
			
			for k2, v2 in pairs(v.items) do
				panel.currentItem = v2[1];
				panelList:AddItem( vgui.Create("aura_SalesmanItem", panel) );
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel( self.sellsPanel, "Sells",
		openAura.salesman:GetSells()
	);
	
	self:RebuildPanel( self.buysPanel, "Buys",
		openAura.salesman:GetBuys()
	);
	
	self:RebuildPanel( self.itemsPanel, "Items",
		openAura.salesman:GetItems()
	);
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	openAura.salesman.text.doneBusiness = self.doneBusinessText:GetValue();
	openAura.salesman.text.cannotAfford = self.cannotAffordText:GetValue();
	openAura.salesman.text.needMore = self.needMoreText:GetValue();
	openAura.salesman.text.noStock = self.noStockText:GetValue();
	openAura.salesman.text.noSale = self.noSaleText:GetValue();
	openAura.salesman.showChatBubble = (self.showChatBubble:GetChecked() == true);
	openAura.salesman.buyInShipments = (self.buyInShipments:GetChecked() == true);
	openAura.salesman.physDesc = self.physDesc:GetValue();
	openAura.salesman.buyRate = self.buyRate:GetValue();
	openAura.salesman.stock = self.stock:GetValue();
	openAura.salesman.model = self.model:GetValue();
	openAura.salesman.cash = self.cash:GetValue();
	
	local priceScale = self.priceScale:GetValue();
	openAura.salesman.priceScale = tonumber(priceScale) or 1;
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

vgui.Register("aura_Salesman", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(32, 32);
	
	self.typeName = self:GetParent().typeName;
	self.itemTable = table.Copy( openAura.item:Get(self:GetParent().currentItem) );
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "SALESMAN");
	end;

	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = openAura:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.itemTable.color);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.itemTable.OnPanelSelected) then
			self.itemTable:OnPanelSelected(self, "SALESMAN");
		end;
		
		if (self.typeName == "Items") then
			if ( self.itemTable.cost == 0 and openAura.config:Get("cash_enabled"):Get() ) then
				local cashName = openAura.option:GetKey("name_cash");
				
				openAura:AddMenuFromData( nil, {
					["Buys"] = function()
						Derma_StringRequest(cashName, "How much do you want the item to be bought for?", "", function(text)
							openAura.salesman.buys[self.itemTable.uniqueID] = tonumber(text) or true;
							openAura.salesman:GetPanel():Rebuild();
						end);
					end,
					["Sells"] = function()
						Derma_StringRequest(cashName, "How much do you want the item to sell for?", "", function(text)
							openAura.salesman.sells[self.itemTable.uniqueID] = tonumber(text) or true;
							openAura.salesman:GetPanel():Rebuild();
						end);
					end,
					["Both"] = function()
						Derma_StringRequest(cashName, "How much do you want the item to sell for?", "", function(sellPrice)
							Derma_StringRequest(cashName, "How much do you want the item to be bought for?", "", function(buyPrice)
								openAura.salesman.sells[self.itemTable.uniqueID] = tonumber(sellPrice) or true;
								openAura.salesman.buys[self.itemTable.uniqueID] = tonumber(buyPrice) or true;
								openAura.salesman:GetPanel():Rebuild();
							end);
						end);
					end
				} );
			else
				openAura:AddMenuFromData( nil, {
					["Buys"] = function()
						openAura.salesman.buys[self.itemTable.uniqueID] = true;
						openAura.salesman:GetPanel():Rebuild();
					end,
					["Sells"] = function()
						openAura.salesman.sells[self.itemTable.uniqueID] = true;
						openAura.salesman:GetPanel():Rebuild();
					end,
					["Both"] = function()
						openAura.salesman.sells[self.itemTable.uniqueID] = true;
						openAura.salesman.buys[self.itemTable.uniqueID] = true;
						openAura.salesman:GetPanel():Rebuild();
					end
				} );
			end;
		elseif (self.typeName == "Sells") then
			openAura.salesman.sells[self.itemTable.uniqueID] = nil;
			openAura.salesman:GetPanel():Rebuild();
		elseif (self.typeName == "Buys") then
			openAura.salesman.buys[self.itemTable.uniqueID] = nil;
			openAura.salesman:GetPanel():Rebuild();
		end;
	end;
	
	local model, skin = openAura.item:GetIconInfo(self.itemTable);
	
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
		if ( openAura.salesman:BuyInShipments() ) then
			amount = self.itemTable.batch;
		else
			amount = 1;
		end;
		
		priceScale = openAura.salesman:GetPriceScale();
	elseif (self.typeName == "Buys") then
		priceScale = openAura.salesman:GetBuyRate() / 100;
	end;
	
	local actualAmount = math.max(amount, 1);
	local cashInfo = "Unset";
	local name = self.itemTable.name;
	
	if (amount > 1) then
		name = amount.." "..self.itemTable.plural;
	elseif (amount == 1) then
		name = amount.." "..name;
	end;
	
	if (self.typeName == "Sells" and openAura.salesman.stock != -1) then
		name = "["..openAura.salesman.stock.."] "..name;
	end;
	
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		if (self.itemTable.cost != 0) then
			cashInfo = FORMAT_CASH( (self.itemTable.cost * priceScale) * actualAmount );
		else
			cashInfo = "Free";
		end;
		
		local overrideCash = openAura.salesman.sells[self.itemTable.uniqueID];
		
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
		self.spawnIcon:SetToolTip( openAura.config:Parse(description).."\n"..openAura.config:Parse(self.itemTable.toolTip) );
	else
		self.spawnIcon:SetToolTip( openAura.config:Parse(description) );
	end;
	
	self.nameLabel:SetText(name);
	self.nameLabel:SizeToContents();
	self.infoLabel:SetText(cashInfo);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("aura_SalesmanItem", PANEL, "DPanel");