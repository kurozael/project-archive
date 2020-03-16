--[[
Name: "cl_directory.lua".
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
	
	-- Set some information.
	kuroScript.directory.panel = self;
	kuroScript.directory.panel.categoryHistory = {};
	
	-- Rebuild the panel.
	self:Rebuild();
end;

-- A function to show a directory category.
function PANEL:ShowCategory(category)
	if (#self.categoryHistory > 0) then
		local backButton = vgui.Create("DButton", self);
		local friendlyName = kuroScript.directory.GetFriendlyName( self.categoryHistory[#self.categoryHistory - 1] ) or "Main";
		
		-- Set some information.
		backButton:SetText("Back to "..friendlyName);
		backButton:SetWide(kuroScript.menu.width);
		
		-- Called when the button is clicked.
		function backButton.DoClick(button)
			table.remove(self.categoryHistory, #self.categoryHistory);
			
			-- Rebuild the panel.
			self:Rebuild();
		end;
		
		-- Set some information.
		self.directoryForm = vgui.Create("DForm", self);
		self.directoryForm:SetPadding(4);
		self.directoryForm:SetName("Directory");
		
		-- Add an item to the panel list.
		self.panelList:AddItem(self.directoryForm);
		
		-- Add an item to the form.
		self.directoryForm:AddItem(backButton);
	end;
	
	-- Set some information.
	local available = nil;
	local k3, v3;
	local k2, v2;
	local k, v;
	
	-- Check if a statement is true.
	if (self.categoryHistory[#self.categoryHistory] != category) then
		self.categoryHistory[#self.categoryHistory + 1] = category;
	end;
	
	-- Set some information.
	self.categoryForm = vgui.Create("DForm", self);
	self.categoryForm:SetPadding(4);
	self.categoryForm:SetName(category or "Main");
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.directory.stored) do
		if (v.parent == category) then
			local categoryButton = vgui.Create("DButton", self);
			local friendlyName = kuroScript.directory.GetFriendlyName(v.category);
			local nextCategory = v.category;
			
			-- Set some information.
			categoryButton:SetText(friendlyName);
			categoryButton:SetWide(kuroScript.menu.width);
			
			-- Called when the button is clicked.
			function categoryButton.DoClick(button)
				self.categoryHistory[#self.categoryHistory + 1] = nextCategory;
				
				-- Rebuild the panel.
				self:Rebuild();
			end;
			
			-- Add an item to the form.
			self.categoryForm:AddItem(categoryButton);
			
			-- Set some information.
			available = true;
		end;
	end;
	
	-- Set some information.
	local text = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.directory.stored) do
		if (v.category == category) then
			if (!v.html) then
				for k2, v2 in pairs(v.information) do
					local wrapped = {};
					local directoryText = v2.text;
					
					-- Check if a statement is true.
					if (type(v2.callback) == "function") then
						directoryText = v2.callback(directoryText);
					end;
					
					-- Wrap the text into a table.
					kuroScript.frame:WrapText(directoryText, "Default", self:GetWide() - 16, 0, wrapped);
					
					-- Loop through each value in a table.
					for k3, v3 in ipairs(wrapped) do
						text[#text + 1] = {
							text = kuroScript.frame:ParseData(v3),
							tip = v2.tip
						};
					end;
				end;
			else
				local html = vgui.Create("HTML"); available = true;
				
				-- Set some information.
				html:SetSize(kuroScript.menu.width, kuroScript.menu.height - 138);
				
				-- Check if a statement is true.
				if (!v.website) then
					html:SetHTML( kuroScript.frame:ParseData(v.information) );
				else
					html:OpenURL(v.information);
				end;
				
				-- Add an item to the form.
				self.categoryForm:AddItem(html);
			end;
			
			-- Break the loop.
			break;
		end;
	end;
	
	-- Check if a statement is true.
	if (#text > 0) then
		local directoryText = vgui.Create("ks_DirectoryText", self);
		
		-- Set some information.
		directoryText:SetText(text);
		
		-- Add an item to the form.
		self.categoryForm:AddItem(directoryText);
	elseif (!available) then
		local directoryText = vgui.Create("ks_DirectoryText", self);
		
		-- Set some information.
		directoryText:SetText("There is no information available for this category.");
		
		-- Add an item to the form.
		self.categoryForm:AddItem(directoryText);
	end;
	
	-- Set some information.
	self.panelList:AddItem(self.categoryForm);
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	self.lastMenuWidth = kuroScript.menu.width;
	
	-- Validate the directory keys.
	kuroScript.frame:ValidateTableKeys(kuroScript.directory.stored);
	
	-- Sort the directories.
	table.sort(kuroScript.directory.stored, function(a, b)
		return a.category < b.category;
	end);
	
	-- Show the current category.
	self:ShowCategory( self.categoryHistory[#self.categoryHistory] );
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Called each frame.
function PANEL:Think()
	if (kuroScript.menu.width != self.lastMenuWidth) then
		self:Rebuild();
	end;
end;

-- Register the panel.
vgui.Register("ks_Directory", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.informationLabels = {};
end;

-- Set some information.
function PANEL:SetText(text)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs(self.informationLabels) do
		v:Remove();
	end;
	
	-- Check if a statement is true.
	if (type(text) != "table") then
		text = { {text = text} };
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs(text) do
		local directoryLabel = vgui.Create("ks_DirectoryLabel", self);
		
		-- Check if a statement is true.
		if (v.tip) then
			directoryLabel:SetToolTip( kuroScript.frame:ParseData(v.tip) );
		end;
		
		-- Check if a statement is true.
		if (string.sub(v.text, 1, 3) == ">r " or string.sub(v.text, 1, 3) == ">g " or string.sub(v.text, 1, 3) == ">b ") then
			directoryLabel.label:SetText( string.sub(v.text, 4) );
		else
			directoryLabel.label:SetText(v.text);
		end;
		
		-- Check if a statement is true.
		if (string.sub(v.text, 1, 3) == ">r ") then
			directoryLabel.label:SetTextColor( Color(255, 100, 100, 255) );
		elseif (string.sub(v.text, 1, 3) == ">g ") then
			directoryLabel.label:SetTextColor( Color(150, 255, 100, 255) );
		elseif (string.sub(v.text, 1, 3) == ">b ") then
			directoryLabel.label:SetTextColor( Color(100, 100, 255, 255) );
		end;
		
		-- Set some information.
		self.informationLabels[#self.informationLabels + 1] = directoryLabel;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local k, v;
	local y = 5;
	
	-- Loop through each value in a table.
	for k, v in ipairs(self.informationLabels) do
		self.informationLabels[k]:SetPos(8, y);
		
		-- Set some information.
		y = y + self.informationLabels[k]:GetTall() + 8
	end;
	
	-- Set some information.
	self:SetTall(y);
end;
	
-- Register the panel.
vgui.Register("ks_DirectoryText", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetTextColor(COLOR_WHITE);
end;

-- Called when the panel should be painted.
function PANEL:Paint() return true; end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SizeToContents();
	self:SetSize( self.label:GetWide(), self.label:GetTall() );
end;
	
-- Register the panel.
vgui.Register("ks_DirectoryLabel", PANEL, "DPanel");