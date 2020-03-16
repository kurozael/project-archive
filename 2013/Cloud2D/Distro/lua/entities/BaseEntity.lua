--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_bShadowCaster = true;
ENTITY.m_iMaterialType = MAT_GENERIC;
ENTITY.m_bDrawShadow = true;
ENTITY.m_bUseSprite = true;
ENTITY.m_iDrawLayer = LAYER_NONE;
ENTITY.m_iEntIndex = 0;
ENTITY.m_bNotDrawn = false;
ENTITY.m_sMaterial = "entity";
ENTITY.m_sUniqueID = "ent:0";
ENTITY.m_bInvalid = false;
ENTITY.m_iHealth = 100;
ENTITY.m_iHeight = 32;
ENTITY.m_iWidth = 32;
ENTITY.m_iTeam = TEAM_GENERIC;

-- Called when the entity is constructed.
function ENTITY:__init(arguments)
	if (self.m_bUseSprite) then
		self.m_sprite = sprites.AddMaterial(self.m_sMaterial, true);
		self:SetSize(
			self.m_sprite:GetW(),
			self.m_sprite:GetH()
		);
	end;
	
	self.m_sUniqueID = "ent:"..self.m_iEntIndex;
	self.m_iMaxHealth = self.m_iHealth;
	self.m_physBody = nil;
	self.m_shadow = util.GetImage("lights/spotlight");
	self.m_color = Color(1, 1, 1, 1);
	self.m_links = {};
	self.m_flags = {};
	self.m_data = {};

	self:UpdateMaterialType();
	self:OnUpdatePhysicsBody();
	self:OnInitialize(arguments);
end;

-- Called when the entity is updated.
function ENTITY:__update(deltaTime)
	local parent = self:GetParent();
	
	if (parent and not parent:IsAwake()) then
		parent:WakeUp();
	end;
	
	if (not parent) then
		self:UnsetParent();
	end;
	
	self:OnUpdate(deltaTime);
end;

-- Called when the entity is removed.
function ENTITY:__remove() self:OnRemove(); end;

-- Called when the entity is drawn.
function ENTITY:__draw() self:OnDraw(); end;

-- Called when the entity has initialized.
function ENTITY:OnInitialize(arguments) end;

-- Called when the physics body should be updated.
function ENTITY:OnUpdatePhysicsBody()
	self:InitPhysicsBox(self:GetW(), self:GetH());
end;

-- Called before a collision with another entity is solved.
function ENTITY:OnPreSolveCollision(entity, collisionInfo) end;

-- Called after a collision with another entity is solved.
function ENTITY:OnPostSolveCollision(entity, collisionInfo) end;

-- Called when the entity begins contact with another entity.
function ENTITY:OnBeginContact(entity, collisionInfo) end;

-- Called when the entity ends contact with another entity.
function ENTITY:OnEndContact(entity, collisionInfo) end;

-- Called to get whether the entity should collide with another entity.
function ENTITY:OnShouldCollide(entity)
	return true;
end;

-- Called to get whether a ray should hit the entity.
function ENTITY:OnShouldTraceHit()
	return true;
end;

-- Called when an entity's key value type can be forced.
function ENTITY:OnForceKeyValueType(key) end;

-- Called when the entity changes material.
function ENTITY:OnChangeMaterial(material) end;

-- Called when the entity is updated within the editor.
function ENTITY:OnEditorUpdate(deltaTime) end;

-- Called when the entity is drawn within the editor.
function ENTITY:OnEditorDraw(rectangle)
	self:OnDraw();
end;

-- Called when the entity is being saved to a level.
function ENTITY:OnSaveLevel(data) end;

-- Called when the entity is being loaded from a level.
function ENTITY:OnLoadLevel(data) end;

-- Called when the entity is spawned.
function ENTITY:OnSpawn() end;

-- Called every frame for the entity.
function ENTITY:OnUpdate(deltaTime)
	self:UpdateSprite();
