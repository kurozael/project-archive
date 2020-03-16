--[[
Name: "sh_attribute.lua".
Product: "nexus".
--]]

nexus.attribute = {};
nexus.attribute.stored = {};
nexus.attribute.buffer = {};

-- A function to get the attribute buffer.
function nexus.attribute.GetBuffer()
	return nexus.attribute.buffer;
end;

-- A function to get all attributes.
function nexus.attribute.GetAll()
	return nexus.attribute.stored;
end;

-- A function to register a new attribute.
function nexus.attribute.Register(attribute)
	attribute.uniqueID = attribute.uniqueID or string.lower( string.gsub(attribute.name, "%s", "_") );
	attribute.index = NEXUS:GetShortCRC(attribute.name);
	attribute.cache = {};
	
	for i = -attribute.maximum, attribute.maximum do
		attribute.cache[i] = {};
	end;
	
	nexus.attribute.GetAll()[attribute.uniqueID] = attribute;
	nexus.attribute.GetBuffer()[attribute.index] = attribute;
	
	return attribute.uniqueID;
end;

-- A function to get an attribute by its name.
function nexus.attribute.Get(name)
	if (name) then
		if ( nexus.attribute.GetBuffer()[name] ) then
			return nexus.attribute.GetBuffer()[name];
		elseif ( nexus.attribute.GetAll()[name] ) then
			return nexus.attribute.GetAll()[name];
		else
			local attribute;
			
			for k, v in pairs( nexus.attribute.GetAll() ) do
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
			
			return attribute;
		end;
	end;
end;