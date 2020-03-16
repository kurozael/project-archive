--[[
Name: "cl_vocations.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, kuroScript.menu.height);
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	-- Rebuild the panel.
	self:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	local vocationsForm = vgui.Create("DForm");
	
	-- Set some information.
	vocationsForm:SetPadding(5);
	vocationsForm:SetName("Vocations");
	
	-- Add an item to the panel list.
	self.panelList:AddItem(vocationsForm);
	
	-- Set some information.
	local vocations = {};
	local available;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.vocation.stored) do
		vocations[#vocations + 1] = v;
	end;
	
	-- Sort the vocations.
	table.sort(vocations, function(a, b)
		return a.name < b.name;
	end);
	
	-- Loop through each value in a table.
	for k, v in pairs(vocations) do
		if ( v.class == kuroScript.player.GetClass(g_LocalPlayer) ) then
			if ( hook.Call("PlayerCanSeeVocation", kuroScript.frame, v) ) then
				available = true;
				
				-- Set some information.
				self.vocation = kuroScript.vocation.stored[v.name];
				
				-- Add an item to the form.
				vocationsForm:AddItem( vgui.Create("ks_VocationsItem", self) );
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (!available) then
		local label = vgui.Create("ks_VocationsText", self);
		
		-- Set some information.
		label:SetText("You do not have access to any vocations.");
		label:SetTextColor(COLOR_WHITE);
		label:SizeToContents();
		
		-- Add an item to the form.
		vocationsForm:AddItem(label);
	end;
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (kuroScript.menu.GetActiveTab() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected as a tab.
function PANEL:OnTabSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("ks_Vocations", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.vocation = self:GetParent().vocation;
	
	-- Set some information.
	self:SetSize(kuroScript.menu.width, 42);
	
	-- Set some information.
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.vocation.name);
	self.nameLabel:SetTextColor(COLOR_WHITE);
	
	-- Set some information.
	self.information = vgui.Create("DLabel", self);
	self.information:SetText(self.vocation.description);
	self.information:SetTextColor(COLOR_WHITE);
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Set some information.
	local gender = kuroScript.player.GetGender(g_LocalPlayer);
	local model = kuroScript.vocation.GetModelByGender(self.vocation.index, gender);
	local skin = 1;
	
	-- Check if a statement is true.
	if (model) then
		if (type(model) == "table") then
			model = model[1]; skin = model[2];
		else
			model = model;
		end;
	else
		model = kuroScript.player.GetDefaultModel(g_LocalPlayer);
	end;
	
	-- Set some information.
	local info = {
		model = string.lower(model),
		skin = skin
	};
	
	-- Call a gamemode hook.
	hook.Call("PlayerAdjustVocationModelInfo", kuroScript.frame, self.vocation.index, info);
	
	-- Set some information.
	self.spawnIcon:SetModel(info.model, info.skin);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		RunConsoleCommand("ks", "vocation", self.vocation.index);
	end;
	
	-- Set some information.
	self.information:SetText(self.vocation.description);
	self.spawnIcon:SetIconSize(32);
end;

-- Called each frame.
function PANEL:Think()
	if (self.vocation) then
		self.spawnIcon:SetToolTip("There are "..g_Team.NumPlayers(self.vocation.index).."/"..self.vocation.limit.." characters with this vocation.");
	end;
end;

-- A function to adjust a position.
function PANEL:AdjustPosition(panel, x, y)
	panel:SetPos(x, y);
	
	-- Return the position.
	return x + panel:GetWide() + 8, y;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local x, y = self:AdjustPosition(self.spawnIcon, 4, 5);
	
	-- Set some information.
	self.nameLabel:SetPos(x, y);
	self.nameLabel:SizeToContents();
	self.information:SetPos(x, y + 19);
	self.information:SizeToContents();
end;
	
-- Register the panel.
vgui.Register("ks_VocationsItem", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetText("N/A");
	self.label:SetTextColor(COLOR_WHITE);
	self.label:SizeToContents();
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(self:GetWide() / 2 - self.label:GetWide() / 2, self:GetTall() / 2 - self.label:GetTall() / 2);
	self.label:SizeToContents();
end;

-- Set some information.
function PANEL:SetText(text)
	self.label:SetText(text);
end;

-- Set some information.
function PANEL:SetTextColor(color)
	self.label:SetTextColor(color);
end;
	
-- Register the panel.
vgui.Register("ks_VocationsText", PANEL, "DPanel");