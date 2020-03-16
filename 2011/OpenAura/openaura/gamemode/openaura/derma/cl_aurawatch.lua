--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle( openAura.option:GetKey("name_moderator") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.moderator.panel = self;
	
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	if (self.moderator) then
		self.navigationForm = vgui.Create("DForm", self);
			self.navigationForm:SetPadding(4);
			self.navigationForm:SetName("Navigation");
		self.panelList:AddItem(self.navigationForm);
	
		local backButton = vgui.Create("DButton", self);
			backButton:SetText("Back to Navigation");
			backButton:SetWide( self:GetParent():GetWide() );
			
			-- Called when the button is clicked.
			function backButton.DoClick(button)
				self.moderator = nil;
				self:Rebuild();
			end;
		self.navigationForm:AddItem(backButton);
		
		local moderatorTable = openAura.moderator:Get(self.moderator);
		
		if (moderatorTable) then
			if (moderatorTable.doesCreateForm) then
				self.moderatorForm = vgui.Create("DForm", self);
					self.moderatorForm:SetPadding(4);
					self.moderatorForm:SetName(moderatorTable.name);
				self.panelList:AddItem(self.moderatorForm);
			end;
			
			moderatorTable:OnDisplay(self, self.moderatorForm);
		end;
	else
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("The "..openAura.option:GetKey("name_moderator").." provides you with various tools.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs( openAura.moderator:GetAll() ) do
			self.moderatorCategoryForm = vgui.Create("DForm", self);
				self.moderatorCategoryForm:SetPadding(4);
				self.moderatorCategoryForm:SetName(v.name);
			self.panelList:AddItem(self.moderatorCategoryForm);
			
			self.moderatorCategoryForm:Help(v.toolTip);
			
			local moderatorButton = vgui.Create("aura_InfoText", moderatorPanel);
				moderatorButton:SetText("Open");
				moderatorButton:SetTextToLeft();
				
				if ( v:HasAccess() ) then
					moderatorButton:SetButton(true);
					moderatorButton:SetInfoColor("green");
					moderatorButton:SetToolTip("Click here to open this Moderator panel.");
					
					-- Called when the button is clicked.
					function moderatorButton.DoClick(button)
						self.moderator = v.name;
						self:Rebuild();
					end;
				else
					moderatorButton:SetInfoColor("red");
					moderatorButton:SetToolTip("You do not have access to this Moderator panel.");
				end;
				
				moderatorButton:SetShowIcon(false);
			self.moderatorCategoryForm:AddItem(moderatorButton);
		end;
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	for k, v in pairs( openAura.moderator:GetAll() ) do
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

vgui.Register("aura_Moderator", PANEL, "DFrame");