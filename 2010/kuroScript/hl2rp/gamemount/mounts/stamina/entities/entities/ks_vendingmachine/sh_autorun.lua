--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kuromeku";
ENT.PrintName = "Vending Machine";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;
ENT.PhysgunDisabled = true;

-- A function to get the entity's stock.
function ENT:GetStock()
	return self:GetSharedVar("ks_Stock");
end;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	RegisterNWTable( self, {
		{"ks_Action", false, NWTYPE_BOOL, REPL_EVERYONE},
		{"ks_Stock", 0, NWTYPE_SHORT, REPL_EVERYONE},
		{"ks_Flash", 0, NWTYPE_NUMBER, REPL_EVERYONE}
	} );
end;