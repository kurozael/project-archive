--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity()
	self:LoadSpawnPoints();
end;

-- Called when a player spawns.
function MOUNT:PlayerSpawn(player)
	if ( player:HasInitialized() ) then
		local position;
		local vocation = kuroScript.vocation.Get( player:Team() );
		local class = player:QueryCharacter("class");
		
		-- Check if a statement is true.
		if (vocation) then
			if (self.spawnPoints[vocation.name] and #self.spawnPoints[vocation.name] > 0) then
				position = self.spawnPoints[vocation.name][ math.random( 1, #self.spawnPoints[vocation.name] ) ];
				
				-- Check if a statement is true.
				if (position) then
					player:SetPos( position + Vector(0, 0, 8) );
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (!position) then
			if ( self.spawnPoints[class] and #self.spawnPoints[class] > 0) then
				position = self.spawnPoints[class][ math.random( 1, #self.spawnPoints[class] ) ];
				
				-- Check if a statement is true.
				if (position) then
					player:SetPos( position + Vector(0, 0, 8) );
				end;
			elseif ( self.spawnPoints["default"] ) then
				if (#self.spawnPoints["default"] > 0) then
					position = self.spawnPoints["default"][ math.random( 1, #self.spawnPoints["default"] ) ];
					
					-- Check if a statement is true.
					if (position) then
						player:SetPos( position + Vector(0, 0, 8) );
					end;
				end;
			end;
		end;
	end;
end;