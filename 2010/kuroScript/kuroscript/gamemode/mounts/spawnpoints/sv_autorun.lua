--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to load the player spawn points.
function MOUNT:LoadSpawnPoints()
	self.spawnPoints = {};
	
	-- Set some information.
	local spawnPoints = kuroScript.frame:RestoreGameData( "mounts/spawnpoints/"..game.GetMap() );
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(spawnPoints) do
		local vocation = kuroScript.vocation.Get(k);
		local class = kuroScript.class.Get(k);
		local name;
		
		-- Check if a statement is true.
		if (vocation or class) then
			if (class) then
				name = class.name;
			else
				name = vocation.name;
			end;
			
			-- Set some information.
			self.spawnPoints[name] = {};
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v) do
				if (type(v2) == "string") then
					local x, y, z = string.match(v2, "(.-), (.-), (.+)");
					
					-- Set some information.
					v2 = Vector( tonumber(x), tonumber(y), tonumber(z) );
				end;
				
				-- Set some information.
				self.spawnPoints[name][#self.spawnPoints[name] + 1] = v2;
			end;
		elseif (k == "default") then
			self.spawnPoints["default"] = {};
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v) do
				if (type(v2) == "string") then
					local x, y, z = string.match(v2, "(.-), (.-), (.+)");
					
					-- Set some information.
					v2 = Vector( tonumber(x), tonumber(y), tonumber(z) );
				end;
				
				-- Set some information.
				self.spawnPoints["default"][#self.spawnPoints["default"] + 1] = v2;
			end;
		end;
	end;
end;

-- A function to save the player spawn points.
function MOUNT:SaveSpawnPoints()
	local spawnPoints = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(self.spawnPoints) do
		spawnPoints[k] = {};
		
		-- Loop through each value in a table.
		for k2, v2 in pairs(v) do
			spawnPoints[k][#spawnPoints[k] + 1] = v2.x..", "..v2.y..", "..v2.z;
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/spawnpoints/"..game.GetMap(), spawnPoints);
end;