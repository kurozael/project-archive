--[[
Name: "cl_settings.lua".
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
	local availableCategories = {};
	local categories = {};
	local k3, v3;
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.setting.stored) do
		if ( !v.condition or v.condition() ) then
			local category = v.category;
			
			-- Check if a statement is true.
			if ( !availableCategories[category] ) then
				availableCategories[category] = {};
			end;
			
			-- Set some information.
			availableCategories[category][#availableCategories[category] + 1] = v;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(availableCategories) do
		table.sort(v, function(a, b)
			if (a.class == b.class) then
				return a.text < b.text;
			else
				return a.class < b.class;
			end;
		end);
		
		-- Set some information.
		categories[#categories + 1] = {category = k, settings = v};
	end;
	
	-- Sort the categories.
	table.sort(categories, function(a, b)
		return a.category < b.category;
	end);
	
	-- Check if a statement is true.
	if (table.Count(categories) > 0) then
		for k, v in ipairs(categories) do
			local form = vgui.Create("DForm");
			
			-- Add an item to the panel list.
			self.panelList:AddItem(form);
			
			-- Set some information.
			form:SetName(v.category);
			form:SetPadding(4);
			
			-- Loop through each value in a table.
			for k2, v2 in ipairs(v.settings) do
				if (v2.class == "numberSlider") then
					panel = form:NumSlider(v2.text, v2.conVar, v2.minimum, v2.maximum, v2.decimals);
				elseif (v2.class == "multiChoice") then
					panel = form:MultiChoice(v2.text, v2.conVar);
					panel:SetEditable(false);
					
					-- Loop through each value in a table.
					for k3, v3 in ipairs(v2.options) do
						panel:AddChoice(v3);
					end;
				elseif (v2.class == "numberWang") then
					panel = form:NumberWang(v2.text, v2.conVar, v2.minimum, v2.maximum, v2.decimals);
				elseif (v2.class == "textEntry") then
					panel = form:TextEntry(v2.text, v2.conVar);
				elseif (v2.class == "checkBox") then
					panel = form:CheckBox(v2.text, v2.conVar);
				end;
				
				-- Check if a statement is true.
				if ( panel and panel:IsValid() ) then
					if (v2.class == "checkBox") then
						panel.Button:SetToolTip(v2.toolTip);
					else
						panel:SetToolTip(v2.toolTip);
					end;
				end;
			end;
		end;
	else
		local label = vgui.Create("ks_SettingsText");
		local form = vgui.Create("DForm");
		
		-- Add an item to the panel list.
		self.panelList:AddItem(form);
		
		-- Set some information.
		form:SetName("Settings");
		form:SetPadding(4);
		
		-- Set some information.
		label:SetText("You do not have access to any settings.");
		label:SetTextColor(COLOR_WHITE);
		
		-- Add an item to the form.
		form:AddItem(label);
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
vgui.Register("ks_Settings", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
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
vgui.Register("ks_SettingsText", PANEL, "DPanel");