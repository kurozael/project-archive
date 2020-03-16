--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	local guarding = 0;
	local entities = {};
	local position = self:GetPos();
	
	y = openAura:DrawInfo("Ration Guarder", x, y, colorTargetID, alpha);
	
	for k, v in pairs( openAura.generator:GetAll() ) do
		table.Add( entities, ents.FindByClass(k) );
	end;
	
	for k, v in ipairs(entities) do
		if (v:GetPos():Distance(position) <= 512) then
			guarding = guarding + 1;
		end;
	end;
	
	y = openAura:DrawInfo("This is guarding "..guarding.." generator(s).", x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	openAura.schema:OpenAuraGeneratorEntityDraw(self);
	self:DrawModel();
end;