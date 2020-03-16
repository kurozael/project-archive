--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Radio";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Frequency", "", NWTYPE_STRING, REPL_EVERYONE},
		{"ks_Off", false, NWTYPE_BOOL, REPL_EVERYONE}
	} );
end;