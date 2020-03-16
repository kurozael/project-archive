--[[
Name: "cl_init.lua".
Product: "nexus".
--]]

include("sh_init.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = nexus.schema.GetColor("target_id");
	local colorWhite = nexus.schema.GetColor("white");
	local index = self:GetSharedVar("sh_Index");
	
	if (index != 0) then
		local itemTable = nexus.item.Get(index);
		
		if (itemTable) then
			local owner = nexus.entity.GetOwner(self);
			
			y = NEXUS:DrawInfo("Shipment", x, y, colorTargetID, alpha);
			y = NEXUS:DrawInfo(itemTable.name, x, y, colorWhite, alpha);
		end;
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;