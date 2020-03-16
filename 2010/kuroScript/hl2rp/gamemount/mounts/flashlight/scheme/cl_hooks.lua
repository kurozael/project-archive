--[[
Name: "cl_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when the top bars are needed.
function MOUNT:GetTopBars(topBars)
	local flashlight = g_LocalPlayer:GetSharedVar("ks_Flashlight");

	-- Check if a statement is true.
	if (!self.flashlight) then
		self.flashlight = flashlight;
	else
		self.flashlight = math.Approach(self.flashlight, flashlight, 1);
	end;
	
	-- Check if a statement is true.
	if (self.flashlight < 90 and self.flashlight != -1) then
		topBars:Add("+", "FLASHLIGHT", "Flashlight", self.flashlight, 100, self.flashlight < 10);
	end;
end;

-- Called each tick.
function MOUNT:Tick()
	if ( kuroScript.game:PlayerIsCombine(g_LocalPlayer) ) then
		local curTime = CurTime();
		local flashlight = g_LocalPlayer:GetSharedVar("ks_Flashlight");
		
		-- Check if a statement is true.
		if (!self.nextFlashlightWarning or curTime >= self.nextFlashlightWarning) then
			if (flashlight != -1) then
				if (self.lastFlashlight and self.lastFlashlight > 0 and flashlight == 0) then
					kuroScript.game:AddCombineDisplayLine( "WARNING! External battery consumption exhausted...", Color(255, 0, 0, 255) );
					
					-- Set some information.
					self.nextFlashlightWarning = curTime + 5;
				elseif (self.lastFlashlight and self.lastFlashlight > 50 and flashlight < 50) then
					kuroScript.game:AddCombineDisplayLine( "WARNING! External battery consumption high...", Color(255, 0, 0, 255) );
					
					-- Set some information.
					self.nextFlashlightWarning = curTime + 5;
				elseif (self.lastFlashlight and flashlight > self.lastFlashlight) then
					if (flashlight == 100) then
						kuroScript.game:AddCombineDisplayLine( "External battery restored...", Color(0, 255, 0, 255) );
					else
						kuroScript.game:AddCombineDisplayLine( "External battery regenerating...", Color(0, 0, 255, 255) );
					end;
					
					-- Set some information.
					self.nextFlashlightWarning = curTime + 5;
				end;
			end;
		end;
		
		-- Set some information.
		self.lastFlashlight = flashlight;
	end;
end;