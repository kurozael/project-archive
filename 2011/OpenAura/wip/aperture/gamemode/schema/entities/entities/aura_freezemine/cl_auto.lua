--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	
	y = openAura:DrawInfo("Freezemine", x, y, colorTargetID, alpha);
	
	if (openAura.Client:GetPos():Distance( self:GetPos() ) <= 80) then
		y = openAura:DrawInfo("You can defuse it from here.", x, y, colorWhite, alpha);
	else
		y = openAura:DrawInfo("Damaging it would be dangerous", x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	openAura.schema:OpenAuraGeneratorEntityDraw( self, Color(0, 0, 255, 5) );
	self:DrawModel();
end;