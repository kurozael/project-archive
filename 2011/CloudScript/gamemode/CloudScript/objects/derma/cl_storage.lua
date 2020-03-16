--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle( CloudScript.storage:GetName() );
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		
		self:Close(); self:Remove();
		
		gui.EnableScreenClicker(false);
		
		CloudScript:RunCommand("StorageClose");
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
	self.propertySheet:AddSheet(CloudScript.option:GetKey("name_inventory"), self.inventoryPanel, "gui/silkicons/application_view_tile", nil, nil, "View items in your inventory.");

	CloudScript:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panel, name, usedWeight, weight, cash, inventory)
	panel:Clear(true);
	panel.cash = cash;
	panel.name = name;
	panel.weight = weight;
	panel.usedWeight = usedWeight;
	panel.inventory = inventory;
	
	CloudScript.plugin:Call("PlayerStorageRebuilding", panel);
	
	local categories = {};
	local usedWeight = ( cash * CloudScript.config:Get("cash_weight"):Get() );
	local items = {};
	
	if ( CloudScript.storage:GetNoCashWeight() ) then
		usedWeight = 0;
	end;
	
	for k, v in pairs(panel.inventory) do
		local itemTable = CloudScript.item:Get(k);
		
		if (itemTable) then
			if (itemTable.allowStorage != false) then
				if ( ( panel.name == "Container" and CloudScript.player:CanTakeFromStorage(k) )
				or ( panel.name == "Inventory" and CloudScript.player:CanGiveToStorage(k) ) ) then
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
		categories[#categories + 1] = v;
	end;
	
	if (!panel.usedWeight) then
		panel.usedWeight = usedWeight;
	end;
	
	CloudScript.plugin:Call("PlayerStorageRebuilt", panel, categories);
	
	local numberWang = nil;
	local cashForm = nil;
	local button = nil;
	
	if (CloudScript.config:Get("cash_enabled"):Get() and panel.cash > 0) then
		numberWang = vgui.Create("DNumberWang", panel);
		cashForm = vgui.Create("DForm", panel);
		button = vgui.Create("DButton", panel);
		
		button:SetText("Transfer");
		button.Stretch = true;
		
		-- Called when the button is clicked.
		function button.DoClick(button)
			local cashName = CloudScript.option:GetKey("name_cash");
			
			if (panel.name == "Inventory") then
				RunConsoleCommand( "cloud", "StorageGive"..string.gsub(cashName, "%s", ""), numberWang:GetValue() );
			else
				RunConsoleCommand( "cloud", "StorageTake"..string.gsub(cashName, "%s", ""), numberWang:GetValue() );
			end;
		end;
		
		numberWang.Stretch = true;
		numberWang:SetValue(panel.cash);
		numberWang:SetMinMax(0, panel.cash);
		numberWang:SetDecimals(0);
		numberWang:SizeToContents();
		
		cashForm:SetPadding(5);
		cashForm:SetName( CloudScript.option:GetKey("name_cash") );
		cashForm:AddItem(numberWang);
		cashForm:AddItem(button);
	end;
	
	if (panel.usedWeight > 0) then
		local informationForm = vgui.Create("DForm", panel);
			informationForm:SetPadding(5);
			informationForm:SetName("Weight");
			informationForm:AddItem( vgui.Create("cloud_StorageWeight", panel) );
		panel:AddItem(informationForm);
	end;
	
	if (cashForm) then
		panel:AddItem(cashForm);
	end;
	
	if (table.Count(categories) > 0) then
		local inventoryForm = vgui.Create("DForm", panel);
			inventoryForm:SetName("Inventory");
			inventoryForm:SetPadding(4);
		panel:AddItem(inventoryForm);
		
		local panelList = vgui.Create("DPanelList", panel);
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
		inventoryForm:AddItem(panelList);
		
		for k, v in pairs(categories) do
			table.sort(v, function(a, b)
				return CloudScript.item.stored[ a[1] ].name < CloudScript.item.stored[ b[1] ].name;
			end);
			
			for k2, v2 in pairs(v) do
				panel.currentAmount = v2[2];
				panel.currentItem = v2[1];
				
				panelList:AddItem( vgui.Create("cloud_StorageItem", panel) );
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel( self.containerPanel, "Container", nil,
		CloudScript.storage:GetWeight(),
		CloudScript.storage:GetCash(),
		CloudScript.storage:GetInventory()
	);
	
	self:RebuildPanel( self.inventoryPanel, "Inventory",
		CloudScript.inventory:GetWeight(),
		CloudScript.inventory:GetMaximumWeight(),
		CloudScript.player:GetCash(),
		CloudScript.inventory:GetAll()
	);
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	if ( IsValid(self.inventoryPanel) ) then
		if (CloudScript.player:GetCash() != self.inventoryPanel.cash) then
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

vgui.Register("cloud_Storage", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(32, 32);
	
	self.containerName = self:GetParent().name;
	self.amount = self:GetParent().currentAmount;
	self.itemTable = table.Copy( CloudScript.item:Get(self:GetParent().currentItem) );
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "STORAGE");
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
			self.itemTable:OnPanelSelected(self, "STORAGE");
		end;
		
		if (self.containerName == "Inventory") then
			CloudScript:RunCommand("StorageGiveItem", self.itemTable.uniqueID);
		else
			CloudScript:RunCommand("StorageTakeItem", self.itemTable.uniqueID);
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
	local toolTip = "";
	local weight = self.itemTable.weight.."kg";
	local name = self.amount.." "..self.itemTable.name;
	
	if (self.amount > 1) then
		name = self.amount.." "..self.itemTable.plural;
	end;
	
	if (self.itemTable.weightText) then
		weight = self.itemTable.weightText;
	elseif (self.itemTable.weight == 0) then
		weight = "Weightless";
	end;
	
	if (self.itemTable.OnPanelThink) then
		self.itemTable:OnPanelThink(self, "STORAGE");
	end;
	
	if (self.itemTable.GetClientSideName) then
		if (self.amount > 1) then
			if ( self.itemTable:GetClientSideName(true) ) then
				name = self.amount.." "..self.itemTable:GetClientSideName(true);
			else
				name = self.amount.." "..self.itemTable.plural;
			end;
		elseif ( self.itemTable:GetClientSideName() ) then
			name = self.amount.." "..self.itemTable:GetClientSideName();
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
	self.infoLabel:SetText(weight);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("cloud_StorageItem", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = CloudScript.option:GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	self.panel = self:GetParent();
	
	self.weight = vgui.Create("DLabel", self);
	self.weight:SetText("N/A");
	self.weight:SetTextColor(colorWhite);
	self.weight:SizeToContents();
	self.weight:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = self.panel.weight or 0;
		local usedWeight = self.panel.usedWeight or 0;
		
		local color = Color(100, 100, 100, 255);
		local width = math.Clamp( (spaceUsed:GetWide() / maximumWeight) * usedWeight, 0, spaceUsed:GetWide() );
		local red = math.Clamp( (255 / maximumWeight) * usedWeight, 0, 255) ;
		
		if (color) then
			color.r = math.min(color.r - 25, 255);
			color.g = math.min(color.g - 25, 255);
			color.b = math.min(color.b - 25, 255);
		end;
		
		CloudScript:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), color);
		CloudScript:DrawSimpleGradientBox( 0, 0, 0, width, spaceUsed:GetTall(), Color(139, 215, 113, 255) );
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.weight:SetText( (self.panel.usedWeight or 0).."/"..(self.panel.weight or 0).."kg" );
	self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2);
	self.weight:SizeToContents();
