--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.menu = {};
CloudScript.menu.width = ScrW() * 0.6;
CloudScript.menu.height = ScrH() * 0.75;
CloudScript.menu.stored = {};

-- A function to get the menu's active panel.
function CloudScript.menu:GetActivePanel()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.activePanel;
	end;
end;

-- A function to get the menu hold time.
function CloudScript.menu:GetHoldTime()
	return self.holdTime;
end;

-- A function to get the menu's items.
function CloudScript.menu:GetItems()
	return self.stored;
end;

-- A function to get the menu's width.
function CloudScript.menu:GetWidth()
	return self.width;
end;

-- A function to get the menu's height.
function CloudScript.menu:GetHeight()
	return self.height;
end;

-- A function to toggle whether the menu is open.
function CloudScript.menu:ToggleOpen()
	local panel = self:GetPanel();
	
	if (panel) then
		if ( self:GetOpen() ) then
			panel:SetOpen(false);
		else
			panel:SetOpen(true);
		end;
	end;
end;

-- A function to set whether the menu is open.
function CloudScript.menu:SetOpen(isOpen)
	local panel = self:GetPanel();
	
	if (panel) then
		panel:SetOpen(isOpen);
	end;
end;

-- A function to get whether the menu is open.
function CloudScript.menu:GetOpen()
	return self.isOpen;
end;

-- A function to get the menu panel.
function CloudScript.menu:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to create the menu.
function CloudScript.menu:Create(setOpen)
	local panel = self:GetPanel();
	
	if (!panel) then
		self.panel = vgui.Create("cloud_Menu");
		
		if ( IsValid(self.panel) ) then
			self.panel:SetOpen(setOpen);
			self.panel:MakePopup();
		end;
	end;
end;