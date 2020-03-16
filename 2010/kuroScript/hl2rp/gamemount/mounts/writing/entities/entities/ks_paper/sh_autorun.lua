--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Paper";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Note", false, NWTYPE_BOOL, REPL_EVERYONE}
	} );
end;