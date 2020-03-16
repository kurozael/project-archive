--[[
Name: "cl_directory.lua".
Product: "kuroScript".
--]]

kuroScript.directory = {};
kuroScript.directory.stored = {};
kuroScript.directory.friendlyNames = {};

-- A function to get a category.
function kuroScript.directory.GetCategory(category)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.directory.stored) do
		if (v.category == category) then
			return v;
		end;
	end;
end;

-- A function to add a HTML category.
function kuroScript.directory.AddHTMLCategory(category, parent, text, website)
	kuroScript.directory.AddCategory(category, parent);
	kuroScript.directory.AddHTML(category, text, website);
end;

-- A function to set a friendly name.
function kuroScript.directory.SetFriendlyName(category, name)
	kuroScript.directory.friendlyNames[category] = name;
end;

-- A function to get a friendly name.
function kuroScript.directory.GetFriendlyName(category)
	return kuroScript.directory.friendlyNames[category] or category;
end;

-- A function to get whether a category exists.
function kuroScript.directory.CategoryExists(category)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.directory.stored) do
		if (v.category == category) then
			return true;
		end;
	end;
end;

-- A function to add a category.
function kuroScript.directory.AddCategory(category, parent)
	if (parent) then kuroScript.directory.AddCategory(parent, false); end;
	
	-- Check if a statement is true.
	if ( !kuroScript.directory.CategoryExists(category) ) then
		if (parent == false) then parent = nil; end;
		
		-- Set some information.
		kuroScript.directory.stored[#kuroScript.directory.stored + 1] = {
			information = {},
			category = category,
			parent = parent
		};
	elseif (parent != false) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.directory.stored) do
			if (v.category == category) then
				v.parent = parent;
			end;
		end;
	end;
	
	-- Return the category and parent.
	return category, parent;
end;

-- A function to add some information.
function kuroScript.directory.AddInformation(category, text, tip, callback)
	local k, v;
	
	-- Check if a statement is true.
	if ( text and string.find(text, "\n") ) then
		local wrappedUniqueIDs = {};
		
		-- Loop through each value in a table.
		for k, v in ipairs( kuroScript.frame:ExplodeString("\n", text) ) do
			local uniqueIDs = kuroScript.directory.AddInformation(category, v, tip, callback);
			
			-- Check if a statement is true.
			if (uniqueIDs) then
				table.Add(wrappedUniqueIDs, uniqueIDs);
			end;
		end;
		
		-- Check if a statement is true.
		if (#wrappedUniqueIDs > 0) then
			return wrappedUniqueIDs;
		end;
	else
		kuroScript.directory.AddCategory(category, false);
		
		-- Set some information.
		local categoryTable = kuroScript.directory.GetCategory(category);
		local uniqueIDs = {};
		local panel = kuroScript.directory.GetPanel();
		
		-- Check if a statement is true.
		if (categoryTable) then
			categoryTable.information[#categoryTable.information + 1] = {
				callback = callback,
				text = text,
				tip = tip
			};
			
			-- Set some information.
			uniqueIDs[#uniqueIDs + 1] = #categoryTable.information;
		end;
		
		-- Check if a statement is true.
		if (panel) then panel:Rebuild(); end;
		
		-- Check if a statement is true.
		if (#uniqueIDs > 0) then
			return uniqueIDs;
		end;
	end;
end;

-- A function to remove some information.
function kuroScript.directory.Remove(category, uniqueID)
	local panel = kuroScript.directory.GetPanel();
	local k, v;
	
	-- Loop through each value in a table.
	if (type(uniqueID) == "table") then
		for k, v in ipairs(uniqueID) do
			kuroScript.directory.Remove(category, v);
		end;
		
		-- Return to break the function.
		return;
	end;
	
	-- Check if a statement is true.
	if (category) then
		for k, v in pairs(kuroScript.directory.stored) do
			if (v.category == category) then
				if (uniqueID and !v.html) then
					if ( kuroScript.directory.stored[k].information[uniqueID] ) then
						kuroScript.directory.stored[k].information[uniqueID] = nil;
					end;
					
					-- Check if a statement is true.
					if (#kuroScript.directory.stored[k].information == 0) then
						kuroScript.directory.Remove(category);
					end;
				else
					for k2, v2 in pairs(kuroScript.directory.stored) do
						if (v2.parent == category) then
							kuroScript.directory.Remove(v2.category);
						end;
					end;
					
					-- Check if a statement is true.
					if (v.parent) then
						local removeParent = true;
						
						-- Loop through each value in a table.
						for k2, v2 in pairs(kuroScript.directory.stored) do
							if (v2.parent == v.parent) then
								removeParent = nil; break;
							elseif (v2.category == v.parent) then
								if (#v2.information > 0) then
									removeParent = nil; break;
								end;
							end;
						end;
						
						-- Check if a statement is true.
						if (removeParent) then
							kuroScript.directory.Remove(v.parent);
						end;
					end;
					
					-- Set some information.
					kuroScript.directory.stored[k] = nil;
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (panel) then panel:Rebuild(); end;
end;

-- A function to add some HTML information.
function kuroScript.directory.AddHTML(category, text, website)
	kuroScript.directory.AddCategory(category, false);
	
	-- Set some information.
	local categoryTable = kuroScript.directory.GetCategory(category);
	local panel = kuroScript.directory.GetPanel();
	
	-- Check if a statement is true.
	if (categoryTable) then
		categoryTable.information = text;
		categoryTable.website = website;
		categoryTable.html = true;
	end;
	
	-- Check if a statement is true.
	if (panel) then panel:Rebuild(); end;
end;

-- A function to get the directory panel.
function kuroScript.directory.GetPanel()
	return kuroScript.directory.panel;
end;