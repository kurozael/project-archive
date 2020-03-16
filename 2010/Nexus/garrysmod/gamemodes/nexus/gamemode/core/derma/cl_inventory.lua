--[[
Name: "cl_inventory.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( nexus.menu.GetWidth(), nexus.menu.GetHeight() );
	self:SetTitle( nexus.schema.GetOption("name_inventory") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	nexus.inventory.panel = self;
	nexus.inventory.panel:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local label = vgui.Create("nx_InfoText", self);
		label:SetText("To view an item's options, click on its spawn icon.");
		label:SetInfoColor("blue");
	self.panelList:AddItem(label);
	
	self.weightForm = vgui.Create("DForm", self);
	self.weightForm:SetPadding(4);
	self.weightForm:SetName("Weight");
	self.weightForm:AddItem( vgui.Create("nx_InventoryWeight", self) );
	
	local inventoryCategories = {};
	local equippedCategories = {};
	local inventoryItems = {};
	local equippedItems = {};
	
	for k, v in pairs( nexus.inventory.GetAll() ) do
		local itemTable = nexus.item.Get(k);
		
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
	
	for k, v in pairs( nexus.item.GetAll() ) do
		local category = v.category;
		
		if (v.equippedCategory) then
			category = v.equippedCategory;
		end;
		
		if ( v.HasPlayerEquipped and v:HasPlayerEquipped(g_LocalPlayer) ) then
			equippedItems[category] = equippedItems[category] or {};
			equippedItems[category][#equippedItems[category] + 1] = v;
		end;
	end;
	
	for k, v in pairs(equippedItems) do
		equippedCategories[#equippedCategories + 1] = {
			category = k,
			items = v
		};
	end;
	
	for k, v in pairs(inventoryItems) do
		inventoryCategories[#inventoryCategories + 1] = {
			category = k,
			items = v
		};
	end;
	
	table.sort(equippedCategories, function(a, b)
		return a.category < b.category;
	end);
	
	table.sort(inventoryCategories, function(a, b)
		return a.category < b.category;
	end);
	
	nexus.mount.Call("PlayerInventoryRebuilt", self, inventoryCategories);
	
	if (self.weightForm) then
		self.panelList:AddItem(self.weightForm);
	end;
	
	if (#equippedCategories > 0) then
		self.equippedForm = vgui.Create("DForm", self);
		self.equippedForm:SetName("Equipment");
		self.equippedForm:SetPadding(4);
		
		for k, v in ipairs(equippedCategories) do
			local categoryForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v.items, function(a, b)
				return a.name < b.name;
			end);
			
			for k2, v2 in pairs(v.items) do
				local model, skin = nexus.item.GetIconInfo(v2);
				
				self.customData = {
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
								NEXUS:StartDataStream( "UnequipItem", {v2.uniqueID, arguments} );
							else
								NEXUS:StartDataStream("UnequipItem", v2.uniqueID);
							end;
						end);
					else
						NEXUS:StartDataStream("UnequipItem", v2.uniqueID);
					end;
				end;
				
				panelList:AddItem( vgui.Create("nx_InventoryCustom", self) ) ;
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			categoryForm:SetName(v.category);
			categoryForm:AddItem(panelList);
			categoryForm:SetPadding(4);
			
			self.equippedForm:AddItem(categoryForm);
		end;
		
		self.panelList:AddItem(self.equippedForm);
	end;
	
	if (#inventoryCategories > 0) then
		self.inventoryForm = vgui.Create("DForm", self);
		self.inventoryForm:SetName( nexus.schema.GetOption("name_inventory") );
		self.inventoryForm:SetPadding(4);
		
		for k, v in ipairs(inventoryCategories) do
			local categoryForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v.items, function(a, b)
				return a[2] < b[2];
			end);
			
			for k2, v2 in pairs(v.items) do
				self.currentItem = v2[1];
				
				panelList:AddItem( vgui.Create("nx_InventoryItem", self) ) ;
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			categoryForm:SetName(v.category);
			categoryForm:AddItem(panelList);
			categoryForm:SetPadding(4);
			
			self.inventoryForm:AddItem(categoryForm);
		end;
		
		self.panelList:AddItem(self.inventoryForm);
	end;

	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (nexus.menu.GetActivePanel() == self) then
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

vgui.Register("nx_Inventory", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local customData = self:GetParent().customData or {};
	local toolTip;
	
	if (customData.information) then
		if (type(customData.information) == "number") then
			customData.information = customData.information.."kg";
		end;
	end;
	
	if (customData.description) then
		toolTip = nexus.config.Parse(customData.description);
	end;
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	self.nameLabel:SetText(customData.name);
	self.nameLabel:SizeToContents();
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	self.infoLabel:SetText(customData.information);
	self.infoLabel:SizeToContents();
	
	self.spawnIcon = NEXUS:CreateColoredSpawnIcon(self);
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
	
vgui.Register("nx_InventoryCustom", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local destroyName = nexus.schema.GetOption("name_destroy");
	local dropName = nexus.schema.GetOption("name_drop");
	local useName = nexus.schema.GetOption("name_use");
	
	self:SetSize(self:GetParent():GetWide(), 32);
	
	self.item = table.Copy( nexus.item.Get(self:GetParent().currentItem) );
	self.amount = nexus.inventory.GetAll()[self.item.uniqueID];
	
	if (self.item.GetLocalAmount) then
		self.amount = self.item:GetLocalAmount(self.amount);
	end;
	
	if (self.item.OnInitialize) then
		self.item:OnInitialize(self, "INVENTORY");
	end;
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = NEXUS:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.item.color);
	
	-- Called when the spawn icon's menu should be opened.
	self.spawnIcon.OpenMenu = function(spawnIcon)
		if (self.item.OnHandleRightClick) then
			local customFunction = self.item:OnHandleRightClick();
			
			if (customFunction and customFunction != "Use") then
				if ( self.item.customFunctions
				and table.HasValue(self.item.customFunctions, customFunction) ) then
					if (self.item.OnCustomFunction) then
						self.item:OnCustomFunction(v);
					end;
				end;
				
				RunConsoleCommand( "nx", "InvAction", self.item.uniqueID, string.lower(customFunction) );
				
				spawnIcon.animPress:Start(0.2);
				
				return;
			end;
		end;
		
		if (self.item.OnUse) then
			if (self.item.OnHandleUse) then
				self.item:OnHandleUse(function()
					NEXUS:RunCommand("InvAction", self.item.uniqueID, "use");
				end);
			else
				NEXUS:RunCommand("InvAction", self.item.uniqueID, "use");
			end;
			
			spawnIcon.animPress:Start(0.2);
		end;
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local itemFunctions = {};
		
		if (self.item.OnPanelSelected) then
			self.item:OnPanelSelected(self, "INVENTORY");
		end;
		
		if (self.item.OnUse) then
			itemFunctions[#itemFunctions + 1] = self.item.useText or useName;
		end;
		
		if (self.item.OnDrop) then
			itemFunctions[#itemFunctions + 1] = self.item.dropText or dropName;
		end;
		
		if (self.item.OnDestroy) then
			itemFunctions[#itemFunctions + 1] = self.item.destroyText or destroyName;
		end;
		
		if (self.item.customFunctions) then
			for k, v in ipairs(self.item.customFunctions) do
				itemFunctions[#itemFunctions + 1] = v;
			end;
		end;
		
		if (self.item.OnEditFunctions) then
			self.item:OnEditFunctions(itemFunctions);
		end;
		
		nexus.mount.Call("PlayerAdjustItemFunctions", self.item, itemFunctions);
		
		NEXUS:ValidateTableKeys(itemFunctions);
		
		table.sort(itemFunctions, function(a, b)
			return a < b;
		end);
		
		if (#itemFunctions > 0) then
			local menu = DermaMenu();
			
			for k, v in pairs(itemFunctions) do
				if ( (!self.item.useText and v == "Use") or (self.item.useText and v == self.item.useText) ) then
					menu:AddOption(v, function()
						if (self.item) then
							if (self.item.OnHandleUse) then
								self.item:OnHandleUse(function()
									NEXUS:RunCommand("InvAction", self.item.uniqueID, "use");
								end);
							else
								NEXUS:RunCommand("InvAction", self.item.uniqueID, "use");
							end;
						end;
					end);
				elseif ( (!self.item.dropText and v == "Drop") or (self.item.dropText and v == self.item.dropText) ) then
					menu:AddOption(v, function()
						if (self.item) then
							NEXUS:RunCommand("InvAction", self.item.uniqueID, "drop");
						end;
					end);
				elseif ( (!self.item.destroyText and v == "Destroy") or (self.item.destroyText and v == self.item.destroyText) ) then
					local subMenu = menu:AddSubMenu(v);
					
					subMenu:AddOption("Yes", function()
						if (self.item) then
							NEXUS:RunCommand("InvAction", self.item.uniqueID, "destroy");
						end;
					end);
					
					subMenu:AddOption("No", function() end);
				else
					if (self.item.OnCustomFunction) then
						self.item:OnCustomFunction(v);
					end;
					
					menu:AddOption(v, function()
						if (self.item) then
							RunConsoleCommand("nx", "InvAction", self.item.uniqueID, v);
						end;
					end);
				end;
			end;
			
			menu:Open();
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
		self.item:OnPanelThink(self, "INVENTORY");
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
	self.infoLabel:SetPos( 36, 30 - self.infoLabel:GetTall() );
end;

vgui.Register("nx_InventoryItem", PANEL, "DPanel");

local PANEL = {};
local GRADIENT = surface.GetTextureID("gui/gradient_up");

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumWeight = nexus.inventory.GetMaximumWeight();
	local colorWhite = nexus.schema.GetColor("white");
	
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	
	self.weight = vgui.Create("DLabel", self);
	self.weight:SetText("N/A");
	self.weight:SetTextColor(colorWhite);
	self.weight:SizeToContents();
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = nexus.inventory.GetMaximumWeight();
		local inventoryWeight = nexus.inventory.GetWeight();
		
		local width = math.Clamp( (spaceUsed:GetWide() / maximumWeight) * inventoryWeight, 0, spaceUsed:GetWide() );
		local red = math.Clamp( (255 / maximumWeight) * inventoryWeight, 0, 255) ;
		
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
	self.weight:SetText(nexus.inventory.GetWeight().."/"..nexus.inventory.GetMaximumWeight().."kg");
	self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2);
	self.weight:SizeToContents();
end;
	
vgui.Register("nx_InventoryWeight", PANEL, "DPanel");