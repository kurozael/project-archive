--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to load the player spawn points.
function PLUGIN:LoadSpawnPoints()
	self.spawnPoints = {};
	
	local spawnPoints = openAura:RestoreSchemaData( "plugins/spawnpoints/"..game.GetMap() );
	
	for k, v in pairs(spawnPoints) do
		local faction = openAura.faction:Get(k);
		local class = openAura.class:Get(k);
		local name;
		
		if (class or faction) then
			if (faction) then
				name = faction.name;
			else
				name = class.name;
			end;
			
			self.spawnPoints[name] = {};
			
			for k2, v2 in pairs(v) do
				if (type(v2) == "string") then
					local x, y, z = string.match(v2, "(.-), (.-), (.+)");
					
					v2 = Vector( tonumber(x), tonumber(y), tonumber(z) );
				end;
				
				self.spawnPoints[name][#self.spawnPoints[name] + 1] = v2;
			end;
		elseif (k == "default") then
			self.spawnPoints["default"] = {};
			
			for k2, v2 in pairs(v) do
				if (type(v2) == "string") then
					local x, y, z = string.match(v2, "(.-), (.-), (.+)");
					
					v2 = Vector( tonumber(x), tonumber(y), tonumber(z) );
				end;
				
				self.spawnPoints["default"][#self.spawnPoints["default"] + 1] = v2;
			end;
		end;
	end;
end;

-- A function to save the player spawn points.
function PLUGIN:SaveSpawnPoints()
	local spawnPoints = {};
	
	for k, v in pairs(self.spawnPoints) do
		spawnPoints[k] = {};
		
		for k2, v2 in pairs(v) do
			spawnPoints[k][#spawnPoints[k] + 1] = v2.x..", "..v2.y..", "..v2.z;
		end;
	end;
	
	openAura:SaveSchemaData("plugins/spawnpoints/"..game.GetMap(), spawnPoints);
end;