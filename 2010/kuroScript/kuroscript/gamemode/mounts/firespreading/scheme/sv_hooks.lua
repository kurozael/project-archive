--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called each tick.
function MOUNT:Tick()
	local curTime = CurTime();
	local k2, v2;
	local k, v;
	
	-- Check if a statement is true.
	if (!self.nextFireSpread or curTime >= self.nextFireSpread) then
		self.nextFireSpread = curTime + 4;
		
		-- Loop through each value in a table.
		for k, v in pairs(self.entityFires) do
			if ( !ValidEntity(k) or !k:IsOnFire() ) then
				self.entityFires[k] = nil;
			elseif (!k._NextIgnite or curTime >= k._NextIgnite) then
				local entities = ents.FindInSphere(k:GetPos(), k);
				
				-- Check if a statement is true.
				for k2, v2 in ipairs(entities) do
					if ( !v2:IsOnFire() ) then
						local isPlayer = v2:IsPlayer();
						local isNPC = v2:IsNPC();
						local class = v2:GetClass();
						
						-- Check if a statement is true.
						if (class == "prop_physics" or class == "prop_physics_multiplayer" or isPlayer or isNPC) then
							if (isPlayer or isNPC) then
								if (math.random(1, 8) == 8) then
									if ( isNPC and kuroScript.entity.CanSeeNPC(k, v2, 0.9) ) then
										v2:Ignite(math.random(1, 60), 0);
									elseif ( isPlayer and kuroScript.entity.CanSeePlayer(k, v2, 0.9) ) then
										v2:Ignite(math.random(1, 30), 0);
									end;
								end;
							elseif ( kuroScript.entity.CanSeeEntity(k, v2, 0.9) ) then
								v2:Ignite(math.random(60, 600), 0);
							end;
							
							-- Check if a statement is true.
							if ( v2:IsOnFire() ) then
								self.entityFires[v2] = v2:BoundingRadius() * 3;
								
								-- Set some information.
								v2._NextIgnite = curTime + 1;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;