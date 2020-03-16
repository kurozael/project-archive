--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.menu = {};
openAura.menu.width = ScrW() * 0.6;
openAura.menu.height = ScrH() * 0.75;
openAura.menu.stored = {};

-- A function to get the menu's active panel.
function openAura.menu:GetActivePanel()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.activePanel;
	end;
end;

-- A function to get the menu hold time.
function openAura.menu:GetHoldTime()
	return self.holdTime;
end;

-- A function to get the menu's items.
function openAura.menu:GetItems()
	return self.stored;
end;

-- A function to get the menu's width.
function openAura.menu:GetWidth()
	return self.width;
end;

-- A function to get the menu's height.
function openAura.menu:GetHeight()
	return self.height;
end;

-- A function to toggle whether the menu is open.
function openAura.menu:ToggleOpen()
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
function openAura.menu:SetOpen(isOpen)
	local panel = self:GetPanel();
	
	if (panel) then
		panel:SetOpen(isOpen);
	end;
end;

-- A function to get whether the menu is open.
function openAura.menu:GetOpen()
	return self.isOpen;
end;

-- A function to get the menu panel.
function openAura.menu:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to create the menu.
function openAura.menu:Create(setOpen)
	local panel = self:GetPanel();
	
	if (!panel) then
		self.panel = vgui.Create("aura_Menu");
		
		if ( IsValid(self.panel) ) then
			self.panel:SetOpen(setOpen);
			self.panel:MakePopup();
		end;
	end;
end;