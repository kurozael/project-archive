--[[
Name: "cl_editpaper.lua".
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
function PANEL:Populate()
	self.panelList:Clear();
	
	-- Set some information.
	local textEntry = vgui.Create("DTextEntry");
	local button = vgui.Create("DButton");
	
	-- Set some information.
	textEntry:SetMultiline(true);
	textEntry:SetHeight(194);
	
	-- Set some information.
	button:SetText("Okay");
	
	-- A function to set the text entry's real value.
	function textEntry:SetRealValue(text)
		self:SetValue(text);
		self:SetCaretPos( string.len(text) );
	end;
	
	-- Called each frame.
	function textEntry:Think()
		local text = self:GetValue();
		
		-- Check if a statement is true.
		if (string.len(text) > 500) then
			self:SetRealValue( string.sub(text, 0, 500) );
			
			-- Play a sound.
			surface.PlaySound("common/talk.wav");
		end;
	end;
	
	-- Called when the button is clicked.
	function button.DoClick(button)
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
		
		-- Check if a statement is true.
		if ( ValidEntity(self.entity) ) then
			datastream.StreamToServer( "ks_EditPaper", { self.entity, string.sub(textEntry:GetValue(), 0, 500) } );
		end;
	end;
	
	-- Add some items to the panel list.
	self.panelList:AddItem(textEntry);
	self.panelList:AddItem(button);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	
	-- Perform the layour.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("ks_EditPaper", PANEL, "DFrame");