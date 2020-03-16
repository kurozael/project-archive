--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle( openAura.option:GetKey("name_business") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	self.isBusinessPanel = true;
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local categories = {};
	local items = {};
	
	for k, v in pairs( openAura.item:GetAll() ) do
		if (!v.isBaseItem and v.business and v.cost and v.batch) then
			if ( openAura:HasObjectAccess(openAura.Client, v) ) then
				if ( openAura.plugin:Call("PlayerCanSeeBusinessItem", v.uniqueID) ) then
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
	
	openAura.plugin:Call("PlayerBusinessRebuilt", self, categories);
	
	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local categoryForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v.items, function(a, b)
				if (openAura.item.stored[a].cost == openAura.item.stored[b].cost) then
					return openAura.item.stored[a].name < openAura.item.stored[b].name;
				else
					return openAura.item.stored[a].cost > openAura.item.stored[b].cost;
				end;
			end);
			
			for k2, v2 in pairs(v.items) do
				self.currentItem = v2;
				panelList:AddItem( vgui.Create("aura_BusinessItem", self) );
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
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("You do not have access to the "..openAura.option:GetKey("name_business", true).." menu!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
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

vgui.Register("aura_Business", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local customData = self:GetParent().customData or {};
	local toolTip = nil;
	
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
	
	if (customData.cooldown) then
		self.spawnIcon:SetCooldown(
			customData.cooldown.expireTime,
			customData.cooldown.textureID
		);
	end;
	
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
	
vgui.Register("aura_BusinessCustom", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 32);
	self.itemTable = table.Copy( openAura.item:Get(self:GetParent().currentItem) );
	
	openAura.plugin:Call("PlayerAdjustBusinessItemTable", self.itemTable);
	
	if (self.itemTable.OnInitialize) then
		self.itemTable:OnInitialize(self, "BUSINESS");
	end;
	
	local model, skin = openAura.item:GetIconInfo(self.itemTable);
	local curTime = CurTime();
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(36, 2);
	
	self.infoLabel = vgui.Create("DLabel", self);
	self.infoLabel:SetPos(36, 2);
	
	self.spawnIcon = openAura:CreateColoredSpawnIcon(self);
	self.spawnIcon:SetColor(self.itemTable.color);
	
	if (openAura.OrderCooldown and curTime < openAura.OrderCooldown) then
		self.spawnIcon:SetCooldown(openAura.OrderCooldown);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.itemTable.OnPanelSelected) then
			self.itemTable:OnPanelSelected(self, "BUSINESS");
		end;
		
		openAura:RunCommand("OrderShipment", self.itemTable.uniqueID);
	end;
	
	self.spawnIcon:SetModel(model, skin);
	self.spawnIcon:SetToolTip("");
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	local description = self.itemTable.description;
	local toolTip = "";
	local cost = self.itemTable.cost * self.itemTable.batch;
	local name = self.itemTable.batch.." "..self.itemTable.name;
	
	if (cost != 0) then
		cost = FORMAT_CASH(cost);
	else
		cost = "Free";
	end;
	
	if (self.itemTable.batch > 1) then
		name = self.itemTable.batch.." "..self.itemTable.plural;
	end;
	
	if (self.itemTable.OnPanelThink) then
		self.itemTable:OnPanelThink(self, "BUSINESS");
	end;
	
	if (self.itemTable.GetClientSideName) then
		if (self.itemTable.batch > 1) then
			if ( self.itemTable:GetClientSideName(true) ) then
				name = self.itemTable.batch.." "..self.itemTable:GetClientSideName(true);
			else
				name = self.itemTable.batch.." "..self.itemTable.plural;
			end;
		elseif ( self.itemTable:GetClientSideName() ) then
			name = self.itemTable.batch.." "..self.itemTable:GetClientSideName();
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
	
	local customText = openAura.plugin:Call("GetCustomBusinessInfoLabel", self, self.itemTable);
	
	if (customText) then
		cost = customText;
	end;
	
	self.nameLabel:SetText(name);
	self.nameLabel:SizeToContents();
	self.infoLabel:SetText(cost);
	self.infoLabel:SizeToContents();
	self.infoLabel:SetPos( self.infoLabel.x, 30 - self.infoLabel:GetTall() );
end;
	
vgui.Register("aura_BusinessItem", PANEL, "DPanel");