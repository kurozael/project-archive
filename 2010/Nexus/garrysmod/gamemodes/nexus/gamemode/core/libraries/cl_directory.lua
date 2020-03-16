--[[
Name: "cl_directory.lua".
Product: "nexus".
--]]

nexus.directory = {};
nexus.directory.tips = {};
nexus.directory.stored = {};
nexus.directory.sorting = {};
nexus.directory.formatting = {};
nexus.directory.friendlyNames = {};

-- A function to get a category.
function nexus.directory.GetCategory(category)
	for k, v in pairs(nexus.directory.stored) do
		if (v.category == category) then
			return v, k;
		end;
	end;
end;

-- A function to set a category tip.
function nexus.directory.SetCategoryTip(category, tip)
	nexus.directory.tips[category] = tip;
end;

-- A function to get a category tip.
function nexus.directory.GetCategoryTip(category)
	return nexus.directory.tips[category];
end;

-- A function to add a category page.
function nexus.directory.AddCategoryPage(category, parent, htmlCode, isWebsite)
	nexus.directory.AddCategory(category, parent);
	nexus.directory.AddPage(category, htmlCode, isWebsite);
end;

-- A function to set a friendly name.
function nexus.directory.SetFriendlyName(category, name)
	nexus.directory.friendlyNames[category] = name;
end;

-- A function to get a friendly name.
function nexus.directory.GetFriendlyName(category)
	return nexus.directory.friendlyNames[category] or category;
end;

-- A function to set category formatting.
function nexus.directory.SetCategoryFormatting(category, htmlCode, noLineBreaks)
	nexus.directory.formatting[category] = {
		noLineBreaks = noLineBreaks,
		htmlCode = htmlCode
	};
end;

-- A function to get category formatting.
function nexus.directory.GetCategoryFormatting(category)
	return nexus.directory.formatting[category];
end;

-- A function to set category sorting.
function nexus.directory.SetCategorySorting(category, Callback)
	nexus.directory.sorting[category] = Callback;
end;

-- A function to get category sorting.
function nexus.directory.GetCategorySorting(category)
	return nexus.directory.sorting[category];
end;

-- A function to get whether a category exists.
function nexus.directory.CategoryExists(category)
	for k, v in pairs(nexus.directory.stored) do
		if (v.category == category) then
			return true;
		end;
	end;
end;

-- A function to add a category.
function nexus.directory.AddCategory(category, parent)
	if (parent) then
		nexus.directory.AddCategory(parent, false);
	end;
	
	if ( !nexus.directory.CategoryExists(category) ) then
		if (parent == false) then parent = nil; end;
		
		nexus.directory.stored[#nexus.directory.stored + 1] = {
			category = category,
			pageData = {},
			parent = parent
		};
	elseif (parent != false) then
		for k, v in pairs(nexus.directory.stored) do
			if (v.category == category) then
				v.parent = parent;
			end;
		end;
	end;
	
	return category, parent;
end;

-- A function to add some code.
function nexus.directory.AddCode(category, htmlCode, Callback, data)
	nexus.directory.AddCategory(category, false);
	
	local categoryTable = nexus.directory.GetCategory(category);
	local uniqueID;
	local panel = nexus.directory.GetPanel();
	
	if (categoryTable) then
		categoryTable.pageData[#categoryTable.pageData + 1] = {
			Callback = Callback,
			htmlCode = htmlCode,
			data = data
		};
		
		uniqueID = #categoryTable.pageData;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
	
	return uniqueID;
end;

-- A function to remove some code.
function nexus.directory.RemoveCode(category, uniqueID, forceRemove)
	local panel = nexus.directory.GetPanel();
	
	if (category) then
		local categoryTable, categoryKey = nexus.directory.GetCategory(category);
		
		if (categoryTable) then
			if (uniqueID and !categoryTable.isHTML) then
				if ( categoryTable.pageData[uniqueID] ) then
					categoryTable.pageData[uniqueID] = nil;
				end;
				
				if (#categoryTable.pageData == 0) then
					nexus.directory.RemoveCode(category);
				end;
			else
				local removeCategory = true;
				
				if (!forceRemove and !categoryTable.isHTML) then
					for k, v in pairs(nexus.directory.stored) do
						if (v.parent == category) then
							removeCategory = true;
							
							break;
						end;
					end;
				end;
				
				if (removeCategory) then
					nexus.directory.stored[categoryKey] = nil;
				end;
			end;
		end;
	end;
	
	if (panel) then
		panel:Rebuild();
	end;
end;

-- A function to add a page.
function nexus.directory.AddPage(category, htmlCode, isWebsite)
	nexus.directory.AddCategory(category, false);
	
	local categoryTable = nexus.directory.GetCategory(category);
	local panel = nexus.directory.GetPanel();
	
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
function nexus.directory.GetPanel()
	return nexus.directory.panel;
end;

nexus.directory.SetCategorySorting("Commands", function(a, b)
	return (a.data or a.htmlCode) < (b.data or b.htmlCode);
end);

nexus.directory.SetCategorySorting("Mounts", function(a, b)
	return (a.data or a.htmlCode) < (b.data or b.htmlCode);
end);

nexus.directory.SetCategoryFormatting("Flags", [[
	<style type="text/css">
		table, td {
			border-color: #000;
			border-style: solid;
		}

		table {
			border-collapse: collapse;
			border-spacing: 0;
			border-width: 0 0 1px 1px;
			width: 100%;
		}

		td {
			background-color: #FFF;
			border-width: 1px 1px 0 0;
			padding: 2px;
			margin: 0;
		}
	</style>
	
	<table>
		<tr>
			<td style="background-color: #9F9F9F"><b>Flag</b></td>
			<td style="background-color: #9F9F9F"><b>Details</b></td>
		</tr>
		{information}
	</table>
]], true);

nexus.directory.SetCategoryTip("Framework", "Contains topics based on the nexus framework.");
nexus.directory.SetCategoryTip("Commands", "Contains a list of commands and their syntax.");

nexus.directory.AddCategory("Mounts", "Framework");
nexus.directory.AddCategory("Flags", "Framework");