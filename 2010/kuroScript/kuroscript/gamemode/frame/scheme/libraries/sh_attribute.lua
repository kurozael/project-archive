--[[
Name: "sh_attribute.lua".
Product: "kuroScript".
--]]

kuroScript.attribute = {};
kuroScript.attribute.stored = {};
kuroScript.attribute.buffer = {};

-- A function to register a new attribute.
function kuroScript.attribute.Register(attribute)
	attribute.uniqueID = attribute.uniqueID or string.lower( string.gsub(attribute.name, "%s", "_") );
	attribute.index = kuroScript.frame:GetShortCRC(attribute.name);
	
	-- Set some information.
	kuroScript.attribute.stored[attribute.uniqueID] = attribute;
	kuroScript.attribute.buffer[attribute.index] = attribute;
	
	-- Return the unique ID.
	return attribute.uniqueID;
end;

-- A function to get an attribute by its name.
function kuroScript.attribute.Get(name)
	if (name) then
		if ( kuroScript.attribute.buffer[name] ) then
			return kuroScript.attribute.buffer[name];
		elseif ( kuroScript.attribute.stored[name] ) then
			return kuroScript.attribute.stored[name];
		else
			local attribute;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.attribute.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (attribute) then
						if ( string.len(v.name) < string.len(attribute.name) ) then
							attribute = v;
						end;
					else
						attribute = v;
					end;
				end;
			end;
			
			-- Return the attribute.
			return attribute;
		end;
	end;
end;