--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_bShadowCaster = false;
ENTITY.m_iDrawLayer = LAYER_LIVING;
ENTITY.m_sMaterial = "Matt/Player/Walk/001";

sprites.AddSequence("player_walk_idle", "Matt/Player/Walk/");
sprites.AddSequence("player_walk_pistol", "Matt/Player/Walk/");
sprites.AddSequence("player_walk_rifle", "Matt/Player/Walk/");

ENTITY:AddInput("GiveWeapon");

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments)
	self.m_iNextFireBullet = 0;
	self.m_flashAngleAdd = 0;
	self.m_activeImage = util.GetImage("marker");
	self.m_weapons = {};
	self:SetCollisionType(COLLISION_PHYSICS);
	self:SetFixedRotation(false);
end;

-- Called when the entity is given an input.
function ENTITY:OnInput(inputName, argString)
	if (inputName == "GiveWeapon") then
		self:GiveWeapon(argString);
		self:SelectWeapon(argString);
	end;
	
	self:BaseClass().OnInput(self, inputName, argString);
end;

-- Called when the entity is spawned.
function ENTITY:OnSpawn()
	self.m_flashLight = lighting.AddCone(Color(1, 1, 0.8, 1), 256, self:GetCenter(), 0, 20);
	self.m_flashLight:setBrushOnly(true);
	self.m_light = lighting.AddPoint(Color(0.8, 0.7, 0.8, 1), 80, self:GetCenter());
	self.m_light:attachToEntity(self);
	self.m_light:setBrushOnly(true);
	
	if (not entities.GetPlayer()) then
		self:MakePlayer();
	end;
	
	self:GiveWeapon("Pistol");
end;

-- Called when the entity is removed.
function ENTITY:OnRemove()
	if (self.m_flashLight) then self.m_flashLight:remove(); end;
	if (self.m_light) then self.m_light:remove(); end;
	
	for k, v in pairs(self.m_weapons) do
		if (v:IsValid()) then
			v:Remove();
		end;
	end;
end;

-- A function to get the entity's active weapon.
function ENTITY:GetActiveWeapon()
	if (self.m_activeWeapon and self.m_activeWeapon:IsValid()) then
		return self.m_activeWeapon;
	end;
end;

-- A function to select a weapon for the entity.
function ENTITY:SelectWeapon(className)
	self.m_activeWeapon = self.m_weapons[className];
	
	if (self.m_activeWeapon) then
		self.m_activeWeapon:SetNotDrawn(false);
	end;
end;

-- A function to give a weapon to the entity.
function ENTITY:GiveWeapon(className)
	local weapon = self.m_weapons[className];
	
	if (not weapon or not weapon:IsValid()) then
		weapon = entities.Create(className);
		if (not weapon) then return; end;
		
		weapon:SetOwner(self);
		weapon:SetNotDrawn(true);
		weapon:Spawn();
		
		self.m_weapons[className] = weapon;
		
		local activeWeapon = self:GetActiveWeapon();
		
		if (not activeWeapon) then
			self:SelectWeapon(className);
		end;
	end;
end;

-- A function to get whether the player has a weapon.
function ENTITY:HasWeapon(className)
	return (self.m_weapons[className] and self.m_weapons[className]:IsValid());
end;

-- Called after a collision with another entity is solved.
function ENTITY:OnPostSolveCollision(entity, collisionInfo)
	if (entity:GetTeam() == TEAM_MONSTERS and self:IsAlive()) then
		local curTime = time.CurTime();
		
		if (not self.m_iNextZombieBite or curTime >= self.m_iNextZombieBite) then
			self.m_iNextZombieBite = curTime + 1;
			
			damage.AttackEntity(
				DAMAGE_MELEE, self, entity, entity, collisionInfo.position, 8,
				collisionInfo.normal * entity:GetVelocity():Length()
			);
			
			entity:EmitSound("bites/00"..math.random(1, 6));
		end;
	end;
end;

-- Called when the entity begins contact with another entity.
function ENTITY:OnBeginContact(entity, collisionInfo)
	local className = entity:GetClass();
	
	if (entity:IsWeapon() and not self:HasWeapon(className)
	and not entity:HasOwner()) then
		entity:SetOwner(self);
		entity:SetNotDrawn(true);
			self.m_weapons[className] = entity;
		self:SelectWeapon(className);
	end;
end;

