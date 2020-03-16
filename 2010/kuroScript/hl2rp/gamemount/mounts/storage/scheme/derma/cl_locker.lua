--[[
Name: "cl_locker.lua".
Product: "HL2 RP".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle("Locker");
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:Close(); self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
	
	-- Set some information.
	self.playersPanel = vgui.Create("DPanelList", self);
 	self.playersPanel:SetPadding(2);
 	self.playersPanel:SetSpacing(3);
 	self.playersPanel:SizeToContents();
	self.playersPanel:EnableVerticalScrollbar();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.playersPanel:Clear();
	
	-- Set some information.
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() and (v:GetSharedVar("ks_Tied") == 2 or v == g_LocalPlayer) ) then
			local button = vgui.Create("DButton", self.playersPanel);
			
			-- Called when the button is clicked.
			function button.DoClick(button)
				datastream.StreamToServer("ks_PlayersLocker", v);
				
				-- Disable the screen clicker.
				gui.EnableScreenClicker(false);
				
				-- Remove the panel.
				self:Remove();
			end;
			
			-- Add an item to the panel list.
			self.playersPanel:AddItem(button);
			
			-- Set some information.
			button:SetText( v:Name() );
		end;
	end;
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	-- Set some information.
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.playersPanel:StretchToParent(4, 28, 4, 4);
	
	-- Perform the layour.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("ks_Locker", PANEL, "DFrame");

-- Hook a user stream.
usermessage.Hook("ks_PlayersLocker", function(msg)
	if (kuroScript.game.lockerPanel) then
		kuroScript.game.lockerPanel:Remove();
	end;
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
	
	-- Set some information.
	kuroScript.game.lockerPanel = vgui.Create("ks_Locker");
	kuroScript.game.lockerPanel:MakePopup();
	kuroScript.game.lockerPanel:Rebuild();
end);