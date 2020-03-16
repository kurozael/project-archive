--[[
Name: "cl_overwatch.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( nexus.menu.GetWidth(), nexus.menu.GetHeight() );
	self:SetTitle( nexus.schema.GetOption("name_overwatch") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	nexus.overwatch.panel = self;
	nexus.overwatch.panel.overwatch = nil;
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	if (self.overwatch) then
		self.navigationForm = vgui.Create("DForm", self);
			self.navigationForm:SetPadding(4);
			self.navigationForm:SetName("Navigation");
		self.panelList:AddItem(self.navigationForm);
	
		local backButton = vgui.Create("DButton", self);
			backButton:SetText("Back to Navigation");
			backButton:SetWide( self:GetParent():GetWide() );
			
			-- Called when the button is clicked.
			function backButton.DoClick(button)
				self.overwatch = nil;
				self:Rebuild();
			end;
		self.navigationForm:AddItem(backButton);
		
		local overwatch = nexus.overwatch.Get(self.overwatch);
		
		if (overwatch) then
			if (overwatch.doesCreateForm) then
				self.overwatchForm = vgui.Create("DForm", self);
					self.overwatchForm:SetPadding(4);
					self.overwatchForm:SetName(overwatch.name);
				self.panelList:AddItem(self.overwatchForm);
			end;
			
			overwatch:OnDisplay(self, self.overwatchForm);
		end;
	else
		local label = vgui.Create("nx_InfoText", self);
			label:SetText("The Overwatch provides you with various administration tools.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		self.navigationForm = vgui.Create("DForm", self);
			self.navigationForm:SetPadding(4);
			self.navigationForm:SetName("Navigation");
		self.panelList:AddItem(self.navigationForm);
		
		for k, v in pairs(nexus.overwatch.stored) do
			local overwatchButton = vgui.Create("DButton", self);
				overwatchButton:SetToolTip(v.toolTip);
				overwatchButton:SetText(v.name);
				overwatchButton:SetWide( self:GetParent():GetWide() );
			
				-- Called when the button is clicked.
				function overwatchButton.DoClick(button)
					self.overwatch = k;
					self:Rebuild();
				end;
			self.navigationForm:AddItem(overwatchButton);
		end;
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	for k, v in pairs(nexus.overwatch.stored) do
		if ( v:HasAccess() ) then
			return true;
		end;
	end;
end;

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

vgui.Register("nx_Overwatch", PANEL, "DFrame");