end;

-- Called when the entity is removed.
function ENTITY:OnRemove() end;

-- Called when the entity is drawn.
function ENTITY:OnDraw()
	self:DrawShadow(); self:DrawSprite();
end;

-- Called when the entity has been killed.
function ENTITY:OnKilled(damageInfo) end;

-- Called when the entity is given an input.
function ENTITY:OnInput(inputName, argString)
	if (inputName == "Remove") then
		self:Remove();
	end;
end;

-- Called when an output is called.
function ENTITY:OnOutput(outputName) end; 

-- Called when the entity takes damage.
function ENTITY:OnTakeDamage(damageInfo) end;

-- Called when an entity's key value is set.
function ENTITY:OnKeyValueSet(key, value) end;

-- A function to add a new key value.
function ENTITY:AddKeyValue(key, value, iForceType)
	self.m_keyValues[key] = value;
	
	if (iForceType) then
		self.m_forceTypes[key] = iForceType;
	end;
end;

-- A function to add a new entity link.
function ENTITY:AddLink(outputName, entity, inputName, argString)
	local entIndex = -1;
	
	if (type(entity) == "string") then
		entIndex = entity;
	elseif (not entity or not entity:IsValid()) then
		return;
	else
		entIndex = entity:EntIndex();
	end;
	
	self.m_links[outputName] = self.m_links[outputName] or {};
	self.m_links[outputName][entIndex] = self.m_links[outputName][entIndex] or {};
	
	table.insert(self.m_links[outputName][entIndex], {inputName = inputName, argString = argString});
end;

-- A function to get the entity's links.
function ENTITY:GetLinks()
	return self.m_links;
end;

-- A function to add an input.
function ENTITY:AddInput(inputName)
	self.m_inputs[inputName] = true;
end;

--[[ Add some default inputs. --]]
ENTITY:AddInput("Remove");

-- A function to add an output.
function ENTITY:AddOutput(outputName, bHasActivator)
	self.m_outputs[outputName] = {hasActivator = bHasActivator};
end;

-- A function to call an input.
function ENTITY:CallInput(inputName, argString)
	self:OnInput(inputName, argString);
end;

-- A function to call an output.
function ENTITY:CallOutput(outputName, activator)
	if (self.m_links[outputName]) then
		for k, v in pairs(self.m_links[outputName]) do
			local entIndex = tonumber(k);
			
			if (entIndex) then
				local entity = entities.GetByIndex(k);
				
				if (entity and entity:IsValid()) then
					for k2, v2 in pairs(v) do
						entity:CallInput(v2.inputName, v2.argString);
					end;
				end;
			elseif (activator and activator:IsValid()
			and (activator:IsDerivedFrom(k)
			or activator:GetClass() == k)) then
				for k2, v2 in pairs(v) do
					activator:CallInput(v2.inputName, v2.argString);
				end;
			end;
		end;
	end;
	
	self:OnOutput(outputName, activator);
end;

--[[
	Default entity key values.
	Do not modify!
--]]

ENTITY:AddKeyValue("TargetName", "");

-- A function to remove an existing key value.
function ENTITY:RemoveKeyValue(key)
	self.m_keyValues[key] = value;
	self.m_forceTypes[key] = nil;
end;

-- A function to get the entity's key values.
function ENTITY:GetKeyValues()
	return self.m_keyValues;
end;

-- A function to set an entity's key value.
function ENTITY:SetKeyValue(key, value)
	value = tonumber(value) or value;
	
	if (self.m_keyValues[key] == value) then
		return;
	end;
	
	self.m_keyValues[key] = value;
	self:OnKeyValueSet(key, value);
end;

-- A function to get a key value from the entity.
function ENTITY:GetKeyValue(key, kvDefault, kvType)
	if (self.m_keyValues[key] == nil) then
		return kvDefault;
	end;
	
	local keyValueType = self:GetKeyValueType(key);
	local value = self.m_keyValues[key];
	value = (tonumber(value) and tonumber(value) or value);
	
	if (kvType and keyValueType ~= kvType) then
		return kvDefault;
	end;
	
	return value;
