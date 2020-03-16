--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	
	y = openAura:DrawInfo("Breach", x, y, colorTargetID, alpha);
	y = openAura:DrawInfo("It can be directly charged.", x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw() self:DrawModel(); end;