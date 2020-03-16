--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle( openAura.storage:GetName() );
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		
		self:Close(); self:Remove();
		
		gui.EnableScreenClicker(false);
		
		openAura:RunCommand("StorageClose");
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
	self.propertySheet:AddSheet(openAura.option:GetKey("name_inventory"), self.inventoryPanel, "gui/silkicons/application_view_tile", nil, nil, "View items in your inventory.");

	openAura:SetNoticePanel(self);
end;

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panel, name, usedWeight, weight, cash, inventory)
	panel:Clear(true);
	panel.cash = cash;
	panel.name = name;
	panel.weight = weight;
	panel.usedWeight = usedWeight;
	panel.inventory = inventory;
	
	openAura.plugin:Call("PlayerStorageRebuilding", panel);
	
	local categories = {};
	local usedWeight = ( cash * openAura.config:Get("cash_weight"):Get() );
	local items = {};
	
	if ( openAura.storage:GetNoCashWeight() ) then
		usedWeight = 0;
	end;
	
	for k, v in pairs(panel.inventory) do
		local itemTable = openAura.item:Get(k);
		
		if (itemTable) then
			if (itemTable.allowStorage != false) then
				if ( ( panel.name == "Container" and openAura.player:CanTakeFromStorage(k) )
				or ( panel.name == "Inventory" and openAura.player:CanGiveToStorage(k) ) ) then
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
	
	openAura.plugin:Call("PlayerStorageRebuilt", panel, categories);
	
	local numberWang = nil;
	local cashForm = nil;
	local button = nil;
	
	if (openAura.config:Get("cash_enabled"):Get() and panel.cash > 0) then
		numberWang = vgui.Create("DNumberWang", panel);
		cashForm = vgui.Create("DForm", panel);
		button = vgui.Create("DButton", panel);
		
		button:SetText("Transfer");
		button.Stretch = true;
		
		-- Called when the button is clicked.
		function button.DoClick(button)
			local cashName = openAura.option:GetKey("name_cash");
			
			if (panel.name == "Inventory") then
				RunConsoleCommand( "aura", "StorageGive"..string.gsub(cashName, "%s", ""), numberWang:GetValue() );
			else
				RunConsoleCommand( "aura", "StorageTake"..string.gsub(cashName, "%s", ""), numberWang:GetValue() );
			end;
		end;
		
		numberWang.Stretch = true;
		numberWang:SetValue(panel.cash);
		numberWang:SetMinMax(0, panel.cash);
		numberWang:SetDecimals(0);
		numberWang:SizeToContents();
		
		cashForm:SetPadding(5);
		cashForm:SetName( openAura.option:GetKey("name_cash") );
		cashForm:AddItem(numberWang);
		cashForm:AddItem(button);
	end;
	
	if (panel.usedWeight > 0) then
		local informationForm = vgui.Create("DForm", panel);
			informationForm:SetPadding(5);
			informationForm:SetName("Weight");
			informationForm:AddItem( vgui.Create("aura_StorageWeight", panel) );
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
				return openAura.item.stored[ a[1] ].name < openAura.item.stored[ b[1] ].name;
			end);
			
			for k2, v2 in pairs(v) do
				panel.currentAmount = v2[2];
				panel.currentItem = v2[1];
				
				panelList:AddItem( vgui.Create("aura_StorageItem", panel) );
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel( self.containerPanel, "Container", nil,
		openAura.storage:GetWeight(),
		openAura.storage:GetCash(),
		openAura.storage:GetInventory()
	);
	
	self:RebuildPanel( self.inventoryPanel, "Inventory",
		openAura.inventory:GetWeight(),
		openAura.inventory:GetMaximumWeight(),
		openAura.player:GetCash(),
		openAura.inventory:GetAll()
	);
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	if ( IsValid(self.inventoryPanel) ) then
		if (openAura.player:GetCash() != self.inventoryPanel.cash) then
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

vgui.Register("aura_Storage", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(32, 32);
	
	self.containerName = self:GetParent().name;
	self.amount = self:GetParent().currentAmount;
	self.itemTable = table.Copy( openAura.item:Get(self:GetParent().currentItem) );
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "STORAGE");
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
			self.itemTable:OnPanelSelected(self, "STORAGE");
		end;
		
		if (self.containerName == "Inventory") then
			openAura:RunCommand("StorageGiveItem", self.itemTable.uniqueID);
		else
			openAura:RunCommand("StorageTakeItem", self.itemTable.uniqueID);
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
		self.spawnIcon:SetToolTip( openAura.config:Parse(description).."\n"..openAura.config:Parse(self.itemTable.toolTip) );
	else
		self.spawnIcon:SetToolTip( openAura.config:Parse(description) );
	end;
	
	self.nameLabel:SetText(name);
	self.nameLabel:SizeToContents();
	self.infoLabel:SetText(weight);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("aura_StorageItem", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = openAura.option:GetColor("white");
	
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
		
		openAura:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), color);
		openAura:DrawSimpleGradientBox( 0, 0, 0, width, spaceUsed:GetTall(), Color(139, 215, 113, 255) );
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2);
	self.weight:SetText( (self.panel.usedWeight or 0).."/"..(self.panel.weight or 0).."kg" );
	self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2);
	self.weight:SizeToContents();
end;
	
vgui.Register("aura_StorageWeight", PANEL, "DPanel");

usermessage.Hook("aura_StorageStart", function(msg)
	if ( openAura.storage:IsStorageOpen() ) then
		CloseDermaMenus();
		
		openAura.storage.panel:Close();
		openAura.storage.panel:Remove();
	end;
	
	gui.EnableScreenClicker(true);
	
	openAura.storage.noCashWeight = msg:ReadBool();
	openAura.storage.inventory = {};
	openAura.storage.weight = openAura.config:Get("default_inv_weight"):Get();
	openAura.storage.entity = msg:ReadEntity();
	openAura.storage.name = msg:ReadString();
	openAura.storage.cash = 0;
	
	openAura.storage.panel = vgui.Create("aura_Storage");
	openAura.storage.panel:Rebuild();
	openAura.storage.panel:MakePopup();
end);

usermessage.Hook("aura_StorageCash", function(msg)
	if ( openAura.storage:IsStorageOpen() ) then
		openAura.storage.cash = msg:ReadLong();
		openAura.storage:GetPanel():Rebuild();
	end;
end);


usermessage.Hook("aura_StorageWeight", function(msg)
	if ( openAura.storage:IsStorageOpen() ) then
		openAura.storage.weight = msg:ReadFloat();
		
		openAura.storage:GetPanel():Rebuild();
	end;
end);

usermessage.Hook("aura_StorageItem", function(msg)
	if ( openAura.storage:IsStorageOpen() ) then
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = openAura.item:Get(index);
		
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			if (amount == 0) then
				openAura.storage.inventory[item] = nil;
			else
				openAura.storage.inventory[item] = amount;
			end;
			
			openAura.storage:GetPanel():Rebuild();
		end;
	end;
end);

usermessage.Hook("aura_StorageClose", function(msg)
	if ( openAura.storage:IsStorageOpen() ) then
		CloseDermaMenus();
		
		openAura.storage:GetPanel():Close();
		openAura.storage:GetPanel():Remove();
		
		gui.EnableScreenClicker(false);
		
		openAura.storage.inventory = nil;
		openAura.storage.weight = nil;
		openAura.storage.entity = nil;
		openAura.storage.name = nil;
	end;
end);