end;

KEYVALUE_NIL = 0;
KEYVALUE_COLOR = 1;
KEYVALUE_ARRAY = 2;
KEYVALUE_STRING = 3;
KEYVALUE_NUMBER = 4;
KEYVALUE_BOOLEAN = 5;
KEYVALUE_TEXTURE = 6;

-- A function to get an entity's key value type.
function ENTITY:GetKeyValueType(key)
	local value = self.m_keyValues[key];
	local forceType = self:OnForceKeyValueType(key);
	if (forceType) then return forceType; end;
	
	if (self.m_forceTypes[key]) then
		return self.m_forceTypes[key];
	end;
	
	if (type(value) == "boolean") then
		return KEYVALUE_BOOLEAN;
	elseif (type(tonumber(value)) == "number") then
		return KEYVALUE_NUMBER;
	elseif (type(value) == "string") then
		return KEYVALUE_STRING;
	elseif (type(value) == "Color") then
		return KEYVALUE_COLOR;
	elseif (type(value) == "table") then
		return KEYVALUE_ARRAY;
	else
		return KEYVALUE_NIL;
	end;
end;

-- A function to initialize the entity's physics box.
function ENTITY:InitPhysicsBox(width, height)
	local materialData = materials.GetData(self.m_sMaterial);
	
	if (materialData) then
		height = materialData:GetNumber("height") or height;
		width = materialData:GetNumber("width") or width;
	end;
	
	if (self.m_physBody) then
		self.m_physBody:UpdateAsBox(width, height);
	else
		self.m_physBody = physics.CreateBox(width, height);
		self.m_physBody:SetData(tostring(self.m_iEntIndex));
		self:SetCollisionType(COLLISION_STATIC);
	end;
	
	self.m_physData = {width = width, height = height};
end;

-- A function to initialize the entity's physics circle.
function ENTITY:InitPhysicsCircle(radius)
	if (self.m_physBody) then
		self.m_physBody:UpdateAsCircle(radius);
	else
		self.m_physBody = physics.CreateCircle(radius);
		self.m_physBody:SetData(tostring(self.m_iEntIndex));
		self:SetCollisionType(COLLISION_STATIC);
	end;
	
	self.m_physData = {width = radius, height = radius};
end;

-- A function to make the entity take damage.
function ENTITY:TakeDamage(damageInfo)
	if (self:OnTakeDamage(damageInfo) ~= false and self:IsAlive()) then
		hooks.Call("EntityTakeDamage", self, damageInfo);
		self:SetHealth(self:GetHealth() - damageInfo:GetDamage());
		
		if (not self:IsAlive()) then
			hooks.Call("EntityKilled", self, damageInfo);
			self:OnKilled(damageInfo);
		end;
	end;
end;

-- A function to get whether the entity is derived from another.
function ENTITY:IsDerivedFrom(className)
	return (self.m_derivatives[className] ~= nil);
end;

-- A function to apply an impulse to the entity.
function ENTITY:ApplyImpulse(impulse, offset)
	if (self:HasPhysics()) then
		self.m_physBody:ApplyImpulse(impulse, offset or self:GetCenter());
	end;
end;

-- A function to apply a force to the entity.
function ENTITY:ApplyForce(force, offset)
	if (self:HasPhysics()) then
		self.m_physBody:ApplyForce(force, offset or self:GetCenter());
	end;
end;

-- A function to set the entity's health.
function ENTITY:SetHealth(health)
	self.m_iHealth = math.min(math.max(health, 0), self.m_iMaxHealth);
end;

-- A function to get the entity's health.
function ENTITY:GetHealth()
	return self.m_iHealth;
end;

-- A function to set the entity's team.
function ENTITY:SetTeam(team)
	self.m_iTeam = team;
end;

