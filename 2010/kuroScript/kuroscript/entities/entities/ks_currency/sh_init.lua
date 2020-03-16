--[[
Name: "sh_init.lua".
Product: "kuroScript".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Currency";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Amount", 0, NWTYPE_SHORT, REPL_EVERYONE}
	} );
end;