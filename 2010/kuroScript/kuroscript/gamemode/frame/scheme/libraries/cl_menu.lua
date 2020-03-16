--[[
Name: "cl_menu.lua".
Product: "kuroScript".
--]]

kuroScript.menu = {};
kuroScript.menu.width = 0;
kuroScript.menu.height = 0;

-- A function to get the menu's active tab.
function kuroScript.menu.GetActiveTab()
	local panel = kuroScript.menu.GetPanel();
	
	-- Check if a statement is true.
	if (panel) then
		return panel.propertySheet:GetActiveTab():GetPanel();
	end;
end;

-- A function to toggle whether the menu is open.
function kuroScript.menu.ToggleOpen()
	local panel = kuroScript.menu.GetPanel();
	
	-- Check if a statement is true.
	if (panel) then
		panel:SetOpen( !kuroScript.menu.GetOpen() );
	end;
end;

-- A function to set whether the menu is open.
function kuroScript.menu.SetOpen(boolean)
	local panel = kuroScript.menu.GetPanel();
	
	-- Check if a statement is true.
	if (panel) then
		panel:SetOpen(boolean);
	end;
end;

-- A function to get whether the menu is open.
function kuroScript.menu.GetOpen()
	return kuroScript.menu.open;
end;

-- A function to get the menu panel.
function kuroScript.menu.GetPanel()
	if ( kuroScript.menu.panel and kuroScript.menu.panel:IsValid() ) then
		return kuroScript.menu.panel;
	end;
end;

-- A function to create the menu.
function kuroScript.menu.Create(open)
	local panel = kuroScript.menu.GetPanel();
	
	-- Check if a statement is true.
	if (!panel) then
		kuroScript.menu.panel = vgui.Create("ks_Menu");
		kuroScript.menu.panel:MakePopup();
		kuroScript.menu.panel:SetOpen(open);
	end;
end;