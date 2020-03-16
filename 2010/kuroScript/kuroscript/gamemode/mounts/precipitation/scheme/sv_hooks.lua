--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called each tick.
function MOUNT:Tick()
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!self.nextTick or curTime >= self.nextTick) then
		self.nextTick = curTime + 60;
		
		-- Calculate the day time.
		self:CalculateDayTime();
	end;
end;