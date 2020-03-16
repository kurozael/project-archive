--[[
Name: "cl_directory.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( nexus.menu.GetWidth(), nexus.menu.GetHeight() );
	self:SetTitle( nexus.schema.GetOption("name_directory") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	nexus.directory.panel = self;
	nexus.directory.panel.categoryHistory = {};
	
	self:Rebuild();
end;

-- A function to show a directory category.
function PANEL:ShowCategory(category)
	if (#self.categoryHistory > 0) then
		local backButton = vgui.Create("DButton", self);
		local friendlyName = nexus.directory.GetFriendlyName( self.categoryHistory[#self.categoryHistory - 1] ) or "Navigation";
		
		backButton:SetText("Back to "..friendlyName);
		backButton:SetWide( self:GetParent():GetWide() );
		
		-- Called when the button is clicked.
		function backButton.DoClick(button)
			table.remove(self.categoryHistory, #self.categoryHistory);
			
			self:Rebuild();
		end;
		
		self.navigationForm = vgui.Create("DForm", self);
		self.navigationForm:SetPadding(4);
		self.navigationForm:SetName("Navigation");
			self.panelList:AddItem(self.navigationForm);
		self.navigationForm:AddItem(backButton);
	elseif (!category) then
		local label = vgui.Create("nx_InfoText", self);
			label:SetText("This is where you'll find lots of information and help.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
	end;
	
	local extraHeight = 0;
	local isInfoAvailable = nil;
	
	if (self.categoryHistory[#self.categoryHistory] != category) then
		self.categoryHistory[#self.categoryHistory + 1] = category;
	end;
	
	self.categoryForm = vgui.Create("DForm", self);
	self.categoryForm:SetPadding(4);
	self.categoryForm:SetName(category or "Navigation");
	
	for k, v in pairs(nexus.directory.stored) do
		if (v.parent == category) then
			local categoryButton = vgui.Create("DButton", self);
			local friendlyName = nexus.directory.GetFriendlyName(v.category);
			local nextCategory = v.category;
			local tip = nexus.directory.GetCategoryTip(v.category);
			
			categoryButton:SetText(friendlyName);
			categoryButton:SetWide( self:GetParent():GetWide() );
			
			if (tip) then
				categoryButton:SetToolTip(tip);
			end;
			
			-- Called when the button is clicked.
			function categoryButton.DoClick(button)
				self.categoryHistory[#self.categoryHistory + 1] = nextCategory;
				self:Rebuild();
			end;
			
			self.categoryForm:AddItem(categoryButton);
				extraHeight = extraHeight + categoryButton:GetTall() + 4;
			isInfoAvailable = true;
		end;
	end;
	
	local categoryTable = nexus.directory.GetCategory(category);
	
	if (categoryTable) then
		categoryTable = table.Copy(categoryTable);
		
		if (!categoryTable.isHTML) then
			categoryTable.newPageData = {};
			
			for k, v in pairs(categoryTable.pageData) do
				categoryTable.newPageData[#categoryTable.newPageData + 1] = v;
			end;
			
			local sorting = nexus.directory.GetCategorySorting(category);
			
			if (sorting) then
				table.sort(categoryTable.newPageData, sorting);
			end;
			
			if (table.Count(categoryTable.newPageData) > 0) then
				local htmlBackground = nexus.schema.GetOption("html_background");
				local formatting = nexus.directory.GetCategoryFormatting(category);
				local htmlPanel = vgui.Create("HTML");
				local finalCode = "";
				local preCode = "";
				
				if (htmlBackground != "") then
					preCode = [[
						<style type="text/css">
							body { background-image: url(]]..htmlBackground..[[) }
						</style>
					]];
				end;
				
				local firstKey = true;
					htmlPanel:SetSize(self:GetParent():GetWide(), self:GetParent():GetTall() - 388 - extraHeight);
					
					for k, v in pairs(categoryTable.newPageData) do
						local htmlCode = v.htmlCode;
						
						if (type(v.Callback) == "function") then
							htmlCode = v.Callback(htmlCode);
						end;
						
						if (!firstKey) then
							if (!formatting or !formatting.noLineBreaks) then
								finalCode = finalCode.."<br>"..htmlCode;
							else
								finalCode = finalCode..htmlCode;
							end;
						else
							finalCode = htmlCode;
						end;
						
						firstKey = false;
					end;
					
					if (formatting) then
						finalCode = string.Replace(formatting.htmlCode, "{information}", finalCode);
					end;
					
					finalCode = preCode..[[
						<font face="Verdana" size="2">
							]]..NEXUS:ParseData(finalCode)..[[
						</font>
					]];
					
					htmlPanel:SetHTML(finalCode);
				self.categoryForm:AddItem(htmlPanel);
				
				isInfoAvailable = true;
			end;
		else
			local htmlPanel = vgui.Create("HTML");
				htmlPanel:SetSize(self:GetParent():GetWide(), self:GetParent():GetTall() - 364 - extraHeight);
				
				if (!categoryTable.isWebsite) then
					local htmlBackground = nexus.schema.GetOption("html_background");
					local finalCode = "";
					
					if (htmlBackground != "") then
						finalCode = [[
							<style type="text/css">
								body { background-image: url(]]..htmlBackground..[[) }
							</style>
						]];
					end;
					
					finalCode = finalCode..[[
						<font face="Verdana" size="2">
							]]..NEXUS:ParseData(categoryTable.pageData)..[[
						</font>
					]];
					
					htmlPanel:SetHTML(finalCode);
				else
					htmlPanel:OpenURL(categoryTable.pageData);
				end;
			self.categoryForm:AddItem(htmlPanel);
			
			isInfoAvailable = true;
		end;
	end;
	
	if (!isInfoAvailable) then
		local directoryText = vgui.Create("nx_InfoText", self);
			directoryText:SetText("There is no information available for this category.");
			directoryText:SetInfoColor("orange");
		self.categoryForm:AddItem(directoryText);
	end;
	
	self.panelList:AddItem(self.categoryForm);
	self.panelList:InvalidateLayout(true);
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (!NX_REBUILDING_DIRECTORY) then
		self.panelList:Clear(true);
		
		NX_REBUILDING_DIRECTORY = true;
			nexus.mount.Call("NexusDirectoryRebuilt", self);
		NX_REBUILDING_DIRECTORY = nil;
		
		NEXUS:ValidateTableKeys(nexus.directory.stored);
		
		table.sort(nexus.directory.stored, function(a, b)
			return a.category < b.category;
		end);
		
		self:ShowCategory( self.categoryHistory[#self.categoryHistory] );
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("nx_Directory", PANEL, "DFrame");