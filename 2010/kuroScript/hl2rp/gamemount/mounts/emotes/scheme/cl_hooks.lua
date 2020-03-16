--[[
Name: "cl_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when the calc view table should be adjusted.
function MOUNT:CalcViewAdjustTable(view)
	if ( g_LocalPlayer:GetSharedVar("ks_Stance") ) then
		local angles = g_LocalPlayer:GetAngles():Forward();
		local eyes = g_LocalPlayer:GetAttachment( g_LocalPlayer:LookupAttachment("eyes") );
		
		-- Check if a statement is true.
		if (eyes) then
			local position = eyes.Pos + Vector(0, 0, 4);
			local traceLine = util.TraceLine( {
				start = position,
				endpos = position + (angles * 16);
				filter = g_LocalPlayer
			} );
			
			-- Check if a statement is true.
			if (traceLine.Hit) then
				view.origin = traceLine.HitPos - (angles * 4);
			else
				view.origin = traceLine.HitPos;
			end;
		end;
	end;
end;