--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

ENT.Damage = 8;
ENT.AnimScale = 3;
ENT.ClawSounds = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"};
ENT.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"};
ENT.DeathSounds = {"runner/death1.wav", "runner/death2.wav"};
ENT.TauntSounds = {"runner/alert1.wav", "runner/alert2.wav"};
ENT.AttackSounds = {"runner/attack.wav", "runner/attack2.wav"};

-- Called when the entity is spawned.
function ENT:SpawnFunction(player, trace)
	if (!trace.Hit) then return; end;
	
	local spawnPos = trace.HitPos + trace.HitNormal * 20;
	local entity = ents.Create("aura_zombie");
	
	entity:SelectRandomModel();
	entity:SetPos(spawnPos)
	entity:Spawn();
	entity:Activate();
	
	return entity;
end;

-- A function to select a random model.
function ENT:SelectRandomModel()
	self:SetModel("models/zed/malezed_0"..table.Random( {4, 6, 8} )..".mdl");
end;

-- Called when the schedule should be selected.
function ENT:SelectSchedule()
	local zombieSchedule = ai_schedule.New("ZombieSchedule");
	local curTime = CurTime();
	
	if (!self.NextFindEnemy or curTime >= self.NextFindEnemy) then
		zombieSchedule:AddTask("FindEnemy");
		
		if ( !IsValid( self:GetLastEnemy() ) ) then
			self.NextFindEnemy = curTime + 1;
		else
			self.NextFindEnemy = curTime + 4;
		end;
	end;
	
	local position = self:GetPos();
	local enemy = self:GetLastEnemy();
	
	if ( !IsValid(enemy) or ( enemy:IsPlayer() and !enemy:Alive() ) ) then
		if (!self.NextFindRandom or curTime >= self.NextFindRandom) then
			zombieSchedule:EngTask("TASK_GET_PATH_TO_RANDOM_NODE", 512);
			
			self.NextFindRandom = curTime + 3;
		end;
		
		zombieSchedule:EngTask("TASK_WALK_PATH", 0);
		
		self:SetLastEnemy(NULL);
		self:SetEnemy(NULL);
	else
		local enemyPosition = enemy:GetPos();
		local hitPosition = position + Vector(0, 0, 64);
		local hasSwung = nil;
		
		zombieSchedule:EngTask("TASK_GET_PATH_TO_ENEMY", 0);
		zombieSchedule:EngTask("TASK_RUN_PATH", 0);
		
		self:UpdateEnemyMemory(enemy, enemyPosition);
		
		if (!self.NextRageProps or curTime >= self.NextRageProps) then
			for k, v in ipairs( ents.FindInSphere(position, 64) ) do
				if ( openAura.entity:IsPhysicsEntity(v) ) then
					local blockingPosition = v:GetPos();
					local physicsObject = v:GetPhysicsObject();
					local nearestPoint = v:NearestPoint(hitPosition);
					
					if (nearestPoint:Distance(hitPosition) < 64) then
						v:TakeDamageInfo( openAura:FakeDamageInfo(4, self, self, v:NearestPoint(hitPosition), DMG_CLUB, 8) );
						
						if ( IsValid(physicsObject) ) then
							physicsObject:ApplyForceCenter( (blockingPosition - position):Normalize() * 4096 );
						end;
						
						hasSwung = true;
					end;
				end;
			end;
			
			self.NextRageProps = curTime + 2;
		end;
		
		if (!self.NextSwingPlayer or curTime >= self.NextSwingPlayer) then
			if ( position:Distance(enemyPosition) <= 64 and enemy:IsPlayer() ) then
				local target = enemy:GetRagdollEntity() or enemy;
				
				if ( IsValid(target) ) then
					local nearestPoint = target:NearestPoint(hitPosition);
					local trace = util.TraceLine( {
						endpos = nearestPoint;
						filter = self,
						start = hitPosition
					} );
					
					if (trace.Entity == target or !trace.Hit) then
						enemy:TakeDamageInfo( openAura:FakeDamageInfo(self.Damage, self, self, nearestPoint, DMG_CLUB, 2) );
						
						self:VoiceSound( table.Random(self.ClawSounds) );
						
						hasSwung = true;
					end;
				end;
			end;
			
			self.NextSwingPlayer = curTime + 1;
		end;
		
		if (hasSwung) then
			local animationTable = { {"swing", 1.5}, {"throw1", 2} };
			local randomNumber = math.random(1, 2);
			local animation = animationTable[randomNumber];
			
			zombieSchedule:EngTask("TASK_FACE_ENEMY", 0);
			zombieSchedule:AddTask( "PlaySequence", { Name = animation[1], Speed = animation[2] } );
			
			self:VoiceSound( table.Random(self.AttackSounds) );
		end;
	end;

	self:StartSchedule(zombieSchedule);
end;