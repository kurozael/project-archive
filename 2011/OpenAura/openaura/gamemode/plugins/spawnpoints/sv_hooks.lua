--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	self:LoadSpawnPoints();
end;

-- Called when a player spawns.
function PLUGIN:PlayerSpawn(player)
	if ( player:HasInitialized() ) then
		local position = nil;
		local faction = player:QueryCharacter("faction");
		local class = openAura.class:Get( player:Team() );
		
		if (class) then
			if (self.spawnPoints[class.name] and #self.spawnPoints[class.name] > 0) then
				position = self.spawnPoints[class.name][ math.random( 1, #self.spawnPoints[class.name] ) ];
				
				if (position) then
					player:SetPos( position + Vector(0, 0, 8) );
				end;
			end;
		end;
		
		if (!position) then
			if ( self.spawnPoints[faction] and #self.spawnPoints[faction] > 0) then
				position = self.spawnPoints[faction][ math.random( 1, #self.spawnPoints[faction] ) ];
				
				if (position) then
					player:SetPos( position + Vector(0, 0, 8) );
				end;
			elseif ( self.spawnPoints["default"] ) then
				if (#self.spawnPoints["default"] > 0) then
					position = self.spawnPoints["default"][ math.random( 1, #self.spawnPoints["default"] ) ];
					
					if (position) then
						player:SetPos( position + Vector(0, 0, 8) );
					end;
				end;
			end;
		end;
	end;
end;