-- Called when the entity has been killed.
function ENTITY:OnKilled(damageInfo)
	if (self:IsPlayer()) then
		local players = entities.GetByClassName("Player");
		
		for k, v in ipairs(players) do
			if (v:IsAlive() and v ~= self) then
				v:MakePlayer();
			end;
		end;
	end;
end;

-- A function to fire the entity's weapon.
function ENTITY:FireWeapon()
	local activeWeapon = self:GetActiveWeapon();
	
	if (activeWeapon) then
		activeWeapon:FirePrimaryAttack();
	end;
end;

-- Called every frame for the entity.
function ENTITY:OnUpdate(deltaTime)
	local activeWeapon = self:GetActiveWeapon();
	local animationID = nil;
	local moveSpeed = 400;
	local bIsAlive = self:IsAlive();
	local impulse = Vec2(0, 0);
	
	if (self:IsPlayer() and bIsAlive) then
		local mousePosWorld = util.ScreenToWorld(util.GetMousePos(), true);
		local angleObject = util.AngleBetweenVectors(self:GetCenter(), mousePosWorld);
		local radians, degrees = angleObject:Radians(), angleObject:Degrees();
		
		if (inputs.IsKeyDown(KEY_SHIFT)) then
			moveSpeed = (moveSpeed * 1.5);
		end;
		
		if (inputs.IsKeyDown(KEY_W)) then
			if (mousePosWorld:Distance(self:GetCenter()) > 32) then
				impulse = impulse + Vec2(math.cos(radians) * moveSpeed, math.sin(radians) * moveSpeed);
			end;
		end;
		
		if (inputs.IsKeyDown(KEY_A)) then
			impulse.x = impulse.x - moveSpeed;
		end;
		
		if (inputs.IsKeyDown(KEY_D)) then
			impulse.x = impulse.x + moveSpeed;
		end;
		
		if (inputs.IsKeyDown(KEY_S)) then
			impulse.y = impulse.y + moveSpeed;
		end;
		
		-- if (impulse.x ~= 0 or impulse.y ~= 0) then
			-- self.m_targetPos = nil;
			-- self.m_targetDist = nil;
		-- end;
		
		--self.m_light:SetColor(Color(0, 0, 1, 0.3));
		self:SetAngle(degrees);
	else
		--self.m_light:SetColor(Color(1, 0, 0, 0.2));
		
		if (bIsAlive) then
			local centerPos = self:GetCenter();
			local zombie, distance = util.GetClosestEntity(self, entities.GetByTeam(TEAM_MONSTERS));
			
			if (zombie and distance < 768) then
				local zombieCenter = zombie:GetCenter();
				local rayData = util.RayCast(centerPos, zombieCenter, self);
				
				if (rayData.hitEntity == zombie) then
					local angleObject = util.AngleBetweenVectors(centerPos, zombieCenter);
					local radians, degrees = angleObject:Radians(), angleObject:Degrees();
					local curTime = time.CurTime();
					
					self:SetAngle(degrees);
					
					if (distance < 80) then
						impulse = impulse + Vec2(
							math.cos(radians) * -(moveSpeed / 2),
							math.sin(radians) * -(moveSpeed / 2)
						);
					end;
					
					if (curTime >= self.m_iNextFireBullet) then
						self.m_iNextFireBullet = curTime + math.RandomFloat(0.2, 0.3);
						self:FireWeapon();
					end;
				end;
			end;
		end;
	end;
	
	local targetPos = self:GetShootPos();
		targetPos:Rotate(self:GetCenter(), self:GetAngle());
	self.m_flashLight:setPosition(targetPos);
	
	if (bIsAlive) then
		self.m_flashLight:setActive(true);
	else
		self.m_flashLight:setActive(false);
	end;
	
	local velLength = self:GetVelocity():Length();
	local turnSpeed = velLength / 10;
	local turnAngle = velLength / 12;
	local angleAdd = 0;
	
	if (self:IsMoving()) then
		angleAdd = math.sin(time.CurTime() * turnSpeed) * turnAngle;
	end;
	
	self.m_flashAngleAdd = math.Approach(self.m_flashAngleAdd, angleAdd, 16 * deltaTime);
	self.m_flashLight:setDirection(self:GetAngle():Degrees() + util.Degrees(self.m_flashAngleAdd):Degrees());
	
	if (self.m_targetPos) then
		local radians = util.AngleBetweenVectors(self:GetCenter(), self.m_targetPos):Radians();
		impulse = impulse + Vec2(math.cos(radians) * moveSpeed, math.sin(radians) * moveSpeed);
		
		if (self:GetCenter():Distance(self.m_targetPos) < 16) then
			timers.Remove(self.m_sUniqueID.."_target");
			
			self.m_targetPos = nil;
			self.m_targetDist = nil;
		end;
	end;
	
	if (impulse.x ~= 0 or impulse.y ~= 0) then
		self:ApplyImpulse(impulse);
		
		if (activeWeapon) then
			local holdType = activeWeapon:GetHoldType();
			
			if (holdType == "rifle") then
				animationID = "player_walk_rifle";
			else
				animationID = "player_walk_pistol";
			end;
		else
			--animationID = "player_walk_idle";
			animationID = "player_walk_pistol";
		end;
	end;
	
	if (animationID) then
		if (moveSpeed > 400) then
			self:Play(animationID, 0.1);
		else
			self:Play(animationID, 0.2);
		end;
	else
		self:Stop();
	end;
	
	self:UpdateSprite(deltaTime);
