--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_iDrawLayer = LAYER_LIVING;
ENTITY.m_iMoveSpeed = 250;
ENTITY.m_iAnimSpeed = 0.2;
ENTITY.m_sMaterial = "sprites/npcs/zombie/idle";
ENTITY.m_sWalkAnim = "zombie_walk";
ENTITY.m_iHealth = 50;

sprites.AddSequence("zombie_walk", "sprites/npcs/zombie/walk/");

-- A function to get alive entities only.
local GET_ALIVE_ONLY = function(entity)
	return entity:IsAlive();
end;

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments)
	self:SetCollisionType(COLLISION_PHYSICS);
	self:SetTeam(TEAM_MONSTERS);
end;

-- A function to queue a target pos.
function ENTITY:QueueTargetPos(position)
	if (not self.m_targetQueue) then
		self.m_targetQueue = {};
	end;
	
	table.insert(self.m_targetQueue, position);
end;

-- Called every frame for the entity.
function ENTITY:OnUpdate(deltaTime)
	local centerPos = self:GetCenter();
	local player = util.GetClosestEntity(self, "Player", GET_ALIVE_ONLY);
	
	if (player and player:GetCenter():Distance(self:GetPos()) < 128
	and util.RayCast(centerPos, player:GetCenter(), self).hitEntity == player) then
		self.m_targetPos = player:GetCenter();
		self.m_iNextChangeTarget = time.CurTime() + 4;
	elseif (self.m_targetPos == nil) then
		while (true) do
			self.m_targetPos = centerPos + Vec2(
				math.RandomFloat(-32, 32), math.RandomFloat(-32, 32)
			);
			self.m_iNextChangeTarget = time.CurTime() + 2;
			
			local rayData = util.RayCast(
				centerPos, self.m_targetPos, self
			);
			
			if (not rayData.didHit) then
				break;
			end;
		end;
	end;
	
	if (self.m_iNextChangeTarget
	and time.CurTime() > self.m_iNextChangeTarget) then
		self.m_iNextChangeTarget = nil;
		self.m_targetPos = nil;
	end;
	
	local impulse = Vec2(0, 0);
	local moveSpeed = self.m_iMoveSpeed * 0.4;
	local animSpeed = self.m_iAnimSpeed * 2;
	
	if (not self.m_iNextChangeTarget) then
		moveSpeed = self.m_iMoveSpeed;
		animSpeed = self.m_iAnimSpeed;
	end;
	
	if (self.m_targetPos and self.m_targetPos:Distance(centerPos) > 8) then
		local angleObject = util.AngleBetweenVectors(centerPos, self.m_targetPos);
		local radians, degrees = angleObject:Radians(), angleObject:Degrees();
		
		impulse = impulse + Vec2(
			math.cos(radians) * moveSpeed,
			math.sin(radians) * moveSpeed
		);
		
		if (self.m_targetPos.y > centerPos.y) then
			impulse.y = impulse.y + moveSpeed;
		elseif (self.m_targetPos.y < centerPos.y) then
			impulse.y = impulse.y - moveSpeed;
		end;
		
		self:SetAngle(degrees);
	end;
	
	if (impulse.x ~= 0 or impulse.y ~= 0) then
		self:ApplyImpulse(impulse);
		self:Play(self.m_sWalkAnim, animSpeed);
	else
		self:Stop(self.m_sWalkAnim);
	end;
	
	self:UpdateSprite(deltaTime);
end;

-- Called when the entity has been killed.
function ENTITY:OnKilled(damageInfo)
	if (math.random(1, 2) == 2) then
		util.MakeBloodParticles(damageInfo:GetPosition(), Color(0.1, 0.8, 0.1, 0.7));
	else
		util.MakeBloodParticles(damageInfo:GetPosition(), Color(0.8, 0.1, 0.1, 0.6));
	end;
	
	self:Remove();
end;

-- Called when the entity takes damage.
function ENTITY:OnTakeDamage(damageInfo)
	local damagePos = damageInfo:GetPosition();
	
	if (damageInfo:GetType() == DAMAGE_BULLET) then
		local damageForce = damageInfo:GetForce();
		local decalSize = math.random(32, 48);
		
		decals.Create("Blood", self:GetCenter(), decalSize, decalSize, Color(0, 0.8, 0, math.RandomFloat(0.2, 0.5)), 10);
		util.MakeBloodParticles(damagePos, Color(0.1, 0.8, 0.1, 0.7));
		
		self:ApplyForce(damageForce, damagePos);
	end;
end;