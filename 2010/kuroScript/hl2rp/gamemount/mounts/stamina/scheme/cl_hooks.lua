--[[
Name: "cl_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when the top bars are needed.
function MOUNT:GetTopBars(topBars)
	local stamina = g_LocalPlayer:GetSharedVar("ks_Stamina");
	
	-- Check if a statement is true.
	if (!self.stamina) then
		self.stamina = stamina;
	else
		self.stamina = math.Approach(self.stamina, stamina, 1);
	end;
	
	-- Check if a statement is true.
	if (self.stamina < 90) then
		topBars:Add("+", "STAMINA", "Stamina", self.stamina, 100, self.stamina < 10);
	end;
end;

-- Called each tick.
function MOUNT:Tick()
	if ( kuroScript.game:PlayerIsCombine(g_LocalPlayer) ) then
		local curTime = CurTime();
		local stamina = g_LocalPlayer:GetSharedVar("ks_Stamina");
		
		-- Check if a statement is true.
		if (!self.nextStaminaWarning or curTime >= self.nextStaminaWarning) then
			if (self.lastStamina and self.lastStamina > 0 and stamina == 0) then
				kuroScript.game:AddCombineDisplayLine( "WARNING! Maximum stamina exhaustion...", Color(255, 0, 0, 255) );
				
				-- Set some information.
				self.nextStaminaWarning = curTime + 5;
			elseif (self.lastStamina and self.lastStamina > 50 and stamina < 50) then
				kuroScript.game:AddCombineDisplayLine( "Heartrate increasing to 125 BPM", Color(255, 0, 0, 255) );
				
				-- Set some information.
				self.nextStaminaWarning = curTime + 5;
			elseif (self.lastStamina and stamina > self.lastStamina) then
				if (stamina == 100) then
					kuroScript.game:AddCombineDisplayLine( "Heartrate nominal...", Color(0, 255, 0, 255) );
				else
					kuroScript.game:AddCombineDisplayLine( "Heartrate decreasing...", Color(0, 0, 255, 255) );
				end;
				
				-- Set some information.
				self.nextStaminaWarning = curTime + 5;
			end;
		end;
		
		-- Set some information.
		self.lastStamina = stamina;
	end;
end;

-- Called when the local player presses a bind.
function MOUNT:PlayerBindPress(player, bind, pressed)
	local stamina = g_LocalPlayer:GetSharedVar("ks_Stamina");
	
	-- Check if a statement is true.
	if (stamina <= 10) then
		if ( !g_LocalPlayer:InVehicle() and string.find(bind, "+jump") and !g_LocalPlayer:IsRagdolled() ) then
			return true;
		end;
	end;
end;
