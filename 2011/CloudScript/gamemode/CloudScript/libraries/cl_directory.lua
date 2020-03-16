--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.directory = {};
CloudScript.directory.tips = {};
CloudScript.directory.stored = {};
CloudScript.directory.sorting = {};
CloudScript.directory.formatting = {};
CloudScript.directory.friendlyNames = {};
CloudScript.directory.masterFormatting = [[
	<style type="text/css">
		body {
			background-image: url(http://kurozael.com/CloudScript/bg.png);
			font-family: Arial;
		}
		
		.cloudBackground {
			background-color: #83ADC4;
		}
		
		.cloudInfoTitle {
			font-family: "Myriad Pro", "Lucida Grande", "Lucida Sans Unicode", Arial;
			background: #FFFFFF;
			font-weight: bold;
			border-bottom: 1px #555555 solid;
			font-size: 16px;
			color: #555555;
		}
		
		.cloudInfoTip {
			background: #CFECFF;
			font-size: 12px;
			color: #666666;
		}
		
		.cloudInfoText {
			font-weight: bold;
			font-size: 12px;
			padding: 2px;
			color: #FFFFFF;
		}
		
		.cloudHeader {
			background: #FFFFFF;
			border-bottom: 1px #555555 solid;
			border-top: 2px #555555 solid;
			font-family: "Myriad Pro", "Lucida Grande", "Lucida Sans Unicode", Arial;
			font-weight: bold;
			font-size: 32px;
			color: #555555;
		}
		
		.cloudTitle {
			font-family: "Myriad Pro", "Lucida Grande", "Lucida Sans Unicode", Arial;
			font-weight: bold;
			font-size: 16px;
			color: #FFFFFF;
		}
		
		.cloudContent {
			background:#83ADC4;
			border-top: 2px #555555 solid;
			padding: 2px;
			color: #FFFFFF;
		}
	</style>
	
	<div class="cloudHeader">
		{category}
	</div><br>
	
	<div class="cloudContent">
		{information}
	</div>
]];

--[[
	A good idea for the master formatting, is to ensure the existance of default CSS classes.
	You can still customize them for use, though.
--]]

-- A function to get a category.
function CloudScript.directory:GetCategory(category)
	for k, v in pairs(self.stored) do
		if (v.category == category) then
			return v, k;
		end;
	end;
end;

-- A function to set a category tip.
function CloudScript.directory:SetCategoryTip(category, tip)
	self.tips[category] = tip;
end;

-- A function to get a category tip.
function CloudScript.directory:GetCategoryTip(category)
	return self.tips[category];
end;

-- A function to add a category page.
function CloudScript.directory:AddCategoryPage(category, parent, htmlCode, isWebsite)
	self:AddCategory(category, parent);
	self:AddPage(category, htmlCode, isWebsite);
end;

-- A function to set a friendly name.
function CloudScript.directory:SetFriendlyName(category, name)
	self.friendlyNames[category] = name;
end;

-- A function to get a friendly name.
function CloudScript.directory:GetFriendlyName(category)
	return self.friendlyNames[category] or category;
end;

-- A function to set the master formatting.
function CloudScript.directory:SetMasterFormatting(htmlCode)
	self.masterFormatting = htmlCode;
end;

-- A function to get the master formatting.
function CloudScript.directory:GetMasterFormatting()
	return self.masterFormatting;
end;

-- A function to set category formatting.
function CloudScript.directory:SetCategoryFormatting(category, htmlCode, noLineBreaks, noMasterFormatting)
	self.formatting[category] = {
		noMasterFormatting = noMasterFormatting,
		noLineBreaks = noLineBreaks,
		htmlCode = htmlCode
	};
end;

-- A function to get category formatting.
function CloudScript.directory:GetCategoryFormatting(category)
	return self.formatting[category];
end;

-- A function to set category sorting.
function CloudScript.directory:SetCategorySorting(category, Callback)
	self.sorting[category] = Callback;
end;

-- A function to get category sorting.
function CloudScript.directory:GetCategorySorting(category)
	return self.sorting[category];
end;

-- A function to get whether a category exists.
function CloudScript.directory:CategoryExists(category)
	for k, v in pairs(self.stored) do
		if (v.category == category) then
			return true;
		end;
	end;
end;

-- A function to add a category.
function CloudScript.directory:AddCategory(category, parent)
	if (parent) then
		self:AddCategory(parent, false);
	end;
	
	if ( !self:CategoryExists(category) ) then
		if (parent == false) then parent = nil; end;
		
		self.stored[#self.stored + 1] = {
			category = category,
			pageData = {},
			parent = parent
		};
	elseif (parent != false) then
		for k, v in pairs(self.stored) do
			if (v.category == category) then
				v.parent = parent;
			end;
		end;
	end;
	
	return category, parent;
end;

-- A function to add some code.
function CloudScript.directory:AddCode(category, htmlCode, noLineBreak, sortData, Callback)
	self:AddCategory(category, false);
	
	local categoryTable = self:GetCategory(category);
	local uniqueID = nil;
	local panel = self:GetPanel();
	
	if (categoryTable) then
		categoryTable.pageData[#categoryTable.pageData + 1] = {
			noLineBreak = noLineBreak,
			sortData = sortData,
			Callback = Callback,
			htmlCode = htmlCode
		};
		
		uniqueID = #categoryTable.pageData;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
	
	return uniqueID;
end;

-- A function to remove some code.
function CloudScript.directory:RemoveCode(category, uniqueID, forceRemove)
	local panel = self:GetPanel();
	
	if (category) then
		local categoryTable, categoryKey = self:GetCategory(category);
		
		if (categoryTable) then
			if (uniqueID and !categoryTable.isHTML) then
				if ( categoryTable.pageData[uniqueID] ) then
					categoryTable.pageData[uniqueID] = nil;
				end;
				
				if (#categoryTable.pageData == 0) then
					self:RemoveCode(category);
				end;
			else
				local removeCategory = true;
				
				if (!forceRemove and !categoryTable.isHTML) then
					for k, v in pairs(self.stored) do
						if (v.parent == category) then
							removeCategory = true;
							
							break;
						end;
					end;
				end;
				
				if (removeCategory) then
					self.stored[categoryKey] = nil;
				end;
			end;
		end;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
end;

-- A function to add a page.
function CloudScript.directory:AddPage(category, htmlCode, isWebsite)
	self:AddCategory(category, false);
	
	local categoryTable = self:GetCategory(category);
	local panel = self:GetPanel();
	
	if (categoryTable) then
		categoryTable.isWebsite = isWebsite;
		categoryTable.pageData = htmlCode;
		categoryTable.isHTML = true;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
end;

-- A function to get the directory panel.
function CloudScript.directory:GetPanel()
	return self.panel;
end;

CloudScript.directory:SetCategorySorting("Commands", function(a, b)
	return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode);
end);

CloudScript.directory:SetCategorySorting("Plugins", function(a, b)
	return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode);
end);

