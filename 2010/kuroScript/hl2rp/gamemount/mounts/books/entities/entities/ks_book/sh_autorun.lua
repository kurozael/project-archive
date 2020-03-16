--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Book";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Index", 0, NWTYPE_NUMBER, REPL_EVERYONE},
	} );
end;