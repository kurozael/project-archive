--[[
Name: "sh_init.lua".
Product: "nexus".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuropixel";
ENT.PrintName = "Cash";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	nexus.entity.RegisterSharedVars( self, {
		{"sh_Amount", NWTYPE_NUMBER}
	} );
end;