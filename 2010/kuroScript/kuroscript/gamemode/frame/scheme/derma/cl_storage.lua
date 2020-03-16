--[[
Name: "cl_storage.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle( kuroScript.storage.GetName() );
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		
		-- Close and remove the panel.
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
		
		-- Run a console command.
		RunConsoleCommand("ks", "storage", "close");
	end;
	
	-- Set some information.
	self.containerPanel = vgui.Create("DPanelList");
 	self.containerPanel:SetPadding(2);
 	self.containerPanel:SetSpacing(3);
 	self.containerPanel:SizeToContents();
	self.containerPanel:EnableVerticalScrollbar();
	
	-- Set some information.
	self.inventoryPanel = vgui.Create("DPanelList");
 	self.inventoryPanel:SetPadding(2);
 	self.inventoryPanel:SetSpacing(3);
 	self.inventoryPanel:SizeToContents();
	self.inventoryPanel:EnableVerticalScrollbar();
	
	-- Set some information.
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:AddSheet("Container", self.containerPanel, "gui/silkicons/box", nil, nil, "View items in the container.");
	self.propertySheet:AddSheet("Inventory", self.inventoryPanel, "gui/silkicons/application_view_tile", nil, nil, "View items in your inventory.");
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panel, name, used, weight, currency, inventory)
	panel:Clear();
	
	-- Set some information.
	panel.name = name;
	panel.used = used;
	panel.weight = weight;
	panel.currency = currency;
	panel.inventory = inventory;
	
	-- Set some information.
	local informationForm = vgui.Create("DForm", panel);
	local currencyForm = vgui.Create("DForm", panel);
	local numberWang = vgui.Create("DNumberWang", panel);
	local button = vgui.Create("DButton", panel);
	
	-- Set some information.
	button:SetText("Transfer");
	button.Stretch = true;
	
	-- Called when the button is clicked.
	function button.DoClick(button)
		if (panel.name == "Inventory") then
			RunConsoleCommand( "ks", "storage", "givecurrency", numberWang:GetValue() );
		else
			RunConsoleCommand( "ks", "storage", "takecurrency", numberWang:GetValue() );
		end;
	end;
	
	-- Set some information.
	numberWang.Stretch = true;
	numberWang:SetValue(currency);
	numberWang:SetMinMax(0, currency);
	numberWang:SetDecimals(0);
	numberWang:SizeToContents();
	
	-- Set some information.
	informationForm:SetPadding(5);
	informationForm:SetName("Weight");
	informationForm:AddItem( vgui.Create("ks_StorageWeight", panel) );
	
	-- Set some information.
	currencyForm:SetPadding(5);
	currencyForm:SetName("Currency");
	currencyForm:AddItem(numberWang);
	currencyForm:AddItem(button);
	
	-- Add some items to the panel list.
	panel:AddItem(informationForm);
	panel:AddItem(currencyForm);
	
	-- Set some information.
	local categories = {};
	local items = {};
	local used = ( currency * kuroScript.config.Get("currency_weight"):Get() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(panel.inventory) do
		local itemTable = kuroScript.item.Get(k);
		
		-- Check if a statement is true.
		if (itemTable) then
			if (itemTable.allowStorage != false) then
				if ( (panel.name == "Container" and itemTable.allowTake != false)
				or (panel.name == "Inventory" and itemTable.allowGive != false) ) then
					local category = itemTable.category;
					
					-- Set some information.
					items[category] = items[category] or {};
					items[category][#items[category] + 1] = {k, v};
					
					-- Set some information.
					used = used + (math.max(itemTable.storageWeight or itemTable.weight, 0) * v);
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(items) do
		categories[#categories + 1] = {category = k, items = v};
	end;
	
	-- Sort the categories.
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	-- Check if a statement is true.
	if (!panel.used) then
		panel.used = used;
	end;
	
	-- Check if a statement is true.
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory", panel);
			local panelList = vgui.Create("DPanelList", panel);
			
			-- Add an item to the panel list.
			panel:AddItem(collapsibleCategory);
			
			-- Sort the items.
			table.sort(v.items, function(a, b)
				return kuroScript.item.stored[ a[1] ].name < kuroScript.item.stored[ b[1] ].name;
			end);
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v.items) do
				panel.currentAmount = v2[2];
				panel.currentItem = v2[1];
				
				-- Add an item to the panel list.
				panelList:AddItem( vgui.Create("ks_StorageItem", panel) );
			end;
			
			-- Set some information.
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			-- Set some information.
			collapsibleCategory:SetLabel(v.category);
			collapsibleCategory:SetPadding(4);
			collapsibleCategory:SetContents(panelList);
			collapsibleCategory:SetCookieName("ks_"..name.."Storage_"..v.category);
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel( self.containerPanel, "Container", nil,
		kuroScript.storage.GetWeight(),
		kuroScript.storage.GetCurrency(),
		kuroScript.storage.GetInventory()
	);
	
	-- Rebuild the panel.
	self:RebuildPanel( self.inventoryPanel, "Inventory",
		kuroScript.inventory.GetWeight(),
		kuroScript.inventory.GetMaximumWeight(),
		kuroScript.player.GetCurrency(),
		kuroScript.inventory.GetAll()
	);
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	-- Set some information.
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	-- Check if a statement is true.
	if ( self.inventoryPanel and self.inventoryPanel:IsValid() ) then
		if (kuroScript.player.GetCurrency() != self.inventoryPanel.currency) then
			self:Rebuild();
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.propertySheet:StretchToParent(4, 28, 4, 4);
	self.containerPanel:StretchToParent(0, 0, 0, 0);
	self.inventoryPanel:StretchToParent(0, 0, 0, 0);
	
	-- Perform the layour.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("ks_Storage", PANEL, "DFrame");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 42);
	self:SetPos(1, 5);
	
	-- Set some information.
	self.containerName = self:GetParent().name;
	self.amount = self:GetParent().currentAmount;
	self.item = table.Copy( kuroScript.item.Get(self:GetParent().currentItem) );
	
	-- Check if a statement is true.
	if (self.name == "Inventory") then
		if (self.item.OnInitialize) then
			self.item:OnInitialize();
		end;
	end;
	
	-- Set some information.
	self.name = vgui.Create("DLabel", self);
	self.name:SetText(self.amount.." "..self.item.name);
	self.name:SizeToContents();
	self.name:SetTextColor(COLOR_WHITE);
	
	-- Check if a statement is true.
	if (self.amount > 1) then
		self.name:SetText(self.amount.." "..self.item.plural);
	end;
	
	-- Set some information.
	self.information = vgui.Create("DLabel", self);
	self.information:SetText(self.item.weight.." Kilograms");
	self.information:SizeToContents();
	self.information:SetTextColor(COLOR_WHITE);
	
	-- Check if a statement is true.
	if (self.item.weightText) then
		self.information:SetText(self.item.weightText);
	elseif (self.item.weight == 1) then
		self.information:SetText(self.item.weight.." Kilogram");
	elseif (self.item.weight == 0) then
		self.information:SetText("Weightless");
	end;
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.containerName == "Inventory") then
			RunConsoleCommand("ks", "storage", "giveitem", self.item.uniqueID);
		else
			RunConsoleCommand("ks", "storage", "takeitem", self.item.uniqueID);
		end;
	end;
	
	-- Set some information.
	local model = self.item.model;
	local skin = self.item.skin;
	
	-- Check if a statement is true.
	if (self.item.iconModel) then
		model = self.item.iconModel;
	end;
	
	-- Check if a statement is true.
	if (self.item.iconSkin) then
		skin = self.item.iconSkin;
	end;
	
	-- Check if a statement is true.
	if (self.item.GetClientSideModel) then
		model = self.item:GetClientSideModel();
	end;
	
	-- Check if a statement is true.
	if (self.item.GetClientSideSkin) then
		skin = self.item:GetClientSideSkin();
	end;
	
	-- Set some information.
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip(self.item.description);
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	if (self.item.GetClientSideName) then
		if (self.amount > 1) then
			if ( self.item:GetClientSideName(true) ) then
				self.name:SetText( self.amount.." "..self.item:GetClientSideName(true) );
			else
				self.name:SetText(self.amount.." "..self.item.plural);
			end;
		else
			if ( self.item:GetClientSideName() ) then
				self.name:SetText( self.amount.." "..self.item:GetClientSideName() );
			else
				self.name:SetText(self.amount.." "..self.item.name);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (self.item.GetClientSideDescription) then
		if ( self.item:GetClientSideDescription() ) then
			self.spawnIcon:SetToolTip( kuroScript.config.Parse( self.item:GetClientSideDescription() ) );
		else
			self.spawnIcon:SetToolTip( kuroScript.config.Parse(self.item.description) );
		end;
	end;
	
	-- Set some information.
	self.name:SizeToContents();
end;

-- A function to adjust a position.
function PANEL:AdjustPosition(panel, x, y)
	panel:SetPos(x, y);
	
	-- Return the position.
	return x + panel:GetWide() + 8, y;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local x, y = self:AdjustPosition(self.spawnIcon, 4, 5);
	
	-- Set some information.
	self.name:SetPos(x, y);
	self.information:SetPos(x, y + 19);
	self.information:SizeToContents();
end;

-- Register the panel.
vgui.Register("ks_StorageItem", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	self.panel = self:GetParent();
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = self.panel.weight or 0;
		local used = self.panel.used or 0;
		
		-- Set some information.
		local width = math.Clamp( (spaceUsed:GetWide() / maximumWeight) * used, 0, spaceUsed:GetWide() );
		local red = math.Clamp( (255 / maximumWeight) * used, 0, 255) ;
		
		-- Set some information.
		surface.SetDrawColor(red, 255 - red, 0, 150);
		surface.DrawRect( 0, 0, width, spaceUsed:GetTall() );
		
		-- Check if a statement is true.
		if ( width > 1 and width < (spaceUsed:GetWide() - 1) ) then
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawRect( width, 0, 1, spaceUsed:GetTall() );
		end;
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
end;
	
-- Register the panel.
vgui.Register("ks_StorageWeight", PANEL, "DPanel");

-- Hook a user message.
usermessage.Hook("ks_StorageStart", function(msg)
	if ( kuroScript.storage.IsStorageOpen() ) then
		CloseDermaMenus();
		
		-- Close and remove the panel.
		kuroScript.storage.panel:Close();
		kuroScript.storage.panel:Remove();
	end;
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
	
	-- Set some information.
	kuroScript.storage.inventory = {};
	kuroScript.storage.currency = 0;
	kuroScript.storage.weight = kuroScript.config.Get("default_inv_weight"):Get();
	kuroScript.storage.entity = msg:ReadEntity();
	kuroScript.storage.name = msg:ReadString();
	
	-- Set some information.
	kuroScript.storage.panel = vgui.Create("ks_Storage");
	kuroScript.storage.panel:Rebuild();
	kuroScript.storage.panel:MakePopup();
end);

-- Hook a user message.
usermessage.Hook("ks_StorageCurrency", function(msg)
	if ( kuroScript.storage.IsStorageOpen() ) then
		kuroScript.storage.currency = msg:ReadLong();
		
		-- Rebuild the storage panel.
		kuroScript.storage.GetPanel():Rebuild();
	end;
end);


-- Hook a user message.
usermessage.Hook("ks_StorageWeight", function(msg)
	if ( kuroScript.storage.IsStorageOpen() ) then
		kuroScript.storage.weight = msg:ReadFloat();
		
		-- Rebuild the storage panel.
		kuroScript.storage.GetPanel():Rebuild();
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_StorageItem", function(msg)
	if ( kuroScript.storage.IsStorageOpen() ) then
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = kuroScript.item.Get(index);
		
		-- Check if a statement is true.
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (amount == 0) then
				kuroScript.storage.inventory[item] = nil;
			else
				kuroScript.storage.inventory[item] = amount;
			end;
			
			-- Rebuild the storage panel.
			kuroScript.storage.GetPanel():Rebuild();
		end;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_StorageClose", function(msg)
	if ( kuroScript.storage.IsStorageOpen() ) then
		CloseDermaMenus();
		
		-- Close and remove the panel.
		kuroScript.storage.GetPanel():Close();
		kuroScript.storage.GetPanel():Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
		
		-- Set some information.
		kuroScript.storage.inventory = nil;
		kuroScript.storage.weight = nil;
		kuroScript.storage.entity = nil;
		kuroScript.storage.name = nil;
	end;
end);

-- Add a hook.
hook.Add("PlayerInventoryRebuilt", "kuroScript.storage.PlayerInventoryRebuilt", function(panel, categories)
	if ( kuroScript.storage.IsStorageOpen() ) then
		kuroScript.storage.GetPanel():Rebuild();
	end;
end);