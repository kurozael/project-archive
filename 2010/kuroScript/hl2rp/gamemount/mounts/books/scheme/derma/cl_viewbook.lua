--[[
Name: "cl_viewbook.lua".
Product: "HL2 RP".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	-- Set some infomration.
	self:SetSize(512, 512);
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
function PANEL:Populate(itemTable)
	self:SetTitle(itemTable.name);
	
	-- Set some information.
	self.htmlPanel = vgui.Create("HTML", self);
	self.htmlPanel:SetHTML(itemTable.bookInformation);
	self.htmlPanel:SetWrap(true);
	
	-- Set some information.
	self.button = vgui.Create("DButton", self);
	self.button:SetText("Take");
	self.button:SetWide(504);
	self.button:SetPos(4, 486);
	
	-- Called when the button is clicked.
	function self.button.DoClick(button)
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
		
		-- Check if a statement is true.
		if ( ValidEntity(self.entity) ) then
			datastream.StreamToServer("ks_TakeBook", self.entity);
		end;
	end;
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.htmlPanel:StretchToParent(4, 28, 4, 30);
	
	-- Perform the layour.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("ks_ViewBook", PANEL, "DFrame");