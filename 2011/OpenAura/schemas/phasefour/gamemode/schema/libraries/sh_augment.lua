--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.augment = {};
openAura.augment.stored = {};
openAura.augment.buffer = {};

-- A function to get the augment buffer.
function openAura.augment:GetBuffer()
	return self.buffer;
end;

-- A function to get all augments.
function openAura.augment:GetAll()
	return self.stored;
end;

-- A function to register a new augment.
function openAura.augment:Register(augment)
	augment.uniqueID = augment.uniqueID or string.lower( string.gsub(augment.name, "%s", "_") );
	augment.index = openAura:GetShortCRC(augment.name);
	
	self.stored[augment.uniqueID] = augment;
	self.buffer[augment.index] = augment;
	
	resource.AddFile("materials/"..augment.image..".vtf");
	resource.AddFile("materials/"..augment.image..".vmt");
	
	return augment.uniqueID;
end;

-- A function to get an augment by its name.
function openAura.augment:Get(name)
	if (name) then
		if ( self.buffer[name] ) then
			return self.buffer[name];
		elseif ( self.stored[name] ) then
			return self.stored[name];
		else
			local augment = nil;
			
			for k, v in pairs(self.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (augment) then
						if ( string.len(v.name) < string.len(augment.name) ) then
							augment = v;
						end;
					else
						augment = v;
					end;
				end;
			end;
			
			return augment;
		end;
	end;
end;

openAura:IncludeDirectory(openAura:GetSchemaFolder().."/gamemode/schema/augments/");