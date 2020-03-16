--[[
Name: "sh_init.lua".
Product: "kuroScript".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Shipment";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Index", 0, NWTYPE_NUMBER, REPL_EVERYONE}
	} );
end;