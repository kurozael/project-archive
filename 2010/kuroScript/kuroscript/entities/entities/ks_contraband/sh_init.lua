--[[
Name: "sh_init.lua".
Product: "kuroScript".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Model = "models/props_combine/combine_mine01.mdl";
ENT.Author = "kuromeku";
ENT.PrintName = "Contraband";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Power", 0, NWTYPE_SHORT, REPL_EVERYONE}
	} );
end;