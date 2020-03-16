--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_iDrawLayer = LAYER_ITEMS;
ENTITY.m_bDrawShadow = false;
ENTITY.m_sHoldType = "pistol";
ENTITY.m_primary = {
	bulletSpread = Vec2(0.15, 0.1),
	tracerColor = Color(1, 1, 1, 1),
	isAutomatic = false,
	fireSound = "weapons/pistol/primary_fire",
	ammoType = "pistol",
	damage = 16,
	force = 196,
	delay = 0.1
};

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments)
	self:SetCollisionType(COLLISION_NONE);
	self:SetFixedRotation(false);
	self.m_iNextPrimaryFire = 0;
end;

-- Called when the entity's primary attack is fired.
function ENTITY:OnPrimaryAttack()
	local firePos = self:LocalToWorld(self:GetFirePos());
	local bulletInfo = {
		tracerColor = self.m_primary.tracerColor,
		direction = self:GetAimVector() + Vec2(
			math.RandomFloat(-self.m_primary.bulletSpread.x, self.m_primary.bulletSpread.y),
			math.RandomFloat(-self.m_primary.bulletSpread.y, self.m_primary.bulletSpread.y)
		),
		inflictor = self,
		position = self:LocalToWorld(self:GetFirePos()),
		damage = self.m_primary.damage,
		force = self.m_primary.force
	};
	
	self.m_owner:FireBullets(bulletInfo);
	self.m_owner:EmitSound(self.m_primary.fireSound);
end;

-- Called when the entity's secondary attack is fired.
function ENTITY:OnSecondaryAttack()
	local firePos = self:LocalToWorld(self:GetFirePos());
	local bulletInfo = {
		tracerColor = self.m_secondary.tracerColor,
		direction = self:GetAimVector(),
		inflictor = self,
		position = firePos,
		damage = self.m_secondary.damage,
		force = self.m_secondary.force
	};
	
	self.m_owner:FireBullets(bulletInfo);
	self.m_owner:EmitSound(self.m_secondary.fireSound);
end;

-- Called every frame for the entity.
function ENTITY:OnUpdate(deltaTime)
	if (not self:HasOwner()) then
		self:SetAngle(self:GetDegrees() + (64 * deltaTime));
		self:SetDrawLayer(LAYER_ITEMS);
	else
		self:SetDrawLayer(LAYER_WEAPONS);
	end;
	
	self:UpdateSprite();
end;

-- A function to get the weapon's hold type.
function ENTITY:GetHoldType()
	return self.m_sHoldType;
end;

-- A function to get whether the entity has a secondary attack.
function ENTITY:HasSecondaryAttack()
	return (self.m_secondary ~= nil);
end;

-- A function to get whether the primary attack is automatic.
function ENTITY:IsPrimaryAutomatic()
	return self.m_primary.isAutomatic;
end;

-- A function to set the entity's owner.
function ENTITY:SetOwner(owner)
	self.m_owner = owner;
	self:SetAngle(owner:GetAngle());
	self:SetParent(owner, owner:GetAttachmentPos() + self:GetHoldPos());
end;

-- A function to get the entity's owner.
function ENTITY:GetOwner()
	return self.m_owner;
end;

-- A function to get whether the entity has an owner.
function ENTITY:HasOwner()
	return (self.m_owner ~= nil and self.m_owner:IsValid());
end;

-- A function to get the entity's hold position.
function ENTITY:GetHoldPos()
	local materialData = self:GetMaterialData();
	local holdPos = Vec2(0, 0);
	local position = materialData:GetVector("holdPos");
	
	if (position) then
		holdPos.x = position.x;
		holdPos.y = position.y;
	end;
	
	return holdPos;
end;

-- A function to get the entity's fire position.
function ENTITY:GetFirePos()
	local materialData = self:GetMaterialData();
	local firePos = Vec2(0, 0);
	local position = materialData:GetVector("firePos");
	
	if (position) then
		firePos.x = position.x;
		firePos.y = position.y;
	end;
	
	return firePos;
end;

-- A function to fire the entity's primary attack.
function ENTITY:FirePrimaryAttack()
	if (self.m_iNextPrimaryFire > time.CurTime()) then
		return;
	end;
	
	if (self.m_owner and self.m_owner:IsValid()) then
		self.m_iNextPrimaryFire = time.CurTime() + self.m_primary.delay;
		self:OnPrimaryAttack();
	end;
end;

-- A function to fire the entity's secondary attack.
function ENTITY:FireSecondaryAttack()
	if (self.m_owner and self.m_owner:IsValid()) then
		if (self:HasSecondaryAttack()) then
			self:OnSecondaryAttack();
		end;
	end;
end;