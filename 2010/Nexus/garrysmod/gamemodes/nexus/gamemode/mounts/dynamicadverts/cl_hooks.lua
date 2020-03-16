--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called just after the opaque renderables have been drawn.
function MOUNT:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (drawingSkybox) then
		return;
	end;
	
	local eyeAngles = EyeAngles();
	local curTime = UnPredictedCurTime();
	local eyePos = EyePos();
	
	cam.Start3D(eyePos, eyeAngles);
		for k, v in pairs(self.dynamicAdverts) do
			v.panel:SetPaintedManually(false);
				cam.Start3D2D(v.position, v.angles, v.scale or 0.25);
					v.panel:PaintManual();
				cam.End3D2D();
			v.panel:SetPaintedManually(true);
		end;
	cam.End3D();
end;