CloudScript.directory:SetCategorySorting("Flags", function(a, b)
	local hasA = CloudScript.player:HasFlags(CloudScript.Client, a.sortData);
	local hasB = CloudScript.player:HasFlags(CloudScript.Client, b.sortData);
	
	if (hasA and hasB) then
		return a.sortData < b.sortData;
	elseif (hasA) then
		return true;
	else
		return false;
	end;
end);

CloudScript.directory:SetCategoryFormatting("Flags", [[
	<style type="text/css">
		.cloudTable
		{
			width: 100%;
		}

		.cloudHeader
		{
			background-color: #FFF;
			font-size: 12px;
			padding: 2px;
			margin: 0;
			width: 50%;
		}
	</style>
	
	<table class="cloudTable">
		<tr>
			<td class="cloudBackground cloudHeader">
				<span class="cloudTitle">FLAG</span>
			</td>
			<td class="cloudBackground cloudHeader">
				<span class="cloudTitle">DETAILS</span>
			</td>
		</tr>
		{information}
	</table>
]], true);

CloudScript.directory:SetCategoryTip("CloudScript", "Contains topics based on the CloudScript framework.");
CloudScript.directory:SetCategoryTip("Commands", "Contains a list of commands and their syntax.");

CloudScript.directory:AddCategoryPage("Updates", "CloudScript", "http://kurozael.com/CloudScript/updates/", true);
CloudScript.directory:AddCategoryPage("Credits", "CloudScript", "http://kurozael.com/CloudScript/credits/", true);
CloudScript.directory:AddCategoryPage("Agreement", "CloudScript", "http://kurozael.com/CloudScript/agreement/", true);
CloudScript.directory:AddCategory("Plugins", "CloudScript");
CloudScript.directory:AddCategory("Flags", "CloudScript");