-- A function to get the entity's team.
function ENTITY:GetTeam()
	return self.m_iTeam;
end;

-- A function to get whether the entity is alive.
function ENTITY:IsAlive()
	return self.m_iHealth > 0;
end;

-- A function to setup the entity's physics.
function ENTITY:SetupPhysics()
	self:OnSetupPhysics();
end;

-- A function to set the entity's material type.
function ENTITY:SetMaterialType(materialType)
	self.m_iMaterialType = materialType;
end;

-- A function to get the entity's material type.
function ENTITY:GetMaterialType()
	return self.m_iMaterialType;
end;

-- A function to get a local position as a world position.
function ENTITY:LocalToWorld(localPos)
	local targetPos = self:GetPos() + localPos;
		targetPos:Rotate(self:GetCenter(), self:GetAngle());
	return targetPos;
end;

-- A function to get the entity's material.
function ENTITY:GetMaterial()
	return self.m_sMaterial;
end;

-- A function to set the entity's material.
function ENTITY:SetMaterial(material, bKeepSize)
	if (self.m_sMaterial ~= material) then
		local sprite = sprites.AddMaterial(material);
		local materialData = materials.GetData(material);
		
		if (self.m_sprite and not self:GetAnimation()) then
			self.m_sprite:CopyFrames(sprite);
			
			if (not bKeepSize) then
				self:SetSize(
					self.m_sprite:GetW(),
					self.m_sprite:GetH()
				);
			end;
		end;

		self.m_sMaterial = material;
			self:UpdateMaterialType();
		self:OnChangeMaterial(material);
	end;
end;

-- A function to set the entity's highest velocity.
function ENTITY:SetHighestVelocity(velocity)
	if (not self.m_highestVel or velocity:Length() > self.m_highestVel:Length()) then
		self.m_highestVel = velocity;
	end;
end;

-- A function to clear the entity's highest velocity.
function ENTITY:ClearHighestVelocity()
	self.m_highestVel = nil;
end;

-- A function to get the entity's highest velocity.
function ENTITY:GetHighestVelocity()
	return self.m_highestVel;
end;

-- A function to get the entity's material data.
function ENTITY:GetMaterialData()
	return materials.GetData(self.m_sMaterial);
end;

-- A function to update the entity's material type.
function ENTITY:UpdateMaterialType()
	self.m_iMaterialType = self:GetMaterialData():GetType();
end;

-- A function to set whether the entity's shadow is drawn.
function ENTITY:SetDrawShadow(bDrawShadow)
	self.m_bDrawShadow = bDrawShadow;
end;

-- A function to get whether the entity's shadow is drawn.
function ENTITY:GetDrawShadow()
	return self.m_bDrawShadow;
end;

-- A function to get the entity's data keys.
function ENTITY:GetDataKeys()
	return self:OnRequestDataKeys();
end;

-- A function to set whether the entity is not drawn.
function ENTITY:SetNotDrawn(bNotDrawn)
	self.m_bNotDrawn = bNotDrawn;
end;

-- A function to get whether the entity is not drawn.
function ENTITY:GetNotDrawn()
	return self.m_bNotDrawn;
end;

-- A function to set the entity's draw layer.
function ENTITY:SetDrawLayer(layer)
	if (self.m_iDrawLayer ~= layer) then
		entities.UpdateDrawLayers();
	end;
	
	self.m_iDrawLayer = layer;
end;

-- A function to set whether the entity has fixed rotation.
function ENTITY:SetFixedRotation(fixedRotation)
	self.m_physBody:SetFixedRotation(fixedRotation);
end;

-- A function to get whether the entity has fixed rotation.
function ENTITY:IsFixedRotation()
	return self.m_physBody:IsFixedRotation();
end;

-- A function to set the entity's max health.
function ENTITY:SetMaxHealth(maxHealth)
	self.m_iMaxHealth = maxHealth;
	self.m_iHealth = math.min(self.m_iHealth, maxHealth);
