--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.Author = "kurozael";
ENT.PrintName = "Salesman";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity is removed.
function ENT:OnRemove()
	if ( SERVER and IsValid(self.ChatBubble) ) then
		self.ChatBubble:Remove();
	end;
end;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	openAura.entity:RegisterSharedVars( self, {
		{"name", NWTYPE_STRING},
		{"physDesc", NWTYPE_STRING}
	} );
end;