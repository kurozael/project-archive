--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Combine Lock";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;
ENT.PhysgunDisabled = true;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_SmokeCharge", 0, NWTYPE_NUMBER, REPL_EVERYONE},
		{"ks_Locked", false, NWTYPE_BOOL, REPL_EVERYONE},
		{"ks_Flash", 0, NWTYPE_NUMBER, REPL_EVERYONE}
	} );
end;