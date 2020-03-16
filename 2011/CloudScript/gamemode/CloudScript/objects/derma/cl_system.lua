--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( CloudScript.menu:GetWidth(), CloudScript.menu:GetHeight() );
	self:SetTitle( CloudScript.option:GetKey("name_system") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	CloudScript.system.panel = self;
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	if (self.system) then
		self.navigationForm = vgui.Create("DForm", self);
			self.navigationForm:SetPadding(4);
			self.navigationForm:SetName("Navigation");
		self.panelList:AddItem(self.navigationForm);
	
		local backButton = vgui.Create("DButton", self);
			backButton:SetText("Back to Navigation");
			backButton:SetWide( self:GetParent():GetWide() );
			
			-- Called when the button is clicked.
			function backButton.DoClick(button)
				self.system = nil;
				self:Rebuild();
			end;
		self.navigationForm:AddItem(backButton);
		
		local systemTable = CloudScript.system:Get(self.system);
		
		if (systemTable) then
			if (systemTable.doesCreateForm) then
				self.systemForm = vgui.Create("DForm", self);
					self.systemForm:SetPadding(4);
					self.systemForm:SetName(systemTable.name);
				self.panelList:AddItem(self.systemForm);
			end;
			
			systemTable:OnDisplay(self, self.systemForm);
		end;
	else
		local label = vgui.Create("cloud_InfoText", self);
			label:SetText("The "..CloudScript.option:GetKey("name_system").." provides you with various tools.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs( CloudScript.system:GetAll() ) do
			self.systemCategoryForm = vgui.Create("DForm", self);
				self.systemCategoryForm:SetPadding(4);
				self.systemCategoryForm:SetName(v.name);
			self.panelList:AddItem(self.systemCategoryForm);
			
			self.systemCategoryForm:Help(v.toolTip);
			
			local systemButton = vgui.Create("cloud_InfoText", systemPanel);
				systemButton:SetText("Open");
				systemButton:SetTextToLeft();
				
				if ( v:HasAccess() ) then
					systemButton:SetButton(true);
					systemButton:SetInfoColor("green");
					systemButton:SetToolTip("Click here to open this System panel.");
					
					-- Called when the button is clicked.
					function systemButton.DoClick(button)
						self.system = v.name;
						self:Rebuild();
					end;
				else
					systemButton:SetInfoColor("red");
					systemButton:SetToolTip("You do not have access to this System panel.");
				end;
				
				systemButton:SetShowIcon(false);
			self.systemCategoryForm:AddItem(systemButton);
		end;
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	for k, v in pairs( CloudScript.system:GetAll() ) do
		if ( v:HasAccess() ) then
			return true;
		end;
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

vgui.Register("cloud_System", PANEL, "DFrame");