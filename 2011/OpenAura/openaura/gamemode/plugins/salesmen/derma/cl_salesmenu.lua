--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local salesmenuName = openAura.salesmenu:GetName();
	
	self:SetTitle(salesmenuName);
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		self:Close(); self:Remove();
		
		openAura:StartDataStream("SalesmanDone", openAura.salesmenu.entity);
		
		openAura.salesmenu.buyInShipments = nil;
		openAura.salesmenu.priceScale = nil;
		openAura.salesmenu.factions = nil;
		openAura.salesmenu.buyRate = nil;
		openAura.salesmenu.classes = nil;
		openAura.salesmenu.entity = nil;
		openAura.salesmenu.stock = nil;
		openAura.salesmenu.sells = nil;
		openAura.salesmenu.cash = nil;
		openAura.salesmenu.text = nil;
		openAura.salesmenu.buys = nil;
		openAura.salesmenu.name = nil;
		
		gui.EnableScreenClicker(false);
	end;
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
	
	if (table.Count( openAura.salesmenu:GetSells() ) > 0) then
		self.sellsPanel = vgui.Create("DPanelList");
		self.sellsPanel:SetPadding(2);
		self.sellsPanel:SetSpacing(3);
		self.sellsPanel:SizeToContents();
		self.sellsPanel:EnableVerticalScrollbar();
		self.propertySheet:AddSheet("Sells", self.sellsPanel, "gui/silkicons/box", nil, nil, "View items that "..salesmenuName.." sells.");
	end;
	
	if (table.Count( openAura.salesmenu:GetBuys() ) > 0) then
		self.buysPanel = vgui.Create("DPanelList");
		self.buysPanel:SetPadding(2);
		self.buysPanel:SetSpacing(3);
		self.buysPanel:SizeToContents();
		self.buysPanel:EnableVerticalScrollbar();
		self.propertySheet:AddSheet("Buys", self.buysPanel, "gui/silkicons/add", nil, nil, "View items that "..salesmenuName.." buys.");
	end;

	openAura:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(name, panel, inventory)
	panel:Clear(true);
	panel.inventory = inventory;
	
	openAura.plugin:Call("PlayerSalesmenuRebuilding", panel);
	
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		local totalCash = openAura.salesmenu:GetCash();
		
		if (totalCash > -1) then
			local cashForm = vgui.Create("DForm", panel);
				cashForm:SetName( openAura.option:GetKey("name_cash") );
				cashForm:SetPadding(4);
			panel:AddItem(cashForm);
			
			cashForm:Help(openAura.salesmenu:GetName().." has "..FORMAT_CASH(totalCash, nil, true).." to their name.");
		end;
	end;
	
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
	
	openAura.plugin:Call("PlayerSalesmenuRebuilt", panel, categories);
	
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
				local aUniqueID = a[1];
				local bUniqueID = b[1];
				
				if (openAura.item.stored[aUniqueID].cost == openAura.item.stored[bUniqueID].cost) then
					return openAura.item.stored[aUniqueID].name < openAura.item.stored[bUniqueID].name;
				else
					return openAura.item.stored[aUniqueID].cost > openAura.item.stored[bUniqueID].cost;
				end;
			end);
			
			for k2, v2 in pairs(v.items) do
				panel.currentItem = v2[1];
				panel.typeName = name;
				
				panelList:AddItem( vgui.Create("aura_SalesmenuItem", panel) );
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if ( IsValid(self.sellsPanel) ) then
		self:RebuildPanel( "Sells", self.sellsPanel, openAura.salesmenu:GetSells() );
	end;
	
	if ( IsValid(self.buysPanel) ) then
		self:RebuildPanel( "Buys", self.buysPanel, openAura.salesmenu:GetBuys() );
	end;
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.propertySheet:StretchToParent(4, 28, 4, 4);
	
	if ( IsValid(self.sellsPanel) ) then
		self.sellsPanel:StretchToParent(0, 0, 0, 0);
	end;
	
	if ( IsValid(self.buysPanel) ) then
		self.buysPanel:StretchToParent(0, 0, 0, 0);
	end;
	
	derma.SkinHook("Layout", "Frame", self);
end;

vgui.Register("aura_Salesmenu", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(32, 32);
	self.itemTable = table.Copy( openAura.item:Get(self:GetParent().currentItem) );
	self.typeName = self:GetParent().typeName;
	
	openAura.plugin:Call("PlayerAdjustBusinessItemTable", self.itemTable);
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "SALESMENU");
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
			self.itemTable:OnPanelSelected(self, "SALESMENU");
		end;
		
		local entity = openAura.salesmenu:GetEntity();
		
		if ( IsValid(entity) ) then
			openAura:StartDataStream( "Salesmenu", {
				tradeType = self.typeName,
				uniqueID = self.itemTable.uniqueID,
				entity = entity
			} );
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
	local priceScale = openAura.salesmenu:GetPriceScale();
	local toolTip = "";
	local amount = 1;
	
	if (self.typeName == "Sells") then
		if ( openAura.salesmenu:BuyInShipments() ) then
			amount = self.itemTable.batch;
		end;
	elseif (self.typeName == "Buys") then
		priceScale = openAura.salesmenu:GetBuyRate() / 100;
		amount = openAura.inventory:HasItem(self.itemTable.uniqueID) or 0;
	end;
	
	local actualAmount = math.max(amount, 1);
	local cashInfo = "Free";
	local name = amount.." "..self.itemTable.name;
	
	if (self.typeName == "Buys") then
		if (amount > 1) then
			name = "["..amount.."] "..self.itemTable.plural;
		else
			name = "["..amount.."] "..self.itemTable.name;
		end;
	elseif (amount > 1) then
		name = amount.." "..self.itemTable.plural;
	end;
	
	if ( self.typeName == "Sells" and openAura.salesmenu.stock[self.itemTable.uniqueID] ) then
		name = "["..openAura.salesmenu.stock[self.itemTable.uniqueID].."] "..name;
	end;
	
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		if (self.itemTable.cost != 0) then
			cashInfo = FORMAT_CASH( (self.itemTable.cost * priceScale) * actualAmount );
		end;
		
		local overrideCash = nil;
		
		if (self.typeName == "Sells") then
			overrideCash = openAura.salesmenu.sells[self.itemTable.uniqueID];
		else
			overrideCash = openAura.salesmenu.buys[self.itemTable.uniqueID];
		end;
		
		if (type(overrideCash) == "number") then
			cashInfo = FORMAT_CASH( (overrideCash * priceScale) * actualAmount );
		end;
	end;
	
	if (self.itemTable.GetClientSideName) then
		if ( self.itemTable:GetClientSideName() ) then
			if (self.typeName == "Buys") then
				name = "["..amount.."] "..self.itemTable:GetClientSideName();
			else
				name = amount.." "..self.itemTable:GetClientSideName();
			end;
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

vgui.Register("aura_SalesmenuItem", PANEL, "DPanel");