end;

-- A function to get the entity's attachment position.
function ENTITY:GetAttachmentPos()
	local materialData = self:GetMaterialData();
	local attachmentPos = Vec2(0, 0);
	local position = materialData:GetVector("attachment");
	
	if (position) then
		attachmentPos.x = position.x;
		attachmentPos.y = position.y;
	end;
	
	return attachmentPos;
end;

-- A function to get the entity's shoot position.
function ENTITY:GetShootPos()
	return self:GetPos() + self:GetAttachmentPos();
end;

-- A function to get the entity's target position.
function ENTITY:GetTargetPos()
	return self.m_targetPos;
end;

-- A function to set the entity's target position.
function ENTITY:SetTargetPos(targetPos)
	timers.Add(self.m_sUniqueID.."_target", 5, 1, function()
		self.m_targetPos = nil;
		self.m_targetDist = nil;
	end);
	
	self.m_targetPos = targetPos;
	self.m_targetDist = self:GetCenter():Distance(targetPos);
end;

-- A function to get the entity's target distance.
function ENTITY:GetTargetDist()
	return self.m_targetDist;
end;

-- Called when the entity takes damage.
function ENTITY:OnTakeDamage(damageInfo)
	local damagePos = damageInfo:GetPosition();
	
	if (damageInfo:GetType() == DAMAGE_BULLET) then
		local damageForce = damageInfo:GetForce();
		local decalSize = math.random(32, 48);
		
		decals.Create("Blood", self:GetCenter(), decalSize, decalSize, Color(0.8, 0, 0, math.RandomFloat(0.2, 0.5)), 10);
		util.MakeBloodParticles(damagePos);
		
		if (self:IsAlive()) then
			self:ApplyForce(damageForce, damagePos);
			self:EmitSound("player/grunt");
		end;
	elseif (damageInfo:GetType() == DAMAGE_MELEE) then
		local decalSize = math.random(32, 48);
		
		decals.Create("Blood", self:GetCenter(), decalSize, decalSize, Color(0.8, 0, 0, math.RandomFloat(0.2, 0.5)), 10);
		util.MakeBloodParticles(damagePos);
	end;
end;

-- Called when the entity is drawn.
function ENTITY:OnDraw()
	local targetPos = self.m_targetPos;
	local targetDist = self.m_targetDist;
	local playerCenter = self:GetCenter();
	
	if (targetPos and targetDist) then
		local alpha = (1 / targetDist) * playerCenter:Distance(targetPos);
		
		render.DrawLine(playerCenter.x, playerCenter.y, targetPos.x, targetPos.y, Color(0, 0, 1, alpha));
		render.DrawLine(targetPos.x - 8, targetPos.y - 8, targetPos.x + 8, targetPos.y + 8, Color(0, 0, 1, alpha));
		render.DrawLine(targetPos.x - 8, targetPos.y + 8, targetPos.x + 8, targetPos.y - 8, Color(0, 0, 1, alpha));
	end;
	
	render.DrawImage(
		self.m_activeImage,
		playerCenter.x - 24,
		playerCenter.y - 24,
		48,
		48,
		Color(1, 1, 1, 0.1)
	);
	
	self:DrawShadow();
	self:DrawSprite();
end;
