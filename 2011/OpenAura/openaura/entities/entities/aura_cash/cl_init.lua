--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	local amount = self:GetDTInt("amount");
	local owner = openAura.entity:GetOwner(self);
	
	y = openAura:DrawInfo(openAura.option:GetKey("name_cash"), x, y, colorTargetID, alpha);
	y = openAura:DrawInfo(FORMAT_CASH(amount), x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (openAura.plugin:Call("OpenAuraCashEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;