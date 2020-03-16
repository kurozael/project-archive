--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local guarding = 0;
	local entities = {};
	local position = self:GetPos();
	
	y = Clockwork:DrawInfo("Cash Guarder", x, y, colorTargetID, alpha);
	
	for k, v in pairs(Clockwork.generator:GetAll()) do
		table.Add(entities, ents.FindByClass(k));
	end;
	
	for k, v in ipairs(entities) do
		if (v:GetPos():Distance(position) <= 512) then
			guarding = guarding + 1;
		end;
	end;
	
	y = Clockwork:DrawInfo("This is guarding "..guarding.." generator(s).", x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	Schema:GeneratorEntityDraw(self);
	self:DrawModel();
end;