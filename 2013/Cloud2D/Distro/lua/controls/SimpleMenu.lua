--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

local SIMPLE_MENUS = {};

-- An internal function to close all simple menus.
local function CloseAllSimpleMenus()
	for k, v in ipairs(SIMPLE_MENUS) do
		v:Remove();
	end;
	
	SIMPLE_MENUS = {};
end;

-- An internal function to add a simple menu to the list.
local function AddSimpleMenuToList(simpleMenu)
	SIMPLE_MENUS[#SIMPLE_MENUS + 1] = simpleMenu;
end;

hooks.Add("ControlMouseButtonPress", "SimpleMenus", function(control, button)
	if (control and control:GetClass() == "SimpleMenu") then
		return;
	end;
	
	if (control and control:GetParent()
	and control:GetParent():GetClass() == "SimpleMenu") then
		return;
	end;
	
	CloseAllSimpleMenus();
end);

-- Called when the control's layout should be performed.
function CONTROL:OnPerformLayout()
	local width = self.m_iMinimumWidth;
	local y = 0;
	
	for k, v in ipairs(self.m_options) do
		width = math.max(width, v:GetW());
	end;
	
	for k, v in ipairs(self.m_options) do
		v:SetWidth(width);
		v:SetPos(0, y);
		y = y + v:GetH();
	end;
	
	self:SetSize(width + 2, y + 2);
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	if (not arguments[1]) then
		CloseAllSimpleMenus();
	end;
	
	AddSimpleMenuToList(self);
	
	self:SetMinimumWidth(100);
	self.m_options = {};
end;

-- A function to add an option to the control.
function CONTROL:AddOption(text, Callback)
	local menuOption = controls.Create("MenuOption", self);
		menuOption:SetText(text);
		menuOption:SetCallback(Callback);
		menuOption:SizeToContents();
		menuOption:SetSize(menuOption:GetW() + 48, 24);
	self.m_options[#self.m_options + 1] = menuOption;
	
	return menuOption;
end;

-- A function to add a sub menu to the control.
function CONTROL:AddSubMenu(text, Callback)
	local subMenu = controls.Create("SimpleMenu", nil, true);
	subMenu:SetVisible(false);
	
	local menuOption = controls.Create("MenuOption", self);
		menuOption:SetText(text);
		menuOption:SetSubMenu(subMenu);
		menuOption:SetCallback(Callback);
		menuOption:SizeToContents();
		menuOption:SetSize(menuOption:GetW() + 48, 18);
	self.m_options[#self.m_options + 1] = menuOption;
	
	return subMenu, menuOption;
end;

-- A function to close the control.
function CONTROL:Close()
	CloseAllSimpleMenus();
end;

-- A function to open the control.
function CONTROL:Open(x, y)
	local mousePos = util.GetMousePos();
	
	if (not x) then
		x = mousePos.x;
	end;
	
	if (not y) then
		y = mousePos.y;
	end;
	
	self:InvalidateLayout();
	self:SetVisible(true);
	self:SetPos(x, y);
end;

-- A function to hide the control.
function CONTROL:Hide()
	self:CloseSubMenu();
	self:SetVisible(false);
end;

-- A function to open a sub menu.
function CONTROL:OpenSubMenu(menuOption, subMenu)
	if (subMenu == self:GetOpenSubMenu()) then
		return;
	end;
	
	self:CloseSubMenu();
	self:SetOpenSubMenu(subMenu);
	
	subMenu:Open(
		menuOption:GetX() + menuOption:GetW(),
		menuOption:GetY()
	);
end;

-- A function to close the control's sub menu.
function CONTROL:CloseSubMenu()
	local openSubMenu = self:GetOpenSubMenu();
	
	if (openSubMenu) then
		openSubMenu:Hide();
		self:SetOpenSubMenu(nil);
	end;
end;

util.AddAccessor(CONTROL, "MinimumWidth", "m_iMinimumWidth");
util.AddAccessor(CONTROL, "OpenSubMenu", "m_openSubMenu");