--[[
Name: "cl_menu.lua".
Product: "nexus".
--]]

nexus.menu = {};
nexus.menu.width = ScrW() * 0.4;
nexus.menu.height = ScrH() * 0.75;
nexus.menu.stored = {};

-- A function to get the menu's active panel.
function nexus.menu.GetActivePanel()
	local panel = nexus.menu.GetPanel();
	
	if (panel) then
		return panel.activePanel;
	end;
end;

-- A function to get the menu's items.
function nexus.menu.GetItems()
	return nexus.menu.stored;
end;

-- A function to get the menu's width.
function nexus.menu.GetWidth()
	return nexus.menu.width;
end;

-- A function to get the menu's height.
function nexus.menu.GetHeight()
	return nexus.menu.height;
end;

-- A function to toggle whether the menu is open.
function nexus.menu.ToggleOpen()
	local panel = nexus.menu.GetPanel();
	
	if (panel) then
		if ( nexus.menu.GetOpen() ) then
			panel:SetOpen(false);
		else
			panel:SetOpen(true);
		end;
	end;
end;

-- A function to get the menu notice.
function nexus.menu.GetNotice()
	return nexus.menu.notice;
end;

-- A function to set the menu notice.
function nexus.menu.SetNotice(notice)
	if ( nexus.menu.GetPanel() ) then
		nexus.menu.GetPanel():DisplayCharacterNotice(notice);
	end;
	
	nexus.menu.notice = notice;
end;

-- A function to set whether the menu is open.
function nexus.menu.SetOpen(boolean)
	local panel = nexus.menu.GetPanel();
	
	if (panel) then
		panel:SetOpen(boolean);
	end;
end;

-- A function to get whether the menu is open.
function nexus.menu.GetOpen()
	return nexus.menu.isOpen;
end;

-- A function to get the menu panel.
function nexus.menu.GetPanel()
	if ( IsValid(nexus.menu.panel) ) then
		return nexus.menu.panel;
	end;
end;

-- A function to create the menu.
function nexus.menu.Create(open)
	local panel = nexus.menu.GetPanel();
	
	if (!panel) then
		nexus.menu.panel = vgui.Create("nx_Menu");
		nexus.menu.panel:SetOpen(open);
		nexus.menu.panel:MakePopup();
	end;
end;