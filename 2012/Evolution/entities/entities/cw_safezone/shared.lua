--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kurozael";
ENT.PrintName = "Safe Zone";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.PhysgunDisabled = true;

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Size");
end;

-- A function to get the minimum box bounds.
function ENT:GetMinimumBoxBounds()
	return (self:GetPos() - Vector(0, 0, 80)) - Vector(self.dt.Size, self.dt.Size, 0);
end;

-- A function to get the maximum box bounds.
function ENT:GetMaximumBoxBounds()
	return (self:GetPos() - Vector(0, 0, 80)) + Vector(self.dt.Size, self.dt.Size, self.dt.Size * 0.5);
end;