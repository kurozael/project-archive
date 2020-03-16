--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kurozael";
ENT.PrintName = "Explomine";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;
ENT.PhysgunDisabled = true;

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "Building");
	self:DTVar("Int", 0, "Upgrades");
end;

--[[ The functions below handle the upgrade system. --]]

-- A function to get whether the entity is building.
function ENT:IsBuilding()
	return self:GetDTBool("Building");
end;

-- A function to get whether the entity has an upgrade.
function ENT:HasUpgrade(iUpgradeFlag)
	return ((self:GetDTInt("Upgrades") & iUpgradeFlag) != 0);
end;