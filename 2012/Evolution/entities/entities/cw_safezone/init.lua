--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_trainstation/tracksign03.mdl");
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	
	local physicsObject = self:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	
	self.cwBaseEntity = ents.Create("prop_physics");
	self.cwBaseEntity:SetMaterial("phoenix_storms/metalset_1-2");
	self.cwBaseEntity:SetModel("models/hunter/misc/cone1x05.mdl");
	self.cwBaseEntity:SetParent(self);
	self.cwBaseEntity:SetLocalPos(
		Vector(0, 0, -76)
	);
	self.cwBaseEntity:Spawn();
	
	--[[ Disable the shadow for the base entity. --]]
	self.cwBaseEntity:DrawShadow(false);
	self:DrawShadow(false);
	
	--[[ Make the base entity safe from idiots! --]]
	Clockwork.entity:MakeSafe(
		self.cwBaseEntity, true, true, true
	);
end;

-- Called every frame.
function ENT:Think()
	local playerList = player.GetAll();
	local entities = ents.FindInBox(
		self:GetMinimumBoxBounds(),
		self:GetMaximumBoxBounds()
	);
	
	for k, v in ipairs(playerList) do
		v.cwLastSafeZone = v.cwIsInSafeZone;
		v.cwIsInSafeZone = nil;
	end;
	
	for k2, v2 in ipairs(entities) do
		if (v2:IsPlayer() and v2:HasInitialized()) then
			if (!v2.cwIsInSafeZone
			and v2.cwLastSafeZone != v) then
				Schema:PlayerEnterSafeZone(v2, v);
			end;
			
			v2.cwIsInSafeZone = v;
		elseif (v2.cwNoSafeZone
		and !v2.cwDissolved) then
			Clockwork.entity:Dissolve(
				v2, DISSOLVE_ENERGY, 4
			);
			
			v2.cwDissolved = true;
		end;
	end;
	
	for k, v in ipairs(playerList) do
		if (v:HasInitialized() and IsValid(v.cwLastSafeZone)
		and !IsValid(v.cwIsInSafeZone)) then
			Schema:PlayerLeaveSafeZone(v, v.cwLastSafeZone);
			v.cwLastSafeZone = nil;
		end;
	end;
	
	self:NextThink(CurTime() + 2);
end;

-- Called when the entity has been removed.
function ENT:OnRemove()
	if (IsValid(self.cwBaseEntity)) then
		self.cwBaseEntity:Remove();
	end;
end;

-- A function to set the size of the Safe Zone.
function ENT:SetSize(size)
	self:SetDTInt("Size", size);
end;

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false;
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;