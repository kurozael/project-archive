--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork:IncludePrefixed("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local guarding = 0;
	local position = self:GetPos();
	
	y = Clockwork:DrawInfo("Door Guarder", x, y, colorTargetID, alpha);
	
	for k, v in ipairs(ents.FindByClass("prop_door_rotating")) do
		if (v:GetPos():Distance(position) <= 256) then
			guarding = guarding + 1;
		end;
	end;
	
	y = Clockwork:DrawInfo("This is guarding "..guarding.." door(s).", x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	Clockwork.schema:GeneratorEntityDraw(self);
	self:DrawModel();
end;