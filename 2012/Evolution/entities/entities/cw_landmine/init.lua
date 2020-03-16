--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl");
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(200);
	self:SetSolid(SOLID_VPHYSICS);
	
	local physicsObject = self:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	
	Schema:SetNoSafeZone(self);
end;

-- Called when the entity touches another entity.
function ENT:Touch(entity)
	if (entity:IsPlayer() and entity != self:GetPlayer()
	and !self:IsBuilding()) then
		local owner = self:GetPlayer();
		local attacker = owner;
		
		if (!IsValid(owner)) then
			attacker = self;
		end;
		
		self:EmitSound("buttons/button16.wav");
		
		timer.Simple(1, function()
			if (!IsValid(self) or !IsValid(attacker)) then
				return;
			end;
			
			if (self:HasUpgrade(MINE_FIRE)) then
				entity:Ignite(10, 0);
			end;
			
			if (self:HasUpgrade(MINE_ICE)) then
				Clockwork.player:SetRagdollState(entity, RAGDOLL_FALLENOVER, 10);
				
				local ragdollEntity = entity:GetRagdollEntity();
				
				if (IsValid(ragdollEntity)) then
					Clockwork.entity:StatueRagdoll(ragdollEntity);
				end;
			end;
			
			self:Explode();
			self:Remove();
		end);
	end;
end;

-- Called each frame.
function ENT:Think()
	if (!self:IsInWorld()) then
		self:Remove();
	end;
end;

-- A function to defuse the entity.
function ENT:Defuse()
	local effectData = EffectData();
		effectData:SetStart(self:GetPos());
		effectData:SetOrigin(self:GetPos());
		effectData:SetScale(8);
	util.Effect("GlassImpact", effectData, true, true);
	
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- A function to explode the entity.
function ENT:Explode(scale, bNoDamage)
	local owner = self:GetPlayer();
	local entities = ents.FindInSphere(self:GetPos(), 128);
	local attacker = owner;
	
	if (!IsValid(owner)) then
		attacker = self;
	end;
	
	local effectData = EffectData();
		effectData:SetStart(self:GetPos());
		effectData:SetOrigin(self:GetPos());
		effectData:SetScale(scale or 8);
	util.Effect("Explosion", effectData);
	
	if (bNoDamage) then return; end;
	
	for k, v in ipairs(entities) do
		if (v:IsPlayer()) then
			v:TakeDamageInfo(
				Clockwork:FakeDamageInfo(
					50, self, attacker, self:GetPos(), DMG_BLAST, 2
				)
			);
		end;
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0));
	
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;

--[[ The functions below handle the upgrade system. --]]

-- A function to start building the entity.
function ENT:StartBuilding(player)
	local buildTime = Schema:GetDexterityTime(player) * 1.5;
		Clockwork.player:SetAction(player, "build", buildTime);
	self:SetDTBool("Building", true);
	
	local effectData = EffectData();
		effectData:SetEntity(self);
		effectData:SetScale(buildTime);
	util.Effect("cw_wirespawn", effectData);
	
	timer.Simple(buildTime, function()
		if (IsValid(self)) then
			self:SetDTBool("Building", false);
		end;
	end);
	
	Clockwork.player:ConditionTimer(player, buildTime * 0.9, function()
		return (player:Alive() and !player:IsRagdolled() and !player:GetSharedVar("IsTied")
		and IsValid(self) and player:GetPos():Distance(self:GetPos()) <= 196);
	end, function(success)
		Clockwork.player:SetAction(player, "build", false);
		self:SetDTBool("Building", false);
		
		if (success) then
			local physicsObject = self:GetPhysicsObject();
			local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
			player:EmitSound(useSounds[math.random(1, #useSounds)]);
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		else
			self:Defuse();
			self:Remove();
		end;
	end);
	
	local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
	player:EmitSound(useSounds[math.random(1, #useSounds)]);
end;

-- A function to give an upgrade to the entity.
function ENT:GiveUpgrade(iUpgradeFlag)
	if (!self:HasUpgrade(iUpgradeFlag)) then
		self:SetDTInt("Upgrades", self:GetDTInt("Upgrades") + iUpgradeFlag);
	end;
end;

-- A function to take an upgrade from the entity.
function ENT:TakeUpgrade(iUpgradeFlag)
	if (self:HasUpgrade(iUpgradeFlag)) then
		self:SetDTInt("Upgrades", self:GetDTInt("Upgrades") - iUpgradeFlag);
	end;
end;