end;

-- A function to get the entity's max health.
function ENTITY:GetMaxHealth()
	return self.m_iMaxHealth;
end;

-- A function to set the entity's angular damping.
function ENTITY:SetAngularDamping(angularDamping)
	self.m_physBody:SetAngularDamping(angularDamping);
end;

-- A function to get the entity's angular damping.
function ENTITY:GetAngularDamping()
	return self.m_physBody:GetAngularDamping();
end;

-- A function to get the entity's draw layer.
function ENTITY:GetDrawLayer()
	return self.m_iDrawLayer;
end;

-- A function to set the entity's density.
function ENTITY:SetDensity(density)
	self.m_physBody:SetDensity(density);
end;

-- A function to get the entity's density.
function ENTITY:GetDensity()
	return self.m_physBody:GetDensity();
end;

-- A function to set the entity's damping.
function ENTITY:SetDamping(damping)
	self.m_physBody:SetDamping(damping);
end;

-- A function to get the entity's damping.
function ENTITY:GetDamping()
	return self.m_physBody:GetDamping();
end;

-- A function to set the entity's friction.
function ENTITY:SetFriction(friction)
	self.m_physBody:SetFriction(friction);
end;

-- A function to get the entity's friction.
function ENTITY:GetFriction()
	return self.m_physBody:GetFriction();
end;

-- A function to set the entity's mass.
function ENTITY:SetMass(mass)
	self.m_physBody:SetMass(mass);
end;

-- A function to get the entity's mass.
function ENTITY:GetMass()
	return self.m_physBody:GetMass();
end;

-- A function to set whether the entity is a bullet.
function ENTITY:SetBullet(isBullet)
	self.m_physBody:SetBullet(isBullet);
end;

-- A function to get whether the entity is a bullet.
function ENTITY:IsBullet()
	return self.m_physBody:IsBullet();
end;

-- A function to get whether the entity is awake.
function ENTITY:IsAwake()
	return self.m_physBody:IsAwake();
end;

-- A function to wake the entity up.
function ENTITY:WakeUp()
	self.m_physBody:WakeUp();
end;

-- A function to put the entity to sleep.
function ENTITY:Sleep()
	self.m_physBody:Sleep();
end;

-- Called to get whether the entity casts shadows.
function ENTITY:IsShadowCaster()
	return self.m_bShadowCaster;
end;

-- A function to set whether the entity casts shadows.
function ENTITY:SetShadowCaster(bShadowCaster)
	self.m_bShadowCaster = bShadowCaster;
end;

-- A function to emit a sound from the entity.
function ENTITY:EmitSound(fileName)
	local player = entities.GetPlayer();
	
	if (player) then
		local distance = player:GetPos():Distance(self:GetPos());
		local volume = math.Clamp(1 - ((1 / 384) * distance), 0, 1);
		
		sounds.PlaySound(fileName, volume);
	else
		sounds.PlaySound(fileName, 1);
	end;
end;

-- A function to get the entity's base class.
function ENTITY:BaseClass(className)
	if (className and self:IsDerivedFrom(className)) then
		return entities.GetTable(className);
	elseif (self.m_sBaseClass == "" or self.m_sBaseClass == nil) then
		return entities.GetTable("BaseEntity");
	else
		return entities.GetTable(self.m_sBaseClass);
	end;
end;

-- A function to set the entity flag.
function ENTITY:GiveFlag(key)
	self.m_flags[key] = true;
end;

-- A function to take the entity flag.
function ENTITY:TakeFlag(key)
	self.m_flags[key] = nil;
end;

-- A function to get whether the entity has a flag.
function ENTITY:HasFlag(key)
	return (self.m_flags[key] == true)
end;

-- A function to get whether the entity is the player.
function ENTITY:IsPlayer()
	return (entities.GetPlayer() == self);
end;

-- A function to get whether the entity is a weapon.
function ENTITY:IsWeapon()
	return self:IsDerivedFrom("Weapon");
