--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.trophy = {};
openAura.trophy.stored = {};
openAura.trophy.buffer = {};

-- A function to get the trophy buffer.
function openAura.trophy:GetBuffer()
	return self.buffer;
end;

-- A function to get all trophies.
function openAura.trophy:GetAll()
	return self.stored;
end;

-- A function to register a new trophy.
function openAura.trophy:Register(trophy)
	trophy.uniqueID = trophy.uniqueID or string.lower( string.gsub(trophy.name, "%s", "_") );
	trophy.index = openAura:GetShortCRC(trophy.name);
	
	self.stored[trophy.uniqueID] = trophy;
	self.buffer[trophy.index] = trophy;
	
	resource.AddFile("materials/"..trophy.image..".vtf");
	resource.AddFile("materials/"..trophy.image..".vmt");
	
	return trophy.uniqueID;
end;

-- A function to get an trophy by its name.
function openAura.trophy:Get(name)
	if (name) then
		if ( self.buffer[name] ) then
			return self.buffer[name];
		elseif ( self.stored[name] ) then
			return self.stored[name];
		else
			local trophy = nil;
			
			for k, v in pairs(self.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (trophy) then
						if ( string.len(v.name) < string.len(trophy.name) ) then
							trophy = v;
						end;
					else
						trophy = v;
					end;
				end;
			end;
			
			return trophy;
		end;
	end;
end;

openAura:IncludeDirectory(openAura:GetSchemaFolder().."/gamemode/schema/trophies/");