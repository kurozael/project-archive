--[[
Name: "cl_menu.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local k, v;
	
	-- Set some information.
	self:SetTitle(NAME_MENU);
	self:SetDraggable(false);
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:SetOpen(false);
	end;
	
	-- Set some information.
	self.propertySheet = vgui.Create("DPropertySheet", self);
	
	-- Set some information.
	kuroScript.frame.PropertySheetTabs.tabs = {};
	
	-- Call some gamemode hooks.
	hook.Call("MenuPropertySheetTabsAdd", kuroScript.frame, kuroScript.frame.PropertySheetTabs);
	hook.Call("MenuPropertySheetTabsDestroy", kuroScript.frame, kuroScript.frame.PropertySheetTabs);
	
	-- Sort the property sheet tabs.
	table.sort(kuroScript.frame.PropertySheetTabs.tabs, function(a, b)
		return a.text < b.text;
	end);
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.frame.PropertySheetTabs.tabs) do
		self.propertySheet:AddSheet(v.text, vgui.Create(v.panel, self.propertySheet), v.icon, nil, nil, v.tip);
	end;
end;

-- Called every fame.
function PANEL:Think()
	local k, v;
	
	-- Set some information.
	kuroScript.menu.width = -(#self.propertySheet.Items * 2);
	
	-- Loop through each value in a table.
	for k, v in pairs(self.propertySheet.Items) do
		kuroScript.menu.width = kuroScript.menu.width + v.Tab:GetWide() + 1;
	end;
	
	-- Set some information.
	kuroScript.menu.height = ScrH() - (ScrH() / 6);
	kuroScript.menu.width = math.min( kuroScript.menu.width, ScrW() - (ScrW() / 8) );
	
	-- Set some information.
	self:SetVisible(kuroScript.menu.open);
	self:SetSize(kuroScript.menu.width, kuroScript.menu.height);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);
	
	-- Check if a statement is true.
	if ( kuroScript.menu.GetOpen() ) then
		if (self.propertySheet:GetActiveTab():GetPanel() != self.lastActiveTab) then
			self.lastActiveTab = self.propertySheet:GetActiveTab():GetPanel();
			
			-- Check if a statement is true.
			if (self.lastActiveTab.OnTabSelected) then
				self.lastActiveTab:OnTabSelected();
			end;
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.propertySheet:StretchToParent(4, 28, 4, 4); DFrame.PerformLayout(self);
end;

-- A function to set whether the panel is open.
function PANEL:SetOpen(boolean)
	self:SetVisible(boolean);
	
	-- Set some information.
	kuroScript.menu.open = boolean;
	
	-- Toggle the screen clicker.
	gui.EnableScreenClicker(boolean);
	
	-- Check if a statement is true.
	if (boolean) then
		hook.Call("MenuOpened", kuroScript.frame);
	else
		hook.Call("MenuClosed", kuroScript.frame);
	end;
end;

-- Register the panel.
vgui.Register("ks_Menu", PANEL, "DFrame");

-- Hook a user message.
usermessage.Hook("ks_MenuOpen", function(msg)
	local panel = kuroScript.menu.GetPanel();
	
	-- Check if a statement is true.
	if (panel) then
		kuroScript.menu.SetOpen( msg:ReadBool() );
	else
		kuroScript.menu.Create( msg:ReadBool() );
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_MenuToggle", function(msg)
	if ( g_LocalPlayer:HasInitialized() ) then
		local panel = kuroScript.menu.GetPanel();
		
		-- Check if a statement is true.
		if (panel) then
			kuroScript.menu.ToggleOpen();
		else
			kuroScript.menu.Create(!kuroScript.menu.open);
		end;
	end;
end);