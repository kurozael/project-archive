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
	
	local colorWhite = nexus.schema.GetColor("white");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	local font = nexus.schema.GetFont("large_3d_2d");
	
	NEXUS:OverrideMainFont(font);
		cam.Start3D(eyePos, eyeAngles);
			for k, v in pairs(self.surfaceTexts) do
				local alpha = math.Clamp(NEXUS:CalculateAlphaFromDistance(512, eyePos, v.position) * 1.5, 0, 255);
				
				if (alpha > 0) then
					local text = NEXUS:ExplodeString("|", v.text);
					local y = 0;
					
					cam.Start3D2D(v.position, v.angles, (v.scale or 0.25) * 0.2);
						for k2, v2 in ipairs(text) do
							y = NEXUS:DrawInfo(v2, 0, y, colorWhite, alpha, nil, function(x, y, width, height)
								return x, y - (height / 2);
							end, 3);
						end;
					cam.End3D2D();
				end;
			end;
		cam.End3D();
	NEXUS:OverrideMainFont(false);
end;