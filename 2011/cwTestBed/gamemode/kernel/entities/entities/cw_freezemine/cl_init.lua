--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork:IncludePrefixed("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	
	y = Clockwork:DrawInfo("Freezemine", x, y, colorTargetID, alpha);
	
	if (Clockwork.Client:GetPos():Distance(self:GetPos()) <= 80) then
		y = Clockwork:DrawInfo("You can defuse it from here.", x, y, colorWhite, alpha);
	else
		y = Clockwork:DrawInfo("Damaging it would be dangerous", x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	Clockwork.schema:GeneratorEntityDraw(self, Color(0, 0, 255, 5));
	self:DrawModel();
end;