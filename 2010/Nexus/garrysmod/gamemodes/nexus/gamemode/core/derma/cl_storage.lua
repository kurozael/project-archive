--[[
Name: "cl_storage.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle( nexus.storage.GetName() );
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		
		self:Close(); self:Remove();
		
		gui.EnableScreenClicker(false);
		
		NEXUS:RunCommand("StorageClose");
	end;
	
	self.containerPanel = vgui.Create("DPanelList");
 	self.containerPanel:SetPadding(2);
 	self.containerPanel:SetSpacing(3);
 	self.containerPanel:SizeToContents();
	self.containerPanel:EnableVerticalScrollbar();
	
	self.inventoryPanel = vgui.Create("DPanelList");
 	self.inventoryPanel:SetPadding(2);
 	self.inventoryPanel:SetSpacing(3);
 	self.inventoryPanel:SizeToContents();
	self.inventoryPanel:EnableVerticalScrollbar();
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:AddSheet("Container", self.containerPanel, "gui/silkicons/box", nil, nil, "View items in the container.");
	self.propertySheet:AddSheet(nexus.schema.GetOption("name_inventory"), self.inventoryPanel, "gui/silkicons/application_view_tile", nil, nil, "View items in your inventory.");
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panel, name, usedWeight, weight, cash, inventory)
	panel:Clear(true);
	panel.cash = cash;
	panel.name = name;
	panel.weight = weight;
	panel.usedWeight = usedWeight;
	panel.inventory = inventory;
	
	nexus.mount.Call("PlayerStorageRebuilding", panel);
	
	local categories = {};
	local usedWeight = ( cash * nexus.config.Get("cash_weight"):Get() );
	local items = {};
	
	if ( nexus.storage.GetNoCashWeight() ) then
		usedWeight = 0;
	end;
	
	for k, v in pairs(panel.inventory) do
		local itemTable = nexus.item.Get(k);
		
		if (itemTable) then
			if (itemTable.allowStorage != false) then
				if ( ( panel.name == "Container" and nexus.player.CanTakeFromStorage(k) )
				or ( panel.name == "Inventory" and nexus.player.CanGiveToStorage(k) ) ) then
					local category = itemTable.category;
					
					if (category) then
						items[category] = items[category] or {};
						items[category][#items[category] + 1] = {k, v};
						
						usedWeight = usedWeight + (math.max(itemTable.storageWeight or itemTable.weight, 0) * v);
					end;
				end;
			end;
		end;
	end;
	
	for k, v in pairs(items) do
		categories[#categories + 1] = {category = k, items = v};
	end;
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	if (!panel.usedWeight) then
		panel.usedWeight = usedWeight;
	end;
	
	nexus.mount.Call("PlayerStorageRebuilt", panel, categories);
	
	local numberWang = nil;
	local cashForm = nil;
	local button = nil;
	
	if (nexus.config.Get("cash_enabled"):Get() and panel.cash > 0) then
		numberWang = vgui.Create("DNumberWang", panel);
		cashForm = vgui.Create("DForm", panel);
		button = vgui.Create("DButton", panel);
		
		button:SetText("Transfer");
		button.Stretch = true;
		
		-- Called when the button is clicked.
		function button.DoClick(button)
			local cashName = nexus.schema.GetOption("name_cash");
			
			if (panel.name == "Inventory") then
				RunConsoleCommand( "nx", "StorageGive"..string.gsub(cashName, "%s", ""), numberWang:GetValue() );
			else
				RunConsoleCommand( "nx", "StorageTake"..string.gsub(cashName, "%s", ""), numberWang:GetValue() );
			end;
		end;
		
		numberWang.Stretch = true;
		numberWang:SetValue(panel.cash);
		numberWang:SetMinMax(0, panel.cash);
		numberWang:SetDecimals(0);
		numberWang:SizeToContents();
		
		cashForm:SetPadding(5);
		cashForm:SetName( nexus.schema.GetOption("name_cash") );
		cashForm:AddItem(numberWang);
		cashForm:AddItem(button);
	end;
	
	if (panel.usedWeight > 0) then
		local informationForm = vgui.Create("DForm", panel);
			informationForm:SetPadding(5);
			informationForm:SetName("Weight");
			informationForm:AddItem( vgui.Create("nx_StorageWeight", panel) );
		panel:AddItem(informationForm);
	end;
	
	if (cashForm) then
		panel:AddItem(cashForm);
	end;
	
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local categoryForm = vgui.Create("DForm", panel);
			local panelList = vgui.Create("DPanelList", panel);
			
			panel:AddItem(categoryForm);
			
			table.sort(v.items, function(a, b)
				return nexus.item.GetAll()[ a[1] ].name < nexus.item.GetAll()[ b[1] ].name;
			end);
			
			for k2, v2 in pairs(v.items) do
				panel.currentAmount = v2[2];
				panel.currentItem = v2[1];
				
				panelList:AddItem( vgui.Create("nx_StorageItem", panel) );
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			categoryForm:SetName(v.category);
			categoryForm:AddItem(panelList);
			categoryForm:SetPadding(4);
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel( self.containerPanel, "Container", nil,
		nexus.storage.GetWeight(),
		nexus.storage.GetCash(),
		nexus.storage.GetInventory()
	);
	
	self:RebuildPanel( self.inventoryPanel, "Inventory",
		nexus.inventory.GetWeight(),
		nexus.inventory.GetMaximumWeight(),
		nexus.player.GetCash(),
		nexus.inventory.GetAll()
	);
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	if ( IsValid(self.inventoryPanel) ) then
		if (nexus.player.GetCash() != self.inventoryPanel.cash) then
			self:Rebuild();
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.propertySheet:StretchToParent(4, 28, 4, 4);
	self.containerPanel:StretchToParent(0, 0, 0, 0);
	self.inventoryPanel:StretchToParent(0, 0, 0, 0);
	
	derma.SkinHook("Layout", "Frame", self);
end;

vgui.Register("nx_Storage", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(32, 32);
	
	self.containerName = self:GetParent().name;
	self.amount = self:GetParent().currentAmount;
	self.item = table.Copy( nexus.item.Get(self:GetParent().currentItem) );
	
	if (self.item.OnInitialize) then
		self.item:OnInitialize(self, "STORAGE");
	end;

	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = NEXUS:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.item.color);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.item.OnPanelSelected) then
			self.item:OnPanelSelected(self, "STORAGE");
		end;
		
		if (self.containerName == "Inventory") then
			NEXUS:RunCommand("StorageGiveItem", self.item.uniqueID);
		else
			NEXUS:RunCommand("StorageTakeItem", self.item.uniqueID);
		end;
	end;
	
	local model, skin = nexus.item.GetIconInfo(self.item);
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	local description = self.item.description;
	local toolTip = "";
	local weight = self.item.weight.."kg";
	local name = self.amount.." "..self.item.name;
	
	if (self.amount > 1) then
		name = self.amount.." "..self.item.plural;
	end;
	
	if (self.item.weightText) then
		weight = self.item.weightText;
	elseif (self.item.weight == 0) then
		weight = "Weightless";
	end;
	
	if (self.item.OnPanelThink) then
		self.item:OnPanelThink(self, "STORAGE");
	end;
	
	if (self.item.GetClientSideName) then
		if (self.amount > 1) then
			if ( self.item:GetClientSideName(true) ) then
				name = self.amount.." "..self.item:GetClientSideName(true);
			else
				name = self.amount.." "..self.item.plural;
			end;
		elseif ( self.item:GetClientSideName() ) then
			name = self.amount.." "..self.item:GetClientSideName();
		end;
	end;
	
	if (self.item.GetClientSideDescription) then
		if ( self.item:GetClientSideDescription() ) then
			description = self.item:GetClientSideDescription();
		end;
	end;
	
	if (self.item.toolTip) then
		self.spawnIcon:SetToolTip( nexus.config.Parse(description).."\n"..nexus.config.Parse(self.item.toolTip) );
	else
		self.spawnIcon:SetToolTip( nexus.config.Parse(description) );
	end;
	
	self.nameLabel:SetText(name);
	self.nameLabel:SizeToContents();
	self.infoLabel:SetText(weight);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("nx_StorageItem", PANEL, "DPanel");

local PANEL = {};
local GRADIENT = surface.GetTextureID("gui/gradient_up");

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = nexus.schema.GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	self.panel = self:GetParent();
	
	self.weight = vgui.Create("DLabel", self);
	self.weight:SetText("N/A");
	self.weight:SetTextColor(colorWhite);
	self.weight:SizeToContents();
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = self.panel.weight or 0;
		local usedWeight = self.panel.usedWeight or 0;
		
		local width = math.Clamp( (spaceUsed:GetWide() / maximumWeight) * usedWeight, 0, spaceUsed:GetWide() );
		local red = math.Clamp( (255 / maximumWeight) * usedWeight, 0, 255) ;
		
		surface.SetDrawColor(red, 255 - red, 0, 150);
		surface.DrawRect( 0, 0, width, spaceUsed:GetTall() );
		
		surface.SetDrawColor(255, 255, 255, 25);
		surface.SetTexture(GRADIENT);
		surface.DrawTexturedRect( 0, 0, width, spaceUsed:GetTall() );
		
		if ( width > 1 and width < (spaceUsed:GetWide() - 1) ) then
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawRect( width, 0, 1, spaceUsed:GetTall() );
		end;
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.weight:SetText( (self.panel.usedWeight or 0).."/"..(self.panel.weight or 0).."kg" );
	self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2);
	self.weight:SizeToContents();
end;
	
vgui.Register("nx_StorageWeight", PANEL, "DPanel");

usermessage.Hook("nx_StorageStart", function(msg)
	if ( nexus.storage.IsStorageOpen() ) then
		CloseDermaMenus();
		
		nexus.storage.panel:Close();
		nexus.storage.panel:Remove();
	end;
	
	gui.EnableScreenClicker(true);
	
	nexus.storage.noCashWeight = msg:ReadBool();
	nexus.storage.inventory = {};
	nexus.storage.weight = nexus.config.Get("default_inv_weight"):Get();
	nexus.storage.entity = msg:ReadEntity();
	nexus.storage.name = msg:ReadString();
	nexus.storage.cash = 0;
	
	nexus.storage.panel = vgui.Create("nx_Storage");
	nexus.storage.panel:Rebuild();
	nexus.storage.panel:MakePopup();
end);

usermessage.Hook("nx_StorageCash", function(msg)
	if ( nexus.storage.IsStorageOpen() ) then
		nexus.storage.cash = msg:ReadLong();
		nexus.storage.GetPanel():Rebuild();
	end;
end);


usermessage.Hook("nx_StorageWeight", function(msg)
	if ( nexus.storage.IsStorageOpen() ) then
		nexus.storage.weight = msg:ReadFloat();
		
		nexus.storage.GetPanel():Rebuild();
	end;
end);

usermessage.Hook("nx_StorageItem", function(msg)
	if ( nexus.storage.IsStorageOpen() ) then
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = nexus.item.Get(index);
		
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			if (amount == 0) then
				nexus.storage.inventory[item] = nil;
			else
				nexus.storage.inventory[item] = amount;
			end;
			
			nexus.storage.GetPanel():Rebuild();
		end;
	end;
end);

usermessage.Hook("nx_StorageClose", function(msg)
	if ( nexus.storage.IsStorageOpen() ) then
		CloseDermaMenus();
		
		nexus.storage.GetPanel():Close();
		nexus.storage.GetPanel():Remove();
		
		gui.EnableScreenClicker(false);
		
		nexus.storage.inventory = nil;
		nexus.storage.weight = nil;
		nexus.storage.entity = nil;
		nexus.storage.name = nil;
	end;
end);