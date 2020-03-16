--[[
Name: "cl_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when the local player has entered an area.
function MOUNT:PlayerEnteredArea(name, minimum, maximum)
	datastream.StreamToServer( "ks_EnteredArea", {name, minimum, maximum} );
end;

-- Called each tick.
function MOUNT:Tick()
	if ( ValidEntity(g_LocalPlayer) and g_LocalPlayer:HasInitialized() ) then
		local lastAreaName = self.currentAreaName;
		local leftAreaName;
		local curTime = UnPredictedCurTime();
		local k, v;
		
		-- Check if a statement is true.
		if (!self.nextCheckAreaNames or curTime >= self.nextCheckAreaNames) then
			self.nextCheckAreaNames = curTime + 1;
			
			-- Loop through each value in a table.
			for k, v in pairs(self.areaNames) do
				if ( kuroScript.entity.IsInBox(g_LocalPlayer, v.minimum, v.maximum) ) then
					if (self.currentAreaName != v.name) then
						self.currentAreaName = v.name;
						
						-- Add some cinematic text.
						kuroScript.frame:AddCinematicText(v.name);
						
						-- Call a gamemode hook.
						hook.Call("PlayerEnteredArea", kuroScript.frame, v.name, v.minimum, v.maximum);
						
						-- Check if a statement is true.
						if (lastAreaName) then
							hook.Call("PlayerExitedArea", kuroScript.frame, lastAreaName, v.name);
						end;
					end;
					
					-- Return to break the function.
					return;
				elseif (lastAreaName == v.name) then
					leftAreaName = v.name;
				end;
			end;
			
			-- Check if a statement is true.
			if (leftAreaName) then
				hook.Call("PlayerExitedArea", kuroScript.frame, leftAreaName);
			end;
		end;
	end;
end;