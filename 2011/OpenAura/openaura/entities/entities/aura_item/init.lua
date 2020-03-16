--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self.data = {};
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(25);
	self:SetSolid(SOLID_VPHYSICS);
	
	local physicsObject = self:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called each frame.
function ENT:Think()
	self:NextThink(CurTime() + 1);
	
	if ( !self:IsInWorld() ) then
		self:Remove();
	end;
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- A function to set the item of the entity.
function ENT:SetItem(item)
	local itemTable = openAura.item:Get(item);
	
	if (itemTable) then
		self:SetModel(itemTable.model);
		self:SetDTInt("index", itemTable.index);
		
		if (itemTable.skin) then
			self:SetSkin(itemTable.skin);
		end;
		
		if (itemTable.OnCreated) then
			itemTable:OnCreated(self);
		end;
		
		self.itemTable = itemTable;
	end;
end;

-- Called when the entity is removed.
function ENT:OnRemove()
	local itemTable = self.itemTable;
	
	if (itemTable) then
		if (itemTable.OnEntityRemoved) then
			itemTable:OnEntityRemoved(self);
		end;
	end;
end;

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(8);
	
	util.Effect("GlassImpact", effectData);

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	local itemTable = self.itemTable;
	
	if (itemTable and itemTable.OnEntityTakeDamage) then
		if (itemTable:OnEntityTakeDamage(self, damageInfo) == false) then
			return;
		end;
	end;
	
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	if (self:Health() <= 0) then
		self:Explode();
		self:Remove();
	end;
end;

-- Called each frame.
function ENT:Think()
	local itemTable = self.itemTable;
	
	if (itemTable and itemTable.OnEntityThink) then
		local nextThink = itemTable:OnEntityThink(self);
		
		if (type(nextThink) == "number") then
			self:NextThink(CurTime() + nextThink);
		end;
	end;
end;