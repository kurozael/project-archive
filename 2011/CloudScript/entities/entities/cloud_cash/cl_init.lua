--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = CloudScript.option:GetColor("target_id");
	local colorWhite = CloudScript.option:GetColor("white");
	local amount = self:GetDTInt("amount");
	local owner = CloudScript.entity:GetOwner(self);
	
	y = CloudScript:DrawInfo(CloudScript.option:GetKey("name_cash"), x, y, colorTargetID, alpha);
	y = CloudScript:DrawInfo(FORMAT_CASH(amount), x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (CloudScript.plugin:Call("CloudScriptCashEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;