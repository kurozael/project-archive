--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a data stream.
datastream.Hook("ks_EnteredArea", function(player, handler, uniqueID, rawData, procData)
	if ( procData[1] and procData[2] and procData[3] ) then
		hook.Call( "PlayerEnteredArea", kuroScript.frame, player, procData[1], procData[2], procData[3] );
	end;
end);

-- A function to load the area names.
function MOUNT:LoadAreaNames()
	self.areaNames = {};
	
	-- Set some information.
	local areaNames = kuroScript.frame:RestoreGameData( "mounts/areanames/"..game.GetMap() );
	
	-- Loop through each value in a table.
	for k, v in pairs(areaNames) do
		if (type(v) == "string") then
			local name, minX, minY, minZ, maxX, maxY, maxZ = string.match(v, "Name%[(.+)%], (.+), (.+), (.+); (.+), (.+), (.+)");
			
			-- Set some information.
			local data = {
				name = name,
				minimum = Vector( tonumber(minX), tonumber(minY), tonumber(minZ) ),
				maximum = Vector( tonumber(maxX), tonumber(maxY), tonumber(maxZ) )
			};
			
			-- Set some information.
			self.areaNames[#self.areaNames + 1] = data;
		else
			self.areaNames[#self.areaNames + 1] = v;
		end;
	end;
end;

-- A function to save the area names.
function MOUNT:SaveAreaNames()
	kuroScript.frame:SaveGameData("mounts/areanames/"..game.GetMap(), self.areaNames);
end;