--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.upgrade = {};
openAura.upgrade.stored = {};
openAura.upgrade.buffer = {};

-- A function to get the upgrade buffer.
function openAura.upgrade:GetBuffer()
	return self.buffer;
end;

-- A function to get all upgrades.
function openAura.upgrade:GetAll()
	return self.stored;
end;

-- A function to register a new upgrade.
function openAura.upgrade:Register(upgrade)
	upgrade.uniqueID = upgrade.uniqueID or string.lower( string.gsub(upgrade.name, "%s", "_") );
	upgrade.index = openAura:GetShortCRC(upgrade.name);
	
	self.stored[upgrade.uniqueID] = upgrade;
	self.buffer[upgrade.index] = upgrade;
	
	resource.AddFile("materials/"..upgrade.image..".vtf");
	resource.AddFile("materials/"..upgrade.image..".vmt");
	
	return upgrade.uniqueID;
end;

-- A function to get an upgrade by its name.
function openAura.upgrade:Get(name)
	if (name) then
		if ( self.buffer[name] ) then
			return self.buffer[name];
		elseif ( self.stored[name] ) then
			return self.stored[name];
		else
			local upgrade = nil;
			
			for k, v in pairs(self.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (upgrade) then
						if ( string.len(v.name) < string.len(upgrade.name) ) then
							upgrade = v;
						end;
					else
						upgrade = v;
					end;
				end;
			end;
			
			return upgrade;
		end;
	end;
end;