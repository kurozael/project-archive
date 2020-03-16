--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( CloudScript.menu:GetWidth(), CloudScript.menu:GetHeight() );
	self:SetTitle( CloudScript.option:GetKey("name_directory") );
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.treeNode = vgui.Create("DTree", self);
	self.treeNode:SetPadding(2);
	self.htmlPanel = vgui.Create("HTML", self);
	
	CloudScript.directory.panel = self;
	CloudScript.directory.panel.categoryHistory = {};
	
	self:Rebuild();
end;

-- A function to show a directory category.
function PANEL:ShowCategory(category)
	if (!category) then
		local masterFormatting = CloudScript.directory:GetMasterFormatting();
		local finalCode = [[
			<div class="cloudInfoTitle">SELECT A CATEGORY</div>
			<div class="cloudInfoText">
				Some categories may only be available to users with special priviledges.
			</div>
		]];
		
		if (masterFormatting) then
			finalCode = CloudScript:Replace(masterFormatting, "{information}", finalCode);
		end;
		
		finalCode = CloudScript:Replace(finalCode, "[category]", "Directory");
		finalCode = CloudScript:Replace(finalCode, "{category}", "DIRECTORY");
		finalCode = CloudScript:ParseData(finalCode);
		
		self.htmlPanel:SetHTML(finalCode);
	else
		local categoryTable = CloudScript.directory:GetCategory(category);
		
		if (categoryTable) then
			if (!categoryTable.isHTML) then
				local newPageData = {};
				
				for k, v in pairs(categoryTable.pageData) do
					newPageData[#newPageData + 1] = v;
				end;
				
				local sorting = CloudScript.directory:GetCategorySorting(category);
				
				if (sorting) then
					table.sort(newPageData, sorting);
				end;
				
				if (table.Count(newPageData) > 0) then
					local masterFormatting = CloudScript.directory:GetMasterFormatting();
					local formatting = CloudScript.directory:GetCategoryFormatting(category);
					local firstKey = true;
					local finalCode = "";
				
					for k, v in pairs(newPageData) do
						local htmlCode = v.htmlCode;
						
						if (type(v.Callback) == "function") then
							htmlCode = v.Callback(htmlCode, v.sortData);
						end;
						
						if (htmlCode and htmlCode != "") then
							if (!firstKey) then
								if ( (!formatting or !formatting.noLineBreaks) and !v.noLineBreak ) then
									finalCode = finalCode.."<br>"..htmlCode;
								else
									finalCode = finalCode..htmlCode;
								end;
							else
								finalCode = htmlCode;
							end;
							
							firstKey = false;
						end;
					end;
					
					if (formatting) then
						finalCode = CloudScript:Replace(formatting.htmlCode, "{information}", finalCode);
					end;
					
					if (masterFormatting) then
						finalCode = CloudScript:Replace(masterFormatting, "{information}", finalCode);
					end;
					
					finalCode = CloudScript:Replace(finalCode, "[category]", category);
					finalCode = CloudScript:Replace( finalCode, "{category}", string.upper(category) );
					finalCode = CloudScript:ParseData(finalCode);
					
					self.htmlPanel:SetHTML(finalCode);
				end;
			elseif (!categoryTable.isWebsite) then
				local masterFormatting = CloudScript.directory:GetMasterFormatting();
				local formatting = CloudScript.directory:GetCategoryFormatting(category);
				local finalCode = categoryTable.pageData;
				
				if (formatting) then
					finalCode = CloudScript:Replace(formatting.htmlCode, "{information}", finalCode);
				end;
				
				if (masterFormatting) then
					finalCode = CloudScript:Replace(masterFormatting, "{information}", finalCode);
				end;
				
				finalCode = CloudScript:Replace(finalCode, "[category]", category);
				finalCode = CloudScript:Replace( finalCode, "{category}", string.upper(category) );
				finalCode = CloudScript:ParseData(finalCode);
				
				self.htmlPanel:SetHTML(finalCode);
			else
				self.htmlPanel:OpenURL(categoryTable.pageData);
			end;
		end;
	end;
end;

-- A function to clear the nodes.
function PANEL:ClearNodes()
	for k, v in pairs(self.treeNode.Items) do
		if ( IsValid(v) ) then v:Remove(); end;
	end;
	
	self.treeNode.m_pSelectedItem = nil;
	self.treeNode.Items = {};
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (!NX_REBUILDING_DIRECTORY) then
		self:ClearNodes();
		
		NX_REBUILDING_DIRECTORY = true;
			CloudScript.plugin:Call("CloudScriptDirectoryRebuilt", self);
		NX_REBUILDING_DIRECTORY = nil;
		
		CloudScript:ValidateTableKeys(CloudScript.directory.stored);
		
		table.sort(CloudScript.directory.stored, function(a, b)
			return a.category < b.category;
		end);
		
		local nodeTable = {};
		
		for k, v in pairs(CloudScript.directory.stored) do
			if (!v.parent) then
				nodeTable[v.category] = self.treeNode:AddNode(v.category);
			end;
		end;
		
		for k, v in pairs(CloudScript.directory.stored) do
			if ( v.parent and nodeTable[v.parent] ) then
				nodeTable[v.category] = nodeTable[v.parent]:AddNode(v.category);
			elseif ( !nodeTable[v.category] ) then
				nodeTable[v.category] = self.treeNode:AddNode(v.category);
			end;
			
			if (!nodeTable[v.category].Initialized) then
				local friendlyName = CloudScript.directory:GetFriendlyName(v.category);
				local tip = CloudScript.directory:GetCategoryTip(v.category);
				
				if (tip) then
					nodeTable[v.category]:SetToolTip(tip);
				end;
				
				nodeTable[v.category].Initialized = true;
				nodeTable[v.category]:SetText(friendlyName);
				nodeTable[v.category].DoClick = function(node)
					for k2, v2 in pairs(CloudScript.directory.stored) do
						if ( v2.category == v.category and (v2.isWebsite
						or v2.isHTML or #v2.pageData > 0) ) then
							self.currentCategory = v.category;
							self:ShowCategory(self.currentCategory);
							
							break;
						end;
					end;
				end;
			end;
		end;
		
		self:ShowCategory(self.currentCategory);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:SetSize(self:GetWide(), ScrH() * 0.75);
	self.treeNode:SetPos(4, 28);
	self.treeNode:SetSize(self:GetWide() * 0.2, self:GetTall() - 36);
	self.htmlPanel:SetPos( (self:GetWide() * 0.2) + 8, 28 );
	self.htmlPanel:SetSize( (self:GetWide() * 0.8) - 16, self:GetTall() - 36 );
	
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

vgui.Register("cloud_Directory", PANEL, "DFrame");