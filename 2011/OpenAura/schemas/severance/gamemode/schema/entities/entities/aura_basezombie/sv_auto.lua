--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity is spawned.
function ENT:SpawnFunction(player, trace)
	if (!trace.Hit) then return; end;
	
	local spawnPos = trace.HitPos + trace.HitNormal * 20;
	local entity = ents.Create("aura_basezombie");
	
	entity:SetModel("models/zombie/classic.mdl");
	entity:SetPos(spawnPos)
	entity:Spawn();
	entity:Activate();
	
	return entity;
end;

-- Called when the entity has initialized.
function ENT:Initialize()
	self:SetHullType(HULL_HUMAN);
	self:SetHullSizeNormal();
	
	self:SetSolid(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_STEP);
	
	self:CapabilitiesAdd(CAP_MOVE_GROUND | CAP_ANIMATEDFACE | CAP_TURN_HEAD | CAP_USE_SHOT_REGULATOR | CAP_AIM_GUN);
	
	self:SetMaxYawSpeed(5000);
	self:SetHealth( math.random(20, 40) );
end;

-- A function to emit a voice sound.
function ENT:VoiceSound(sound, volume)
	WorldSound( sound, self:GetPos(), volume or 75, math.random(75, 100) );
end;

-- Called when the entity's death should be done.
function ENT:DoDeath()
	if (!self.IsDead) then
		self.IsDead = true;
		self:VoiceSound( table.Random(self.DeathSounds) );
		self.DamageForce = openAura:ConvertForce(self.DamageForce * 192);
		
		local ragdoll = openAura.entity:MakeIntoRagdoll( self, nil, (self:GetVelocity() * 1.5) + self.DamageForce, self:GetAngles() - Angle(0, -45, 0) );
		
		if ( IsValid(ragdoll) ) then
			ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);
			
			openAura.entity:Decay(ragdoll, 120);
			
			self:Remove();
		end;
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	local damagePosition = damageInfo:GetDamagePosition();
	local damageAmount = damageInfo:GetDamage();
	local damageForce = damageInfo:GetDamageForce();
	
	self:SetHealth( math.max(self:Health() - damageAmount, 1) );
	
	if (self:Health() > 1) then
		self:VoiceSound( table.Random(self.PainSounds) );
	else
		self.DamageForce = damageForce;
	end;
	
	openAura:CreateBloodEffects(damagePosition, 1, self, damageForce);
end;

-- Called each frame.
function ENT:Think()
	local curTime = CurTime();
	
	if (!self.NextDropToFloor) then
		self.NextDropToFloor = curTime + 1;
	else
		self:DropToFloor();
		self.NextDropToFloor = nil;
	end;
	
	if (!self.NextTauntTime) then
		self.NextTauntTime = curTime + math.random(16, 32);
	elseif (curTime >= self.NextTauntTime) then
		self:VoiceSound( table.Random(self.TauntSounds) );
		self.NextTauntTime = nil;
	end;
	
	if ( self.DamageForce and IsValid(self) ) then
		self:DoDeath();
	end;
	
	if (!self.NextRunSound) then
		self.NextRunSound = curTime + math.random(0.1, 0.2);
		
		if (!self.NextRunFoot or self.NextRunFoot == 0) then
			self.NextRunFoot = 1;
		else
			self.NextRunFoot = 0;
		end;
	elseif (curTime >= self.NextRunSound) then
		if ( self:GetSequence() == self:LookupSequence("run_all") and self:IsOnGround() ) then
			if (self.NextRunFoot == 0) then
				local randomSounds = {1, 3, 5};
				local randomNumber = math.random(1, 3);
				
				self:VoiceSound( "npc/metropolice/gear"..randomSounds[randomNumber]..".wav", math.random(50, 75) );
			else
				local randomSounds = {2, 4, 6};
				local randomNumber = math.random(1, 3);
				
				self:VoiceSound( "npc/metropolice/gear"..randomSounds[randomNumber]..".wav", math.random(50, 75) );
			end;
			
			self.NextRunSound = nil;
		end;
	end;
end;

-- Called when a sequence should be played.
function ENT:TaskStart_PlaySequence(data)
	local sequenceID = data.ID;
	local curTime = CurTime();

	if (data.Name) then
		sequenceID = self:LookupSequence(data.Name);
	end;

	self:ResetSequence(sequenceID);
	self:SetNPCState(NPC_STATE_SCRIPT);
	
	local duration = self:SequenceDuration();

	if (data.Speed and data.Speed > 0) then 
		self:SetPlaybackRate(data.Speed);
		
		duration = duration / data.Speed;
	end;
	
	self.TaskSequenceEnd = curTime + duration;
end;

-- A function to set the last enemy.
function ENT:SetLastEnemy(enemy)
	self.LastEnemy = enemy;
end;

-- A function to get the last enemy.
function ENT:GetLastEnemy()
	return self.LastEnemy;
end;

-- Called when an enemy is needed.
function ENT:TaskStart_FindEnemy(data)
	local position = self:GetPos();
	local closest = nil;
	
	for k, v in ipairs( _player.GetAll() ) do
		local playerPosition = v:GetPos();
		local distance = playerPosition:Distance(position);
		
		if (v:Alive() and ( self:Visible(v) or v:Visible(self) )
		and v:GetMoveType() != MOVETYPE_NOCLIP) then
			if ( !closest or distance < closest[2] ) then
				closest = {v, distance};
			end;
		end;
	end;
	
	for k, v in ipairs( ents.FindInSphere(position, 1024) ) do
		if ( v:GetClass() == "aura_flare" and ( self:Visible(v) or v:Visible(self) ) ) then
			local flarePosition = v:GetPos();
			local distance = flarePosition:Distance(position);
			
			if ( !closest or distance < closest[2] or closest[1]:IsPlayer() ) then
				closest = {v, distance};
			end;
		end;
	end;
	
	if (closest) then
		self:SetEnemy( closest[1] );
		self:SetLastEnemy( closest[1] );
		self:UpdateEnemyMemory( closest[1], closest[1]:GetPos() );
	else
		self:SetEnemy(NULL);
		self:SetLastEnemy(NULL);
	end;
	
	self:TaskComplete();
end;

-- Called when a sequence is playing.
function ENT:Task_PlaySequence(data)
	local curTime = CurTime();
	
	if (curTime < self.TaskSequenceEnd) then
		return;
	end;
	
	self:TaskComplete();
	self:SetNPCState(NPC_STATE_NONE);
	self.TaskSequenceEnd = nil;
end;