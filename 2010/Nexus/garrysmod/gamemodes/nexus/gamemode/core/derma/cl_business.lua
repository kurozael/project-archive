--[[
Name: "cl_business.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( nexus.menu.GetWidth(), nexus.menu.GetHeight() );
	self:SetTitle( nexus.schema.GetOption("name_business") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local categories = {};
	local items = {};
	
	for k, v in pairs( nexus.item.GetAll() ) do
		if (!v.isBaseItem and v.business and v.cost and v.batch) then
			if ( NEXUS:HasObjectAccess(g_LocalPlayer, v) ) then
				if ( nexus.mount.Call("PlayerCanSeeBusinessItem", v.uniqueID) ) then
					items[v.category] = items[v.category] or {};
					items[v.category][#items[v.category] + 1] = k;
				end;
			end;
		end;
	end;
	
	for k, v in pairs(items) do
		categories[#categories + 1] = {
			category = k,
			items = v
		};
	end;
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	nexus.mount.Call("PlayerBusinessRebuilt", self, categories);
	
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local categoryForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v.items, function(a, b)
				if (nexus.item.GetAll()[a].cost == nexus.item.GetAll()[b].cost) then
					return nexus.item.GetAll()[a].name < nexus.item.GetAll()[b].name;
				else
					return nexus.item.GetAll()[a].cost > nexus.item.GetAll()[b].cost;
				end;
			end);
			
			for k2, v2 in pairs(v.items) do
				self.currentItem = v2;
				
				panelList:AddItem( vgui.Create("nx_BusinessItem", self) );
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			categoryForm:SetName(v.category);
			categoryForm:AddItem(panelList);
			categoryForm:SetPadding(4);
			
			self.panelList:AddItem(categoryForm);
		end;
	else
		local label = vgui.Create("nx_InfoText", self);
			label:SetText("You do not have access to the "..nexus.schema.GetOption("name_business", true).." menu!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
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

vgui.Register("nx_Business", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local customData = self:GetParent().customData or {};
	local toolTip;
	
	if (customData.information) then
		if (type(customData.information) == "number") then
			if (customData.information != 0) then
				customData.information = FORMAT_CASH(customData.information);
			else
				customData.information = "Free";
			end;
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
	
vgui.Register("nx_BusinessCustom", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	self.item = table.Copy( nexus.item.Get(self:GetParent().currentItem) );
	
	nexus.mount.Call("PlayerAdjustBusinessItemTable", self.item);
	
	if (self.item.OnInitialize) then
		self.item:OnInitialize(self, "BUSINESS");
	end;
	
	local model, skin = nexus.item.GetIconInfo(self.item);
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = NEXUS:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.item.color);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.item.OnPanelSelected) then
			self.item:OnPanelSelected(self, "BUSINESS");
		end;
		
		NEXUS:RunCommand("OrderShipment", self.item.uniqueID);
	end;
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	local description = self.item.description;
	local toolTip = "";
	local cost = self.item.cost * self.item.batch;
	local name = self.item.batch.." "..self.item.name;
	
	if (cost != 0) then
		cost = FORMAT_CASH(cost);
	else
		cost = "Free";
	end;
	
	if (self.item.batch > 1) then
		name = self.item.batch.." "..self.item.plural;
	end;
	
	if (self.item.OnPanelThink) then
		self.item:OnPanelThink(self, "BUSINESS");
	end;
	
	if (self.item.GetClientSideName) then
		if (self.item.batch > 1) then
			if ( self.item:GetClientSideName(true) ) then
				name = self.item.batch.." "..self.item:GetClientSideName(true);
			else
				name = self.item.batch.." "..self.item.plural;
			end;
		elseif ( self.item:GetClientSideName() ) then
			name = self.item.batch.." "..self.item:GetClientSideName();
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
	self.infoLabel:SetText(cost);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;
	
vgui.Register("nx_BusinessItem", PANEL, "DPanel");