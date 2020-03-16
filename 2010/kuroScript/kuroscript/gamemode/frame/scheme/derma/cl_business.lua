--[[
Name: "cl_business.lua".
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
	
	-- Rebuild the panel.
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	self.businessForm = vgui.Create("DForm");
	self.businessForm:SetName("Business");
	self.businessForm:SetPadding(4);
	
	-- Set some information.
	local categories = {};
	local items = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.item.stored) do
		if (v.business and v.cost and v.batch) then
			if ( kuroScript.frame:HasObjectAccess(g_LocalPlayer, v) ) then
				if ( hook.Call("PlayerCanSeeBusinessItem", kuroScript.frame, v.uniqueID) ) then
					items[v.category] = items[v.category] or {};
					items[v.category][#items[v.category] + 1] = k;
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
	
	-- Call a gamemode hook.
	hook.Call("PlayerBusinessRebuilt", kuroScript.frame, self, categories);
	
	-- Check if a statement is true.
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory", self);
			local panelList = vgui.Create("DPanelList", self);
			
			-- Sort the items.
			table.sort(v.items, function(a, b)
				if (kuroScript.item.stored[a].cost == kuroScript.item.stored[b].cost) then
					return kuroScript.item.stored[a].name < kuroScript.item.stored[b].name;
				else
					return kuroScript.item.stored[a].cost > kuroScript.item.stored[b].cost;
				end;
			end);
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v.items) do
				self.currentItem = v2;
				
				-- Add an item to the panel list.
				panelList:AddItem( vgui.Create("ks_BusinessItem", self) );
			end;
			
			-- Set some information.
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			-- Set some information.
			collapsibleCategory:SetLabel(v.category);
			collapsibleCategory:SetPadding(4);
			collapsibleCategory:SetContents(panelList);
			collapsibleCategory:SetCookieName("ks_Business_"..v.category);
			
			-- Add an item to the form.
			self.businessForm:AddItem(collapsibleCategory);
		end;
	else
		local label = vgui.Create("ks_BusinessText");
		
		-- Set some information.
		label:SetText("You do not have access to order any items for your business.");
		label:SetTextColor(COLOR_WHITE);
		
		-- Add an item to the form.
		self.businessForm:AddItem(label);
	end;
	
	-- Add an item to the panel list.
	self.panelList:AddItem(self.businessForm);
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
vgui.Register("ks_Business", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local customData = self:GetParent().customData or {};
	local description = customData.description or "";
	local callback = customData.callback or function() end;
	local model = customData.model or "";
	local skin = customData.skin or nil;
	local name = customData.name or "";
	local cost = customData.cost or 0;
	
	-- Set some information.
	self:SetSize(kuroScript.menu.width, 42);
	
	-- The name of the item.
	self.name = vgui.Create("DLabel", self);
	self.name:SetText(name);
	self.name:SetTextColor(COLOR_WHITE);
	
	-- Set some information.
	self.information = vgui.Create("DLabel", self);
	self.information:SetTextColor(COLOR_WHITE);
	self.information:SetText( FORMAT_CURRENCY(cost) );
	
	-- Check if a statement is true.
	if (cost == 0) then
		self.information:SetText("Free");
	end;
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		callback();
	end;
	
	-- Set some information.
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip( kuroScript.config.Parse(description) );
	self.spawnIcon:SetIconSize(32);
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
	self.name:SizeToContents();
	self.information:SetPos(x, y + 19);
	self.information:SizeToContents();
end;
	
-- Register the panel.
vgui.Register("ks_BusinessCustom", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, 42);
	
	-- The name of the item.
	self.item = table.Copy( kuroScript.item.Get(self:GetParent().currentItem) );
	self.name = vgui.Create("DLabel", self);
	self.name:SetTextColor(COLOR_WHITE);
	
	-- Call a gamemode hook.
	hook.Call("PlayerAdjustBusinessItemTable", kuroScript.frame, self.item);
	
	-- Check if a statement is true.
	if (self.item.OnInitialize) then
		self.item:OnInitialize();
	end;
	
	-- Set some information.
	local model = self.item.model;
	local skin = self.item.skin;
	local cost = self.item.cost * self.item.batch;
	
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
	
	-- Check if a statement is true.
	if (self.item.batch > 1) then
		self.name:SetText(self.item.batch.." "..self.item.plural);
	else
		self.name:SetText(self.item.batch.." "..self.item.name);
	end;
	
	-- Set some information.
	self.information = vgui.Create("DLabel", self);
	self.information:SetTextColor(COLOR_WHITE);
	self.information:SetText( FORMAT_CURRENCY(cost) );
	
	-- Check if a statement is true.
	if (cost == 0) then
		self.information:SetText("Free");
	end;
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		RunConsoleCommand("ks", "order", self.item.uniqueID);
	end;
	
	-- Set some information.
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip( kuroScript.config.Parse(self.item.description) );
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	if (self.item.GetClientSideName) then
		if (self.item.batch > 1) then
			if ( self.item:GetClientSideName(true) ) then
				self.name:SetText( self.item.batch.." "..self.item:GetClientSideName(true) );
			else
				self.name:SetText(self.item.batch.." "..self.item.plural);
			end;
		else
			if ( self.item:GetClientSideName() ) then
				self.name:SetText( self.item.batch.." "..self.item:GetClientSideName() );
			else
				self.name:SetText(self.item.batch.." "..self.item.name);
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
	self.name:SizeToContents();
	self.information:SetPos(x, y + 19);
	self.information:SizeToContents();
end;
	
-- Register the panel.
vgui.Register("ks_BusinessItem", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
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
vgui.Register("ks_BusinessText", PANEL, "DPanel");