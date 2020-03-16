--[[
Name: "cl_attributes.lua".
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
	kuroScript.attributes.panel = self;
	kuroScript.attributes.panel.progress = {};
	kuroScript.attributes.panel.attributes = {};
	
	-- Rebuild the panel.
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	local attributesForm = vgui.Create("DForm", self);
	
	-- Set some information.
	attributesForm:SetPadding(5);
	attributesForm:SetName("Attributes");
	
	-- Add an item to the panel list.
	self.panelList:AddItem(attributesForm);
	
	-- Set some information.
	local attributes = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.attribute.stored) do
		if ( kuroScript.frame:HasObjectAccess(g_LocalPlayer, v) ) then
			attributes[#attributes + 1] = {k, v.name};
		end;
	end;
	
	-- Sort the attributes.
	table.sort(attributes, function(a, b) return a[2] < b[2]; end);
	
	-- Check if a statement is true.
	if (#attributes > 0) then
		for k, v in ipairs(attributes) do
			self.currentAttribute = v[1];
			
			-- Add an item to the form.
			attributesForm:AddItem( vgui.Create("ks_AttributesItem", self) ) ;
		end;
	else
		local label = vgui.Create("ks_AttributesText", self);
		
		-- Set some information.
		label:SetText("You do not have access to any attributes.");
		label:SetTextColor(COLOR_WHITE);
		label:SizeToContents();
		
		-- Add an item to the form.
		attributesForm:AddItem(label);
	end;
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
vgui.Register("ks_Attributes", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.attribute = kuroScript.attribute.Get(self:GetParent().currentAttribute);
	
	-- Set some information.
	self:SetToolTip(self.attribute.description);
	self:SetSize(kuroScript.menu.width, 33);
	self:SetPos(1, 5);
	
	-- Set some information.
	self.basePanel = vgui.Create("DPanel", self);
	self.basePanel:SetPos(2, 2);
	self.basePanel:SetSize(self:GetWide() - 4, 20);
	
	-- Set some information.
	self.baseBar = vgui.Create("DPanel", self.basePanel);
	self.baseBar:SetPos(1, 1);
	self.baseBar:SetSize(self:GetWide() - 4, 20);
	
	-- Set some information.
	self.progressPanel = vgui.Create("DPanel", self);
	self.progressPanel:SetPos(2, 21);
	self.progressPanel:SetSize(self:GetWide() - 4, 10);
	
	-- Set some information.
	self.progressBar = vgui.Create("DPanel", self.progressPanel);
	self.progressBar:SetPos(1, 1);
	self.progressBar:SetSize(self:GetWide() - 4, 10);
	
	-- Set some information.
	self.percentageText = vgui.Create("DLabel", self.baseBar);
	self.percentageText:SetText("0%");
	self.percentageText:SetTextColor( Color(255, 255, 255, 255) );
	self.percentageText:SizeToContents();
	
	-- Set some information.
	self.baseText = vgui.Create("DLabel", self.baseBar);
	self.baseText:SetText(self.attribute.name);
	self.baseText:SetTextColor( Color(255, 255, 255, 255) );
	self.baseText:SizeToContents();
	
	-- Set some information.
	local x = self.baseBar:GetWide() / 2 - self.baseText:GetWide() / 2;
	local y = self.baseBar:GetTall() / 2 - self.baseText:GetTall() / 2;
	
	-- Set some information.
	self.percentageText:SetPos(self.baseBar:GetWide() - self.percentageText:GetWide() - 16, y);
	self.baseText:SetPos(x, y);

	-- Called when the panel should be painted.
	function self.baseBar.Paint(baseBar)
		local attributes = kuroScript.attributes.panel.attributes;
		local uniqueID = self.attribute.uniqueID;
		local curTime = CurTime();
		local default = kuroScript.attributes.stored[uniqueID];
		local boost = 0;
		local k, v;
		
		-- Check if a statement is true.
		if ( !attributes[uniqueID] ) then
			if (default) then
				attributes[uniqueID] = default.amount;
			else
				attributes[uniqueID] = 0;
			end;
		end;
		
		-- Check if a statement is true.
		if (default) then
			attributes[uniqueID] = math.Approach(attributes[uniqueID], default.amount, 1);
		else
			attributes[uniqueID] = math.Approach(attributes[uniqueID], 0, FrameTime() * 2);
		end;
		
		-- Check if a statement is true.
		if ( kuroScript.attributes.boosts[uniqueID] ) then
			for k, v in pairs( kuroScript.attributes.boosts[uniqueID] ) do
				if (v.expire and v.finish) then
					local timeLeft = v.finish - curTime;
					
					-- Check if a statement is true.
					if (timeLeft >= 0) then
						if (v.amount < 0) then
							boost = boost - math.max( (math.abs(v.amount) / v.expire) * timeLeft, 0 );
						else
							boost = boost + math.max( (v.amount / v.expire) * timeLeft, 0 );
						end;
					end;
				else
					boost = boost + v.amount;
				end;
			end;
		end;
		
		-- Set some information.
		self:SetPercentageText(self.attribute.maximum, attributes[uniqueID], boost);
		
		-- Set some information.
		local color = derma.Color("bg_color_sleep", self) or Color(70, 70, 70, 255);
		local width = (baseBar:GetWide() / self.attribute.maximum) * attributes[uniqueID];
		local boostData = {
			negative = boost < 0,
			boost = math.abs(boost),
			width = (baseBar:GetWide() / self.attribute.maximum) * math.abs(boost)
		};
		
		-- Set some information.
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect( 0, 0, baseBar:GetWide(), baseBar:GetTall() );
		
		-- Check if a statement is true.
		if (boostData.negative) then
			boostData.width = math.min(boostData.width, width);
			
			-- Set some information.
			surface.SetDrawColor(200, 100, 50, 255);
			surface.DrawRect( 0, 0, math.max(width - boostData.width, 0), baseBar:GetTall() );
			surface.SetDrawColor(100, 200, 255, 255);
			surface.DrawRect( math.max(width - boostData.width, 0), 0, boostData.width, baseBar:GetTall() );
			
			-- Check if a statement is true.
			if ( math.min( math.max(width - boostData.width, 0), baseBar:GetWide() ) < (baseBar:GetWide() - 1) ) then
				if (math.max(width - boostData.width, 0) > 1) then
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawRect( math.min( math.max(width - boostData.width, 0), baseBar:GetWide() ), 0, 1, baseBar:GetTall() );
				end;
			end;
			
			-- Check if a statement is true.
			if ( math.min( math.max(width - boostData.width, 0), baseBar:GetWide() ) + boostData.width < (baseBar:GetWide() - 1) ) then
				if (boostData.width > 1) then
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawRect( math.min( math.max(width - boostData.width, 0) + boostData.width, baseBar:GetWide() ), 0, 1, baseBar:GetTall() );
				end;
			end;
		else
			surface.SetDrawColor(200, 100, 50, 255);
			surface.DrawRect( 0, 0, width, baseBar:GetTall() );
			surface.SetDrawColor(100, 200, 255, 255);
			surface.DrawRect( width, 0, math.min( boostData.width, baseBar:GetWide() ), baseBar:GetTall() );
			
			-- Check if a statement is true.
			if ( width > 1 and width < (baseBar:GetWide() - 1) ) then
				surface.SetDrawColor(255, 255, 255, 255);
				surface.DrawRect( width, 0, 1, baseBar:GetTall() );
			end;
			
			-- Check if a statement is true.
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
		local uniqueID = self.attribute.uniqueID;
		local progress = kuroScript.attributes.panel.progress;
		local default = kuroScript.attributes.stored[uniqueID];
		local k, v;
		
		-- Check if a statement is true.
		if ( !progress[uniqueID] ) then
			if (default) then
				progress[uniqueID] = default.progress;
			else
				progress[uniqueID] = 0;
			end;
		end;
		
		-- Check if a statement is true.
		if (default) then
			progress[uniqueID] = math.Approach(progress[uniqueID], default.progress, 1);
		else
			progress[uniqueID] = math.Approach(progress[uniqueID], 0, FrameTime() * 2);
		end;
		
		-- Set some information.
		local width = (progressBar:GetWide() / 100) * progress[uniqueID];
		local color = table.Copy( derma.Color("bg_color", self) or Color(100, 100, 100, 255) );
		
		-- Check if a statement is true.
		if (color) then
			color.r = math.min(color.r + 25, 255);
			color.g = math.min(color.g + 25, 255);
			color.b = math.min(color.b + 25, 255);
		end;
		
		-- Set some information.
		surface.SetDrawColor(color.r, color.g, color.b, color.a);
		surface.DrawRect( 0, 0, progressBar:GetWide(), progressBar:GetTall() );
		surface.SetDrawColor(255, 50, 50, 255);
		surface.DrawRect( 0, 0, width, progressBar:GetTall() );
		
		-- Check if a statement is true.
		if ( width > 1 and width < (progressBar:GetWide() - 1) ) then
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawRect( width, 0, 1, progressBar:GetTall() );
		end;
	end;
end;

-- A function to set the panel's percentage text.
function PANEL:SetPercentageText(maximum, default, boost)
	local percentage = math.Clamp(math.Round( (100 / maximum) * (default + boost) ), 0, 100);
	
	-- Set some information.
	self.percentageText:SetText(percentage.."%");
	self.percentageText:SizeToContents();
	
	-- Set some information.
	self.percentageText:SetPos(self.baseBar:GetWide() - self.percentageText:GetWide() - 16, self.percentageText.y);
end;

-- Called each frame.
function PANEL:Think()
	self.progressPanel:SetSize(self:GetWide() - 4, 10);
	self.progressBar:SetSize(self:GetWide() - 6, 8);
	self.basePanel:SetSize(self:GetWide() - 4, 20);
	self.baseBar:SetSize(self:GetWide() - 6, 18);
end;
	
-- Register the panel.
vgui.Register("ks_AttributesItem", PANEL, "DPanel");

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
vgui.Register("ks_AttributesText", PANEL, "DPanel");