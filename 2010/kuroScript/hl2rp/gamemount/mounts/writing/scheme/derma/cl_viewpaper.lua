--[[
Name: "cl_viewpaper.lua".
Product: "HL2 RP".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	self:SetTitle("Paper");
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	-- Set some infomration.
	self:SetSize(512, 256);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	-- Check if a statement is true.
	if (!ValidEntity(self.entity) or self.entity:GetPos():Distance( g_LocalPlayer:GetPos() ) > 192) then
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
end;

-- A function to set the panel's entity.
function PANEL:SetEntity(entity)
	self.entity = entity;
end;

-- A function to populate the panel.
function PANEL:Populate(text)
	self.panelList:Clear();
	self.label = vgui.Create("DLabel");
	
	-- Set some information.
	self.label:SetAutoStretchVertical(true);
	self.label:SetTextColorHovered(COLOR_WHITE);
	self.label:SetTextColor(COLOR_WHITE);
	self.label:SetWrap(true)
	self.label:SetText(text);
	
	-- Add an item to the panel list.
	self.panelList:AddItem(self.label);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	
	-- Perform the layour.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("ks_ViewPaper", PANEL, "DFrame");