--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	
	y = openAura:DrawInfo("Paper", x, y, colorTargetID, alpha);
	
	if ( self:GetDTBool("note") ) then
		y = openAura:DrawInfo("It has been written on.", x, y, colorWhite, alpha);
	else
		y = openAura:DrawInfo("It is blank.", x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;