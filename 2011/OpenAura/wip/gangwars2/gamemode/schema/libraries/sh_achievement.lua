--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.achievement = {};
openAura.achievement.stored = {};
openAura.achievement.buffer = {};

-- A function to get the achievement buffer.
function openAura.achievement:GetBuffer()
	return self.buffer;
end;

-- A function to get all achievements.
function openAura.achievement:GetAll()
	return self.stored;
end;

-- A function to register a new achievement.
function openAura.achievement:Register(achievement)
	achievement.uniqueID = achievement.uniqueID or string.lower( string.gsub(achievement.name, "%s", "_") );
	achievement.index = openAura:GetShortCRC(achievement.name);
	
	self.stored[achievement.uniqueID] = achievement;
	self.buffer[achievement.index] = achievement;
	
	resource.AddFile("materials/"..achievement.image..".vtf");
	resource.AddFile("materials/"..achievement.image..".vmt");
	
	return achievement.uniqueID;
end;

-- A function to get an achievement by its name.
function openAura.achievement:Get(name)
	if (name) then
		if ( self.buffer[name] ) then
			return self.buffer[name];
		elseif ( self.stored[name] ) then
			return self.stored[name];
		else
			local achievement = nil;
			
			for k, v in pairs(self.stored) do
				if ( string.find( string.lower(v.name), string.lower(name) ) ) then
					if (achievement) then
						if ( string.len(v.name) < string.len(achievement.name) ) then
							achievement = v;
						end;
					else
						achievement = v;
					end;
				end;
			end;
			
			return achievement;
		end;
	end;
end;