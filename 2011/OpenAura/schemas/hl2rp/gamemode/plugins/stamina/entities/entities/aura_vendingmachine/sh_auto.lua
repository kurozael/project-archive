--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kurozael";
ENT.PrintName = "Vending Machine";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;
ENT.PhysgunDisabled = true;

-- A function to get the entity's stock.
function ENT:GetStock()
	return self:GetDTInt("stock");
end;

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "stock");
	self:DTVar("Bool", 0, "action");
	self:DTVar("Float", 0, "flash");
end;