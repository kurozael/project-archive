--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(50);
	self:SetSolid(SOLID_VPHYSICS);
	
	local physicsObject = self:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- A function to set the data of the entity.
function ENT:SetData(inventory, cash)
	self:SetModel("models/weapons/w_suitcase_passenger.mdl");
	
	self.cash = cash;
	self.inventory = inventory;
end;

-- A function to explode the entity.
function ENT:Explode(scale)
	local effectData = EffectData();
	
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(scale or 8);
	
	util.Effect("GlassImpact", effectData);

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;

-- Called when the entity is removed.
function ENT:OnRemove()
	if ( !openAura:IsShuttingDown() ) then
		-- local i;
		
		if (self.inventory) then
			for k, v in pairs(self.inventory) do
				if (v > 0) then
					for i = 1, v do
						local item = openAura.entity:CreateItem( nil, k, self:GetPos() + Vector( 0, 0, math.random(1, 48) ), self:GetAngles() );
						
						if ( IsValid(item) ) then
							openAura.entity:CopyOwner(self, item);
						end;
					end;
				end;
			end;
		end;
		
		if (self.cash and self.cash > 0) then
			openAura.entity:CreateCash( nil, self.cash, self:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
		end;
		
		self.inventory = nil;
		self.cash = nil;
	end;
end;