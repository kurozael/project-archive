--[[
Name: "cl_attributes.lua".
Product: "nexus".
--]]

local PANEL = {};
local GRADIENT = surface.GetTextureID("gui/gradient_up");

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( nexus.menu.GetWidth(), nexus.menu.GetHeight() );
	self:SetTitle( nexus.schema.GetOption("name_attributes") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	nexus.attributes.panel = self;
	nexus.attributes.panel.boosts = {};
	nexus.attributes.panel.progress = {};
	nexus.attributes.panel.attributes = {};
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local miscellaneous = {};
	local categories = {};
	local attributes = {};
	
	for k, v in pairs( nexus.attribute.GetAll() ) do
		if ( NEXUS:HasObjectAccess(g_LocalPlayer, v) ) then
			if (v.category) then
				local category = v.category;
				
				attributes[category] = attributes[category] or {};
				attributes[category][#attributes[category] + 1] = {k, v.name};
			else
				miscellaneous[#miscellaneous + 1] = {k, v.name};
			end;
		end;
	end;
	
	for k, v in pairs(attributes) do
		categories[#categories + 1] = {
			attributes = v,
			category = k
		};
	end;
	
	table.sort(miscellaneous, function(a, b)
		return a[2] < b[2];
	end);
	
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	if (#categories > 0 or #miscellaneous > 0) then
		local label = vgui.Create("nx_InfoText", self);
			label:SetText("The top bar represents the points and the bottom represents progress.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		local label = vgui.Create("nx_InfoText", self);
			label:SetText("A green bar means that the attribute has been boosted.");
			label:SetInfoColor("green");
			label:SetShowIcon(false);
		self.panelList:AddItem(label);
		
		local label = vgui.Create("nx_InfoText", self);
			label:SetText("A red bar means that the attribute has been hindered.");
			label:SetInfoColor("red");
			label:SetShowIcon(false);
		self.panelList:AddItem(label);
		
		local attributesForm = vgui.Create("DForm", self);
			attributesForm:SetPadding(5);
			attributesForm:SetName( nexus.schema.GetOption("name_attributes") );
		self.panelList:AddItem(attributesForm);
		
		for k, v in ipairs(miscellaneous) do
			self.currentAttribute = v[1];
				attributesForm:AddItem( vgui.Create("nx_AttributesItem", self) ) ;
		end;
		
		for k, v in ipairs(categories) do
			local categoryForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v.attributes, function(a, b)
				return a[2] < b[2];
			end);
			
			for k2, v2 in pairs(v.attributes) do
				self.currentAttribute = v2[1];
					categoryForm:AddItem( vgui.Create("nx_AttributesItem", self) ) ;
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
			label:SetText("You do not have access to any "..nexus.schema.GetOption("name_attributes", true).."!");
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

vgui.Register("nx_Attributes", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.attribute = nexus.attribute.Get(self:GetParent().currentAttribute);
	
	self:SetBackgroundColor( Color(80, 70, 60, 255) );
	self:SetToolTip(self.attribute.description);
	self:SetSize(self:GetParent():GetWide() - 8, 24);
	self:SetPos(4, 4);
	
	self.baseBar = vgui.Create("DPanel", self);
	self.baseBar:SetPos(2, 2);
	self.baseBar:SetSize(self:GetWide() - 4, 12);
	
	self.progressBar = vgui.Create("DPanel", self);
	self.progressBar:SetPos(2, 14);
	self.progressBar:SetSize(self:GetWide() - 4, 8);
	
	self.percentageText = vgui.Create("DLabel", self);
	self.percentageText:SetText("0%");
	self.percentageText:SetTextColor( nexus.schema.GetColor("white") );
	self.percentageText:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	self.percentageText:SizeToContents();
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.attribute.name);
	self.nameLabel:SetTextColor( nexus.schema.GetColor("white") );
	self.nameLabel:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	self.nameLabel:SizeToContents();
	
	self.percentageText:SetPos(
		self:GetWide() - self.percentageText:GetWide() - 16,
		self:GetTall() / 2 - self.percentageText:GetTall() / 2
	);
	
	self.nameLabel:SetPos(
		(self:GetWide() / 2) - (self.nameLabel:GetWide() / 2),
		(self:GetTall() / 2) - (self.nameLabel:GetTall() / 2)
	);

	-- Called when the panel should be painted.
	function self.baseBar.Paint(baseBar)
		local hinderColor = Color(179, 46, 49, 255);
		local boostColor = Color(139, 215, 113, 255);
		local attributes = nexus.attributes.panel.attributes;
		local mainColor = Color(139, 174, 179, 255);
		local frameTime = FrameTime() * 10;
		local uniqueID = self.attribute.uniqueID;
		local curTime = CurTime();
		local default = nexus.attributes.stored[uniqueID];
		local boosts = nexus.attributes.panel.boosts;
		local boost = 0;
		
		if ( !boosts[uniqueID] ) then
			boosts[uniqueID] = 0;
		end;
		
		if ( !attributes[uniqueID] ) then
			if (default) then
				attributes[uniqueID] = default.amount;
			else
				attributes[uniqueID] = 0;
			end;
		end;
		
		if (default) then
			attributes[uniqueID] = math.Approach(attributes[uniqueID], default.amount, frameTime);
		else
			attributes[uniqueID] = math.Approach(attributes[uniqueID], 0, frameTime);
		end;
		
		if ( nexus.attributes.boosts[uniqueID] ) then
			for k, v in pairs( nexus.attributes.boosts[uniqueID] ) do
				boost = boost + v.amount;
			end;
		end;
		
		if (boost > self.attribute.maximum) then
			boost = self.attribute.maximum;
		elseif (boost < -self.attribute.maximum) then
			boost = -self.attribute.maximum;
		end;
		
		boosts[uniqueID] = math.Approach(boosts[uniqueID], boost, frameTime);
		
		local color = derma.Color("bg_color_sleep", self) or Color(70, 70, 70, 255);
		local width = (baseBar:GetWide() / self.attribute.maximum) * attributes[uniqueID];
		local boostData = {
			negative = boosts[uniqueID] < 0,
			boost = math.abs( boosts[uniqueID] ),
			width = math.ceil( (baseBar:GetWide() / self.attribute.maximum) * math.abs( boosts[uniqueID] ) )
		};
		
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect( 0, 0, baseBar:GetWide(), baseBar:GetTall() );
		
		self:SetPercentageText( self.attribute.maximum, attributes[uniqueID], boosts[uniqueID] );
		
		if (boostData.negative) then
			if (attributes[uniqueID] - boostData.boost < 0) then
				surface.SetDrawColor( NEXUS:UnpackColor(hinderColor) );
				surface.DrawRect( 0, 0, boostData.width, baseBar:GetTall() );
				
				surface.SetDrawColor(100, 100, 100, 100);
				surface.SetTexture(GRADIENT);
				surface.DrawTexturedRect( 0, 0, boostData.width, baseBar:GetTall() );
				
				if ( boostData.width > 1 and boostData.width < (baseBar:GetWide() - 1) ) then
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawRect( boostData.width, 0, 1, baseBar:GetTall() );
				end;
			else
				boostData.width = math.min(boostData.width, width);
				
				surface.SetDrawColor( NEXUS:UnpackColor(mainColor) );
				surface.DrawRect( 0, 0, math.max(width - boostData.width, 0), baseBar:GetTall() );
				surface.SetDrawColor( NEXUS:UnpackColor(hinderColor) );
				surface.DrawRect( math.max(width - boostData.width, 0), 0, boostData.width, baseBar:GetTall() );
				
				surface.SetDrawColor(100, 100, 100, 100);
				surface.SetTexture(GRADIENT);
				surface.DrawTexturedRect( 0, 0, math.max(width - boostData.width, 0) + boostData.width, baseBar:GetTall() );
				
				if ( math.min( math.max(width - boostData.width, 0), baseBar:GetWide() ) < (baseBar:GetWide() - 1) ) then
					if (math.max(width - boostData.width, 0) > 1) then
						surface.SetDrawColor(255, 255, 255, 255);
						surface.DrawRect( math.min( math.max(width - boostData.width, 0), baseBar:GetWide() ), 0, 1, baseBar:GetTall() );
					end;
				end;
				
				if ( math.min( math.max(width - boostData.width, 0), baseBar:GetWide() ) + boostData.width < (baseBar:GetWide() - 1) ) then
					if (boostData.width > 1) then
						surface.SetDrawColor(255, 255, 255, 255);
						surface.DrawRect( math.min( math.max(width - boostData.width, 0) + boostData.width, baseBar:GetWide() ), 0, 1, baseBar:GetTall() );
					end;
				end;
			end;
		else
			surface.SetDrawColor( NEXUS:UnpackColor(mainColor) );
			surface.DrawRect( 0, 0, width, baseBar:GetTall() );
			surface.SetDrawColor( NEXUS:UnpackColor(boostColor) );
			surface.DrawRect( width, 0, math.min( boostData.width, baseBar:GetWide() ), baseBar:GetTall() );
			
			surface.SetDrawColor(100, 100, 100, 100);
			surface.SetTexture(GRADIENT);
			surface.DrawTexturedRect( 0, 0, math.min( width + boostData.width, baseBar:GetWide() ), baseBar:GetTall() );
			
			if ( width > 1 and width < (baseBar:GetWide() - 1) ) then
				surface.SetDrawColor(255, 255, 255, 255);
				surface.DrawRect( width, 0, 1, baseBar:GetTall() );
			end;
			
			if ( width + math.min( boostData.width, baseBar:GetWide() ) < (baseBar:GetWide() - 1) ) then
				if (boostData.width > 1) then
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawRect( width + math.min( boostData.width, baseBar:GetWide() ), 0, 1, baseBar:GetTall() );
				end;
			end;
		end;
	end;
	
	-- Called when the panel should be painted.
	function self.progressBar.Paint(progressBar)
		local progressColor = Color(150, 130, 120, 255);
		local uniqueID = self.attribute.uniqueID;
		local progress = nexus.attributes.panel.progress;
		local default = nexus.attributes.stored[uniqueID];
		
		if ( !progress[uniqueID] ) then
			if (default) then
				progress[uniqueID] = default.progress;
			else
				progress[uniqueID] = 0;
			end;
		end;
		
		if (default) then
			progress[uniqueID] = math.Approach(progress[uniqueID], default.progress, 1);
		else
			progress[uniqueID] = math.Approach(progress[uniqueID], 0, FrameTime() * 2);
		end;
		
		local width = math.ceil( (progressBar:GetWide() / 100) * progress[uniqueID] );
		local color = table.Copy( derma.Color("bg_color", self) or Color(100, 100, 100, 255) );
		
		if (color) then
			color.r = math.min(color.r + 25, 255);
			color.g = math.min(color.g + 25, 255);
			color.b = math.min(color.b + 25, 255);
		end;
		
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect( 0, 0, progressBar:GetWide(), progressBar:GetTall() );
		surface.SetDrawColor( NEXUS:UnpackColor(progressColor) );
		surface.DrawRect( 0, 0, width, progressBar:GetTall() );
		
		surface.SetDrawColor(100, 100, 100, 100);
		surface.SetTexture(GRADIENT);
		surface.DrawTexturedRect( 0, 0, width, progressBar:GetTall() );
		
		if ( width > 1 and width < (progressBar:GetWide() - 1) ) then
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawRect( width, 0, 1, progressBar:GetTall() );
		end;
	end;
end;

-- A function to set the panel's percentage text.
function PANEL:SetPercentageText(maximum, default, boost)
	local percentage = math.Clamp(math.Round( (100 / maximum) * (default + boost) ), -100, 100);
	
	self.percentageText:SetText(percentage.."%");
	self.percentageText:SizeToContents();
	self.percentageText:SetPos(self:GetWide() - self.percentageText:GetWide() - 16, self.percentageText.y);
end;

-- Called when the panel is painted.
function PANEL:Paint()
	local width, height = self:GetSize();
	local x, y = 0, 0;
	
	NEXUS:DrawRoundedGradient( 4, x, y, width, height, self:GetBackgroundColor() );
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self.progressBar:SetSize(self:GetWide() - 4, 8);
	self.baseBar:SetSize(self:GetWide() - 4, 12);
	self.nameLabel:SetPos(
		(self:GetWide() / 2) - (self.nameLabel:GetWide() / 2),
		(self:GetTall() / 2) - (self.nameLabel:GetTall() / 2)
	);
end;
	
vgui.Register("nx_AttributesItem", PANEL, "DPanel");