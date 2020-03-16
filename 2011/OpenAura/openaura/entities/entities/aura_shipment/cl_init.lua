--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	local index = self:GetDTInt("index");
	
	if (index != 0) then
		local itemTable = openAura.item:Get(index);
		
		if (itemTable) then
			local owner = openAura.entity:GetOwner(self);
			
			y = openAura:DrawInfo("Shipment", x, y, colorTargetID, alpha);
			y = openAura:DrawInfo(itemTable.name, x, y, colorWhite, alpha);
		end;
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (openAura.plugin:Call("OpenAuraShipmentEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;