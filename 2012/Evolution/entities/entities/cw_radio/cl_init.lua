--[[
	� 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

--[[ The material used to display whether it is on. --]]
local GLOW_MATERIAL = Material("sprites/glow04_noz");

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local frequency = self:GetNetworkedString("Frequency");
	
	y = Clockwork:DrawInfo("Radio", x, y, colorTargetID, alpha);
	
	if (frequency == "") then
		y = Clockwork:DrawInfo("This radio has no frequency set.", x, y, colorWhite, alpha);
	else
		y = Clockwork:DrawInfo(frequency, x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	local r, g, b, a = self:GetColor();
	local glowColor = Color(0, 255, 0, a);
	local position = self:GetPos();
	local forward = self:GetForward() * 9;
	local right = self:GetRight() * 5;
	local up = self:GetUp() * 8;
	
	if (self:IsOff()) then
		glowColor = Color(255, 0, 0, a);
	end;
	
	cam.Start3D(EyePos(), EyeAngles());
		render.SetMaterial(GLOW_MATERIAL);
		render.DrawSprite(position + forward + right + up, 16, 16, glowColor);
	cam.End3D();
end;