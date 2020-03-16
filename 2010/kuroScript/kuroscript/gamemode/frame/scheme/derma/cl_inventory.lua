--[[
Name: "cl_inventory.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, kuroScript.menu.height);
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	-- Set some information.
	kuroScript.inventory.panel = self;
	kuroScript.inventory.panel:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	self.weightForm = vgui.Create("DForm", self);
	self.weightForm:SetPadding(4);
	self.weightForm:SetName("Weight");
	self.weightForm:AddItem( vgui.Create("ks_InventoryWeight", self) );
	
	-- Set some information.
	self.inventoryForm = vgui.Create("DForm", self);
	self.inventoryForm:SetName("Inventory");
	self.inventoryForm:SetPadding(4);
	
	-- Set some information.
	local categories = {};
	local items = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.inventory.stored) do
		local itemTable = kuroScript.item.Get(k);
		
		-- Check if a statement is true.
		if (itemTable) then
			local category = itemTable.category;
			
			-- Set some information.
			items[category] = items[category] or {};
			items[category][#items[category] + 1] = k;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(items) do
		categories[#categories + 1] = { category = k, items = v };
	end;
	
	-- Sort the categories.
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	-- Call a gamemode hook.
	hook.Call("PlayerInventoryRebuilt", kuroScript.frame, self, categories);
	
	-- Check if a statement is true.
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory", self);
			local panelList = vgui.Create("DPanelList", self);
			
			-- Sort the items.
			table.sort(v.items, function(a, b)
				return kuroScript.item.stored[a].name > kuroScript.item.stored[b].name;
			end);
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v.items) do
				self.currentItem = v2;
				
				-- Add an item to the panel list.
				panelList:AddItem( vgui.Create("ks_InventoryItem", self) ) ;
			end;
			
			-- Set some information.
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			-- Set some information.
			collapsibleCategory:SetLabel(v.category);
			collapsibleCategory:SetPadding(4);
			collapsibleCategory:SetContents(panelList);
			collapsibleCategory:SetCookieName("ks_Inventory_"..v.category);
			
			-- Add an item to the panel list.
			self.inventoryForm:AddItem(collapsibleCategory);
		end;
	else
		local label = vgui.Create("ks_InventoryText", self);
		
		-- Set some information.
		label:SetText("You do not have any items in your inventory.");
		label:SetTextColor(COLOR_WHITE);
		label:SizeToContents();
		
		-- Add an item to the form.
		self.inventoryForm:AddItem(label);
		self.inventoryForm:SetName("Information");
	end;
	
	-- Add an item to the panel list.
	self.panelList:AddItem(self.weightForm);
	self.panelList:AddItem(self.inventoryForm);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (kuroScript.menu.GetActiveTab() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected as a tab.
function PANEL:OnTabSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("ks_Inventory", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, 42);
	self:SetPos(1, 5);
	
	-- Set some information.
	self.itemFunctions = {};
	self.item = table.Copy( kuroScript.item.Get(self:GetParent().currentItem) );
	
	-- Check if a statement is true.
	if (self.item.OnInitialize) then
		self.item:OnInitialize();
	end;
	
	-- Set some information.
	self.name = vgui.Create("DLabel", self);
	self.name:SetText(kuroScript.inventory.stored[self.item.uniqueID].." "..self.item.name);
	self.name:SizeToContents();
	self.name:SetTextColor(COLOR_WHITE);
	
	-- Check if a statement is true.
	if (kuroScript.inventory.stored[self.item.uniqueID] > 1) then
		self.name:SetText(kuroScript.inventory.stored[self.item.uniqueID].." "..self.item.plural);
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
	
	-- Check if a statement is true.
	if (self.item.OnUse) then self.itemFunctions[#self.itemFunctions + 1] = self.item.useText or "Use"; end;
	if (self.item.OnDrop) then self.itemFunctions[#self.itemFunctions + 1] = self.item.dropText or "Drop"; end;
	if (self.item.OnDestroy) then self.itemFunctions[#self.itemFunctions + 1] = self.item.destroyText or "Destroy"; end;
	
	-- Check if a statement is true.
	if (self.item.customFunctions) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(self.item.customFunctions) do
			self.itemFunctions[#self.itemFunctions + 1] = v;
		end;
	end;
	
	-- Check if a statement is true.
	if (self.item.OnEditFunctions) then
		self.item:OnEditFunctions(self.itemFunctions);
		
		-- Validate the function keys.
		kuroScript.frame:ValidateTableKeys(self.itemFunctions);
	end;
	
	-- Sort the item functions.
	table.sort(self.itemFunctions, function(a, b) return a < b; end);
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Called when the spawn icon's menu should be opened.
	self.spawnIcon.OpenMenu = function(spawnIcon)
		if (self.item.OnUse) then
			RunConsoleCommand("ks", "inventory", self.item.uniqueID, "use");
			
			-- Start the press animation.
			spawnIcon.animPress:Start(0.2);
		end;
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (#self.itemFunctions > 0) then
			local menu = DermaMenu();
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in pairs(self.itemFunctions) do
				if ( (!self.item.useText and v == "Use") or (self.item.useText and v == self.item.useText) ) then
					menu:AddOption(v, function()
						RunConsoleCommand("ks", "inventory", self.item.uniqueID, "use");
					end);
				elseif ( (!self.item.dropText and v == "Drop") or (self.item.dropText and v == self.item.dropText) ) then
					menu:AddOption(v, function()
						RunConsoleCommand("ks", "inventory", self.item.uniqueID, "drop");
					end);
				elseif ( (!self.item.destroyText and v == "Destroy") or (self.item.destroyText and v == self.item.destroyText) ) then
					menu:AddOption(v, function()
						RunConsoleCommand("ks", "inventory", self.item.uniqueID, "destroy");
					end);
				else
					menu:AddOption(v, function()
						RunConsoleCommand( "ks", "inventory", self.item.uniqueID, string.lower(v) );
					end);
				end;
			end;
			
			-- Open the menu.
			menu:Open();
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
		if (kuroScript.inventory.stored[self.item.uniqueID] > 1) then
			if ( self.item:GetClientSideName(true) ) then
				self.name:SetText( kuroScript.inventory.stored[self.item.uniqueID].." "..self.item:GetClientSideName(true) );
			else
				self.name:SetText(kuroScript.inventory.stored[self.item.uniqueID].." "..self.item.plural);
			end;
		else
			if ( self.item:GetClientSideName() ) then
				self.name:SetText( kuroScript.inventory.stored[self.item.uniqueID].." "..self.item:GetClientSideName() );
			else
				self.name:SetText(kuroScript.inventory.stored[self.item.uniqueID].." "..self.item.name);
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
vgui.Register("ks_InventoryItem", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumWeight = kuroScript.inventory.GetMaximumWeight();
	
	-- Set some information.
	self.spaceUsed = vgui.Create("DPanel", self);
	self.spaceUsed:SetPos(1, 1);
	
	-- Called when the panel should be painted.
	function self.spaceUsed.Paint(spaceUsed)
		local maximumWeight = kuroScript.inventory.GetMaximumWeight();
		local inventoryWeight = kuroScript.inventory.GetWeight();
		
		-- Set some information.
		local width = math.Clamp( (spaceUsed:GetWide() / maximumWeight) * inventoryWeight, 0, spaceUsed:GetWide() );
		local red = math.Clamp( (255 / maximumWeight) * inventoryWeight, 0, 255) ;
		
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
vgui.Register("ks_InventoryWeight", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetText("N/A");
	self.label:SetTextColor(COLOR_WHITE);
	self.label:SizeToContents();
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(self:GetWide() / 2 - self.label:GetWide() / 2, self:GetTall() / 2 - self.label:GetTall() / 2);
	self.label:SizeToContents();
end;

-- Set some information.
function PANEL:SetText(text)
	self.label:SetText(text);
end;

-- Set some information.
function PANEL:SetTextColor(color)
	self.label:SetTextColor(color);
end;
	
-- Register the panel.
vgui.Register("ks_InventoryText", PANEL, "DPanel");