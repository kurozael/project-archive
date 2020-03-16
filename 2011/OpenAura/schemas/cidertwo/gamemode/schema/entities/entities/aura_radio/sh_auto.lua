--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kurozael";
ENT.PrintName = "Radio";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	openAura.entity:RegisterSharedVars( self, {
		{"frequency", NWTYPE_STRING},
		{"off", NWTYPE_BOOL}
	} );
end;

-- A function to get whether the entity is off.
function ENT:IsOff()
	return self:GetSharedVar("off");
end;