--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called just after the opaque renderables have been drawn.
function PLUGIN:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (drawingSkybox or drawingDepth) then
		return;
	end;
	
	local eyeAngles = EyeAngles();
	local curTime = UnPredictedCurTime();
	local eyePos = EyePos();
	
	cam.Start3D(eyePos, eyeAngles);
		for k, v in pairs(self.dynamicAdverts) do
			if ( !IsValid(v.panel) ) then
				if ( openAura.player:CanSeePosition(openAura.Client, v.position, nil, true) ) then
					self:CreateHTMLPanel(v);
				end;
			else
				v.panel:SetPaintedManually(false);
					cam.Start3D2D(v.position, v.angles, v.scale or 0.25);
						v.panel:PaintManual();
					cam.End3D2D();
				v.panel:SetPaintedManually(true);
			end;
		end;
	cam.End3D();
end;