end;

-- A function to make the entity the player.
function ENTITY:MakePlayer()
	entities.SetPlayer(self);
end;

-- A function to get the entity's physics body.
function ENTITY:GetPhysBody()
	return self.m_physBody;
end;

-- A function to get an entity's aim vector.
function ENTITY:GetAimVector()
	return util.AngleToVector(self:GetAngle());
end;

-- A function to fire bullets from the entity.
function ENTITY:FireBullets(bulletInfo)
	local rayFilter = {self, bulletInfo.inflictor};
	local damageInfo = nil;
	
	if (bulletInfo.attacker ~= self) then
		rayFilter[#rayFilter + 1] = bulletInfo.attacker;
	end;
	
	local rayData = util.RayCast(
		bulletInfo.position,
		bulletInfo.position + (bulletInfo.direction * 8192),
		rayFilter
	);
	
	if (bulletInfo.force) then
		bulletInfo.force = bulletInfo.force * 1000;
	end;
	
	if (rayData.didHit) then
		damageInfo = damage.AttackEntity(
			DAMAGE_BULLET,
			rayData.hitEntity,
			bulletInfo.attacker or self,
			bulletInfo.inflictor,
			rayData.hitPos,
			bulletInfo.damage,
			bulletInfo.direction * bulletInfo.force
		);
	end;
	
	if (not bulletInfo.hideTracer) then
		local tracer = effects.Create("BulletTracer");
			tracer:SetData("StartPos", rayData.startPos);
			tracer:SetData("EndPos", rayData.hitPos);
			tracer:SetData("Color", bulletInfo.tracerColor);
		tracer:Dispatch();
	end;
	
	if (bulletInfo.Callback) then
		bulletInfo.Callback(rayData);
	end;
	
	return damageInfo;
end;

-- A function to get whether the entity has physics.
function ENTITY:HasPhysics()
	return (self:GetCollisionType() == COLLISION_PHYSICS);
end;

-- A function to get the collision type.
function ENTITY:GetCollisionType()
	return self.m_iCollisionType;
end;

-- A function to set the collision type.
function ENTITY:SetCollisionType(collisionType)
	if (self:GetParent()) then
		self.m_oldCollisionType = collisionType;
		return;
	end;
	
	self.m_physBody:SetStatic(collisionType == COLLISION_STATIC);
	self.m_iCollisionType = collisionType;
end;

-- A function to get the entity's physics width.
function ENTITY:GetPhysW()
	return self.m_physData.width;
end;

-- A function to get the entity's physics height.
function ENTITY:GetPhysH()
	return self.m_physData.height;
end;

-- A function to get whether the entity is moving.
function ENTITY:IsMoving()
	return (self:HasPhysics() and self:GetVelocity():Length() > 1);
end;

-- A function to get the width of the entity.
function ENTITY:GetW()
	return self.m_iWidth;
end;

-- A function to get the height of the entity.
function ENTITY:GetH()
	return self.m_iHeight;
end;

-- A function to set the size of the entity.
function ENTITY:SetSize(width, height, bNoPhysUpdate)
	if (width ~= self.m_iWidth or height ~= self.m_iHeight) then
		self.m_iHeight = height; self.m_iWidth = width;
		
		if (not bNoPhysUpdate and self.m_physBody) then
			self:OnUpdatePhysicsBody();
		end;
	end;
end;

-- A function to set the entity's local position.
function ENTITY:SetLocalPos(position)
	self.m_localPos = position;
end;

-- A function to get the entity's local position.
function ENTITY:GetLocalPos()
	return self.m_localPos;
end;

-- A function to set the entity's local angle.
function ENTITY:SetLocalAngle(angle)
	self.m_localAngle = angle;
end;

-- A function to get the entity's local angle.
function ENTITY:GetLocalAngle()
	return self.m_localAngle;
end;

-- A function to set the entity's parent.
function ENTITY:SetParent(entity, localPos)
	if (self.m_parentData) then self:UnsetParent(); end;
	
	if (entity ~= nil and entity:IsValid()) then
		self.m_oldCollisionType = self:GetCollisionType();
		self:SetCollisionType(COLLISION_NONE);
		
		local parentDegrees = entity:GetDegrees();
		local entityDegrees = self:GetDegrees();
		
		entity:SetAngle(0); self:SetAngle(0);
		self:SetPos(entity:GetPos() + localPos);
		
		self.m_parentData = {
			entity = entity,
			joint = physics.WeldJoint(
				entity:GetPhysBody(), 
				self:GetPhysBody(),
				entity:GetPos()
			)
		};
		
		entity:SetAngle(parentDegrees);
		self:SetAngle(entityDegrees);
	end;
end;

-- A function to unset the entity's parent.
function ENTITY:UnsetParent()
	if (not self.m_parentData) then return; end;
	
	if (self.m_oldCollisionType) then
		self:SetCollisionType(self.m_oldCollisionType);
		self.m_oldCollisionType = nil;
	end;

	if (self.m_parentData.joint) then
		self.m_parentData.joint:Destroy();
	end;
	
	self.m_parentData = nil;
end;

-- A function to get the entity's parent.
function ENTITY:GetParent()
	if (self.m_parentData and self.m_parentData.entity:IsValid()) then
		return self.m_parentData.entity;
	end;
end;

-- A function to get the entity's position.
function ENTITY:GetPos()
	return self.m_physBody:GetPos() - Vec2(
		self:GetPhysW() / 2, self:GetPhysH() / 2
	);
end;

-- A function to set the entity's velocity.
function ENTITY:SetVelocity(velocity)
	if (self:HasPhysics()) then
		self.m_physBody:SetVelocity(velocity);
	end;
end;

-- A function to add to the entity's velocity.
function ENTITY:AddVelocity(velocity)
	if (self:HasPhysics()) then
		self.m_physBody:SetVelocity(self:GetVelocity() + velocity);
	end;
end;

-- A function to set the entity's angular spin.
function ENTITY:SetAngularVelocity(angularVelocity)
	self.m_physBody:SetAngularVelocity(angularVelocity);
end;

-- A function to add to the entity's angular spin.
function ENTITY:AddAngularVelocity(angularVelocity)
	self.m_physBody:SetAngularVelocity(self:GetAngularVelocity() + angularVelocity);
end;

-- A function to get the entity's angular spin.
function ENTITY:GetAngularVelocity()
	return self.m_physBody:GetAngularVelocity();
end;

-- A function to get the entity's velocity.
function ENTITY:GetVelocity()
	return self.m_physBody:GetVelocity();
end;

-- A function to get the entity's color.
function ENTITY:GetColor()
	return Color(
		self.m_color.r,
		self.m_color.g,
		self.m_color.b,
		self.m_color.a
	);
end;

-- A function to set the entity's color.
function ENTITY:SetColor(color)
	self.m_color.r = color.r;
	self.m_color.g = color.g;
	self.m_color.b = color.b;
	self.m_color.a = color.a;
end;

-- A function to get the entity's center.
function ENTITY:GetCenter()
	return self.m_physBody:GetPos();
end;

-- A function to set the entity's angle.
function ENTITY:SetAngle(angle)
	if (type(angle) == "number") then
		self.m_angle = util.Degrees(angle);
	else
		self.m_angle = angle;
	end;
	
	self.m_physBody:SetAngle(self.m_angle);
end;

-- A function to set the entity's position.
function ENTITY:SetPos(position)
	self.m_physBody:SetPos(
		position + Vec2(
			self:GetPhysW() / 2,
			self:GetPhysH() / 2
		)
	);
end;

-- A function to get the entity's angle.
function ENTITY:GetAngle(unitType)
	return self.m_physBody:GetAngle();
end;

-- A function to get an entity's angle in degrees.
function ENTITY:GetDegrees()
	return self:GetAngle():Degrees();
end;

-- A function to get an entity's angle in radians.
function ENTITY:GetRadians()
	return self:GetAngle():Radians();
end;

-- A function to draw the bounding box.
function ENTITY:DrawBBox(bAccurate)
	if (not bAccurate) then
		local position = self:GetPos();
		local height = self:GetPhysH();
		local width = self:GetPhysW();
		
		render.DrawBox(position.x, position.y, width, height, Color(1, 0, 0, 1));
	else
		physics.DebugDraw(self.m_physBody, Color(1, 0, 0, 1));
	end;
end;

-- A function to draw the shadow.
function ENTITY:DrawShadow()
	if (self.m_bDrawShadow and not self.m_bNotDrawn) then
		local position = self:GetPos();
		local height = self:GetH() + 64;
		local width = self:GetW() + 64;
		
		render.DrawImage(
			self.m_shadow,
			position.x - 32,
			position.y - 32,
			width, height,
			Color(0, 0, 0, 0.5)
		);
	end;
end;

-- A function to test whether a position hits the entity.
function ENTITY:HitTest(position)
	return self.m_physBody:HitTest(position);
end;

-- A function to draw the sprite.
function ENTITY:DrawSprite(fAlpha)
	if (self.m_sprite and not self.m_bNotDrawn) then
		local position = self:GetPos();
		local height = self:GetH();
		local width = self:GetW();
		local color = self:GetColor();
		
		if (fAlpha) then
			color.a = fAlpha;
		end;
		
		self.m_sprite:Draw(
			position.x,
			position.y,
			width, height,
			self:GetAngle(),
			color
		);
	end;
end;

-- A function to update the sprite.
function ENTITY:UpdateSprite()
	if (self.m_sprite) then
		self.m_sprite:Update();
	end;
end;

-- A function to set the entity's animation delay.
function ENTITY:SetDelay(seconds)
	self.m_sprite:SetDelay(seconds);
end;

-- A function to play an animation.
function ENTITY:Play(uniqueID, animDelay)
	if (self.m_sprite and self.m_sAnimation ~= uniqueID) then
		local sprite = sprites.Get(uniqueID);
		
		if (sprite) then
			self.m_sprite:CopyFrames(sprite);
			self.m_sprite:CopyModes(sprite);
			self.m_sAnimation = uniqueID;
			self:SetDelay(animDelay);
		end;
	end;
end;

-- A function to stop an animation.
function ENTITY:Stop(uniqueID)
	if (((uniqueID and self.m_sAnimation == uniqueID)
	or self.m_sAnimation ~= nil) and self.m_sprite) then
		local sprite = sprites.Get(self.m_sMaterial);
		
		if (sprite) then
			self.m_sprite:CopyFrames(sprite);
			self.m_sprite:CopyModes(sprite);
			self.m_sAnimation = nil;
		end;
	end;
end;

-- A function to spawn the entity.
function ENTITY:Spawn()
	if (not self.m_bSpawned) then
		entities.FlagAsSpawned(self);
		self.m_bSpawned = true;
		self:OnSpawn();
	end;
	
	return self;
end;

-- A function to remove the entity.
function ENTITY:Remove()
	entities.Remove(self);
end;

-- A function to get the entity index.
function ENTITY:EntIndex()
	return self.m_iEntIndex;
end;

-- A function to get whether the entity is valid.
function ENTITY:IsValid()
	return (not self.m_bInvalid);
end;

-- A function to get the entity's sprite.
function ENTITY:GetSprite()
	return self.m_sprite;
end;

-- A function to get the entity's current animation.
function ENTITY:GetAnimation()
	return self.m_sAnimation;
end;

-- A function to get the entity's class.
function ENTITY:GetClass()
	return self.m_sClassName;
end;

-- A function to get the entity's unique ID.
function ENTITY:UniqueID()
	return self.m_sUniqueID;
end;