end;
	
vgui.Register("cloud_StorageWeight", PANEL, "DPanel");

usermessage.Hook("cloud_StorageStart", function(msg)
	if ( CloudScript.storage:IsStorageOpen() ) then
		CloseDermaMenus();
		
		CloudScript.storage.panel:Close();
		CloudScript.storage.panel:Remove();
	end;
	
	gui.EnableScreenClicker(true);
	
	CloudScript.storage.noCashWeight = msg:ReadBool();
	CloudScript.storage.inventory = {};
	CloudScript.storage.weight = CloudScript.config:Get("default_inv_weight"):Get();
	CloudScript.storage.entity = msg:ReadEntity();
	CloudScript.storage.name = msg:ReadString();
	CloudScript.storage.cash = 0;
	
	CloudScript.storage.panel = vgui.Create("cloud_Storage");
	CloudScript.storage.panel:Rebuild();
	CloudScript.storage.panel:MakePopup();
end);

usermessage.Hook("cloud_StorageCash", function(msg)
	if ( CloudScript.storage:IsStorageOpen() ) then
		CloudScript.storage.cash = msg:ReadLong();
		CloudScript.storage:GetPanel():Rebuild();
	end;
end);


usermessage.Hook("cloud_StorageWeight", function(msg)
	if ( CloudScript.storage:IsStorageOpen() ) then
		CloudScript.storage.weight = msg:ReadFloat();
		
		CloudScript.storage:GetPanel():Rebuild();
	end;
end);

usermessage.Hook("cloud_StorageItem", function(msg)
	if ( CloudScript.storage:IsStorageOpen() ) then
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = CloudScript.item:Get(index);
		
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			if (amount == 0) then
				CloudScript.storage.inventory[item] = nil;
			else
				CloudScript.storage.inventory[item] = amount;
			end;
			
			CloudScript.storage:GetPanel():Rebuild();
		end;
	end;
end);

usermessage.Hook("cloud_StorageClose", function(msg)
	if ( CloudScript.storage:IsStorageOpen() ) then
		CloseDermaMenus();
		
		CloudScript.storage:GetPanel():Close();
		CloudScript.storage:GetPanel():Remove();
		
		gui.EnableScreenClicker(false);
		
		CloudScript.storage.inventory = nil;
		CloudScript.storage.weight = nil;
		CloudScript.storage.entity = nil;
		CloudScript.storage.name = nil;
	end;
end);