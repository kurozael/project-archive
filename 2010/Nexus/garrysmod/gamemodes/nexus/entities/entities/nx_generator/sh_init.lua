--[[
Name: "sh_init.lua".
Product: "nexus".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Model = "models/props_combine/combine_mine01.mdl";
ENT.Author = "kuropixel";
ENT.PrintName = "Generator";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	nexus.entity.RegisterSharedVars( self, {
		{"sh_Power", NWTYPE_NUMBER}
	} );
end;

-- A function to get the entity's power.
function ENT:GetPower()
	return self:GetSharedVar("sh_Power");
end;