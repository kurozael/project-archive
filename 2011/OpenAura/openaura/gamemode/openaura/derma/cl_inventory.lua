--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle( openAura.option:GetKey("name_inventory") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.inventory.panel = self;
	openAura.inventory.panel:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("To view an item's options, click on its spawn icon.");
		label:SetInfoColor("blue");
	self.panelList:AddItem(label);
	
	self.weightForm = vgui.Create("DForm", self);
	self.weightForm:SetPadding(4);
	self.weightForm:SetName("Weight");
	self.weightForm:AddItem( vgui.Create("aura_InventoryWeight", self) );
	
	local inventoryCategories = {};
	local equippedCategories = {};
	local inventoryItems = {};
	local equippedItems = {};
	
	for k, v in pairs(openAura.inventory.stored) do
		local itemTable = openAura.item:Get(k);
		
		if (itemTable) then
			local category = itemTable.category;
			local amount = v;
			
			if (itemTable.GetLocalAmount) then
				amount = itemTable:GetLocalAmount(amount);
			end;
			
			if (amount > 0) then
				inventoryItems[category] = inventoryItems[category] or {};
				inventoryItems[category][#inventoryItems[category] + 1] = {k, itemTable.name};
			end;
		end;
	end;
	
	local itemWeapons = {};
	local fakeWeapons = openAura.Client:GetWeapons();
	
	for k, v in pairs(fakeWeapons) do
		local itemTable = openAura.item:GetWeapon(v);
		
		if (itemTable) then
			itemWeapons[itemTable] = v;
		end;
	end;
	
	for k, v in pairs(openAura.item.stored) do
		local category = v.category;
		
		if (v.equippedCategory) then
			category = v.equippedCategory;
		end;
		
		if ( v.HasPlayerEquipped and v:HasPlayerEquipped(openAura.Client, itemWeapons) ) then
			equippedItems[category] = equippedItems[category] or {};
			equippedItems[category][#equippedItems[category] + 1] = v;
		end;
	end;
	
	for k, v in pairs(equippedItems) do
		equippedCategories[#equippedCategories + 1] = v;
	end;
	
	for k, v in pairs(inventoryItems) do
		inventoryCategories[#inventoryCategories + 1] = v;
	end;
	
	openAura.plugin:Call("PlayerInventoryRebuilt", self, inventoryCategories);
	
	if (self.weightForm) then
		self.panelList:AddItem(self.weightForm);
	end;
	
	if (#equippedCategories > 0) then
		self.equippedForm = vgui.Create("DForm", self);
		self.equippedForm:SetName("Equipment");
		self.equippedForm:SetPadding(4);
		
		local panelList = vgui.Create("DPanelList", self);
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
		self.equippedForm:AddItem(panelList);
		
		for k, v in ipairs(equippedCategories) do
			table.sort(v, function(a, b)
				return a.name < b.name;
			end);
			
			for k2, v2 in pairs(v) do
				local model, skin = openAura.item:GetIconInfo(v2);
				
				self.customData = {
					spawnIconColor = v2.color,
					description = v2.description,
					information = v2.weight,
					model = model,
					skin = skin,
					name = v2.name,
				};
				
				self.customData.Callback = function()
					if (v2.OnHandleUnequip) then
						v2:OnHandleUnequip(function(arguments)
							if (arguments) then
								openAura:StartDataStream( "UnequipItem", {v2.uniqueID, arguments} );
							else
								openAura:StartDataStream("UnequipItem", v2.uniqueID);
							end;
						end);
					else
						openAura:StartDataStream("UnequipItem", v2.uniqueID);
					end;
				end;
				
				panelList:AddItem( vgui.Create("aura_InventoryCustom", self) ) ;
			end;
		end;
		
		self.panelList:AddItem(self.equippedForm);
	end;
	
	if (#inventoryCategories > 0) then
		self.inventoryForm = vgui.Create("DForm", self);
		self.inventoryForm:SetName( openAura.option:GetKey("name_inventory") );
		self.inventoryForm:SetPadding(4);
		
		local panelList = vgui.Create("DPanelList", self);
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
		self.inventoryForm:AddItem(panelList);
		
		for k, v in ipairs(inventoryCategories) do
			table.sort(v, function(a, b)
				return a[2] < b[2];
			end);
			
			for k2, v2 in pairs(v) do
				self.currentItem = v2[1];
				panelList:AddItem( vgui.Create("aura_InventoryItem", self) ) ;
			end;
		end;
		
		self.panelList:AddItem(self.inventoryForm);
	end;

	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (openAura.menu:GetActivePanel() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("aura_Inventory", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local customData = self:GetParent().customData or {};
	local toolTip = nil;
	
	if (customData.information) then
		if (type(customData.information) == "number") then
			customData.information = customData.information.."kg";
		end;
	end;
	
	if (customData.description) then
		toolTip = openAura.config:Parse(customData.description);
	end;
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	self.nameLabel:SetText(customData.name);
	self.nameLabel:SizeToContents();
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	self.infoLabel:SetText(customData.information);
	self.infoLabel:SizeToContents();
	
	self.spawnIcon = openAura:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(customData.spawnIconColor);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (customData.Callback) then
			customData.Callback();
		end;
	end;
	
	self.spawnIcon:SetModel(customData.model, customData.skin);
	self.spawnIcon:SetToolTip(toolTip);
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;
	
vgui.Register("aura_InventoryCustom", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local destroyName = openAura.option:GetKey("name_destroy");
	local dropName = openAura.option:GetKey("name_drop");
	local useName = openAura.option:GetKey("name_use");
	
	self:SetSize(self:GetParent():GetWide(), 32);
	
	self.itemTable = table.Copy( openAura.item:Get(self:GetParent().currentItem) );
	self.amount = openAura.inventory.stored[self.itemTable.uniqueID];
	
	if (self.itemTable.GetLocalAmount) then
		self.amount = self.itemTable:GetLocalAmount(self.amount);
	end;
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "INVENTORY");
	end;
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = openAura:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.itemTable.color);
	
	-- Called when the spawn icon's menu should be opened.
	self.spawnIcon.OpenMenu = function(spawnIcon)
		if (self.itemTable.OnHandleRightClick) then
			local customFunction = self.itemTable:OnHandleRightClick();
			
			if (customFunction and customFunction != "Use") then
				if ( self.itemTable.customFunctions
				and table.HasValue(self.itemTable.customFunctions, customFunction) ) then
					if (self.itemTable.OnCustomFunction) then
						self.itemTable:OnCustomFunction(v);
					end;
				end;
				
				RunConsoleCommand( "aura", "InvAction", self.itemTable.uniqueID, string.lower(customFunction) );
				
				spawnIcon.animPress:Start(0.2);
				
				return;
			end;
		end;
		
		if (self.itemTable.OnUse) then
			if (self.itemTable.OnHandleUse) then
				self.itemTable:OnHandleUse(function()
					openAura:RunCommand("InvAction", self.itemTable.uniqueID, "use");
				end);
			else
				openAura:RunCommand("InvAction", self.itemTable.uniqueID, "use");
			end;
			
			spawnIcon.animPress:Start(0.2);
		end;
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local itemFunctions = {};
		
		if (self.itemTable.OnPanelSelected) then
			self.itemTable:OnPanelSelected(self, "INVENTORY");
		end;
		
		if (self.itemTable.OnUse) then
			itemFunctions[#itemFunctions + 1] = self.itemTable.useText or useName;
		end;
		
		if (self.itemTable.OnDrop) then
			itemFunctions[#itemFunctions + 1] = self.itemTable.dropText or dropName;
		end;
		
		if (self.itemTable.OnDestroy) then
			itemFunctions[#itemFunctions + 1] = self.itemTable.destroyText or destroyName;
		end;
		
		if (self.itemTable.customFunctions) then
			for k, v in ipairs(self.itemTable.customFunctions) do
				itemFunctions[#itemFunctions + 1] = v;
			end;
		end;
		
		if (self.itemTable.OnEditFunctions) then
			self.itemTable:OnEditFunctions(itemFunctions);
		end;
		
		openAura.plugin:Call("PlayerAdjustItemFunctions", self.itemTable, itemFunctions);
		
		openAura:ValidateTableKeys(itemFunctions);
		
		table.sort(itemFunctions, function(a, b)
			return a < b;
		end);
		
		if (#itemFunctions > 0) then
			local menu = DermaMenu();
			
			openAura.plugin:Call("PlayerAdjustItemMenu", self.itemTable, menu, itemFunctions);
			
			for k, v in pairs(itemFunctions) do
				if ( (!self.itemTable.useText and v == "Use") or (self.itemTable.useText and v == self.itemTable.useText) ) then
					menu:AddOption(v, function()
						if (self.itemTable) then
							if (self.itemTable.OnHandleUse) then
								self.itemTable:OnHandleUse(function()
									openAura:RunCommand("InvAction", self.itemTable.uniqueID, "use");
								end);
							else
								openAura:RunCommand("InvAction", self.itemTable.uniqueID, "use");
							end;
						end;
					end);
				elseif ( (!self.itemTable.dropText and v == "Drop") or (self.itemTable.dropText and v == self.itemTable.dropText) ) then
					menu:AddOption(v, function()
						if (self.itemTable) then
							openAura:RunCommand("InvAction", self.itemTable.uniqueID, "drop");
						end;
					end);
				elseif ( (!self.itemTable.destroyText and v == "Destroy") or (self.itemTable.destroyText and v == self.itemTable.destroyText) ) then
					local subMenu = menu:AddSubMenu(v);
					
					subMenu:AddOption("Yes", function()
						if (self.itemTable) then
							openAura:RunCommand("InvAction", self.itemTable.uniqueID, "destroy");
						end;
					end);
					
					subMenu:AddOption("No", function() end);
				else
					if (self.itemTable.OnCustomFunction) then
						self.itemTable:OnCustomFunction(v);
					end;
					
					menu:AddOption(v, function()
						if (self.itemTable) then
							RunConsoleCommand("aura", "InvAction", self.itemTable.uniqueID, v);
						end;
					end);
				end;
			end;
			
			menu:Open();
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
		self.itemTable:OnPanelThink(self, "INVENTORY");
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
	self.infoLabel:SetPos( 36, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("aura_InventoryItem", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumWeight = openAura.inventory:GetMaximumWeight();
	local colorWhite = openAura.option:GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	
	self.weight = vgui.Create("DLabel", self);
	self.weight:SetText("N/A");
	self.weight:SetTextColor(colorWhite);
	self.weight:SizeToContents();
	self.weight:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = openAura.inventory:GetMaximumWeight();
		local inventoryWeight = openAura.inventory:GetWeight();
		
		local color = Color(100, 100, 100, 255);
		local width = math.Clamp( (spaceUsed:GetWide() / maximumWeight) * inventoryWeight, 0, spaceUsed:GetWide() );
		local red = math.Clamp( (255 / maximumWeight) * inventoryWeight, 0, 255) ;
		
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
	self.weight:SetText(openAura.inventory:GetWeight().."/"..openAura.inventory:GetMaximumWeight().."kg");
	self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2);
	self.weight:SizeToContents();
end;
	
vgui.Register("aura_InventoryWeight", PANEL, "DPanel");