--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Set some information.
AddCSLuaFile("cl_autorun.lua");
AddCSLuaFile("sh_autorun.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	-- Set some information.
	self:SetModel("models/props_combine/combine_lock01.mdl");
	
	-- Set some information.
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(800);
	self:SetSolid(SOLID_VPHYSICS);
	
	-- Set some information.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called each frame.
function ENT:Think()
	if ( ValidEntity(self._Entity) ) then
		if ( kuroScript.config.Get("combine_lock_overrides"):Get() ) then
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs(self._Entities) do
				if ( ValidEntity(v) ) then
					if ( self:IsLocked() ) then
						v:Fire("Lock", "", 0);
						v:Fire("Close", "", 0);
					else
						v:Fire("Unlock", "", 0);
					end;
				end;
			end;
		end;
	else
		self:Explode(); self:Remove();
	end;
	
	-- Set the next think.
	self:NextThink(CurTime() + 0.1);
end;

-- A function to set the entity's door.
function ENT:SetDoor(entity)
	local position = entity:GetPos();
	local angles = entity:GetAngles();
	local model = entity:GetModel();
	local skin = entity:GetSkin();
	local k, v;
	
	-- Set some information.
	self._Entity = entity;
	self._Entity:DeleteOnRemove(self);
	self._Entities = {entity};
	
	-- Loop through each value in a table.
	for k, v in ipairs( ents.FindByClass( entity:GetClass() ) ) do
		if (self._Entity != v) then
			if (v:GetModel() == model and v:GetSkin() == skin) then
				local tempPosition = v:GetPos();
				local distance = tempPosition:Distance(position);
				
				-- Check if a statement is true.
				if (distance >= 90 and distance <= 100) then
					if (v:GetAngles() != angles) then
						if ( math.floor(tempPosition.z) == math.floor(position.z) ) then
							self._Entities[#self._Entities + 1] = v;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs(self._Entities) do
		v._CombineLock = self;
	end;
end;

-- A function to get whether the entity is locked.
function ENT:IsLocked()
	return self:GetSharedVar("ks_Locked");
end;

-- A function to toggle whether the entity is locked.
function ENT:Toggle()
	if ( self:IsLocked() ) then
		self:Unlock();
	else
		self:Lock();
	end;
end;

-- A function to lock the entity.
function ENT:Lock()
	local k, v;
	
	-- Emit a random sound from the entity.
	self:EmitRandomSound();
	
	-- Loop through each value in a table.
	for k, v in ipairs(self._Entities) do
		if ( ValidEntity(v) ) then
			v:Fire("Lock", "", 0);
			v:Fire("Close", "", 0);
		end;
	end;
	
	-- Set some information.
	self:SetSharedVar("ks_Locked", true);
end;

-- A function to unlock the entity.
function ENT:Unlock()
	local k, v;
	
	-- Emit a random sound from the entity.
	self:EmitRandomSound();
	
	-- Loop through each value in a table.
	for k, v in ipairs(self._Entities) do
		if ( ValidEntity(v) ) then
			v:Fire("Unlock", "", 0);
		end;
	end;
	
	-- Set some information.
	self:SetSharedVar("ks_Locked", false);
end;

-- A function to set the entity's flash duration.
function ENT:SetFlashDuration(duration)
	self:EmitSound("buttons/combine_button_locked.wav");
	self:SetSharedVar("ks_Flash", CurTime() + duration);
end;

-- A function to activate the entity's smoke charge.
function ENT:ActivateSmokeCharge(force)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (self:GetSharedVar("ks_SmokeCharge") < curTime) then
		self:SetSharedVar("ks_SmokeCharge", curTime + 12);
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Smoke Charge: "..self:EntIndex(), 12, 1, function()
			if ( ValidEntity(self) ) then
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in ipairs(self._Entities) do
					if (ValidEntity(v) and string.lower( v:GetClass() ) == "prop_door_rotating") then
						kuroScript.game:BustDownDoor(nil, v, force);
						
						-- Set some information.
						local effectData = EffectData();
						
						-- Set some information.
						effectData:SetOrigin( self:GetPos() );
						effectData:SetScale(0.75);
						
						-- Set some information.
						util.Effect("ks_effect_smoke", effectData, true, true);
					end;
				end;
			end;
		end);
	end;
end;

-- A function to emit a random sound from the entity.
function ENT:EmitRandomSound()
	local randomSounds = {
		"buttons/combine_button1.wav",
		"buttons/combine_button2.wav",
		"buttons/combine_button3.wav",
		"buttons/combine_button5.wav",
		"buttons/combine_button7.wav"
	};
	
	-- Set some information.
	local randomSound = randomSounds[ math.random(1, #randomSounds) ];
	
	-- Check if a statement is true.
	if (self._Entities) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(self._Entities) do
			if ( ValidEntity(v) ) then
				v:EmitSound(randomSound);
			end;
		end;
	end;
	
	-- Emit a sound from the entity.
	self:EmitSound(randomSound);
end;

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set some information.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(1);
	
	-- Set some information.
	util.Effect("Explosion", effectData, true, true);
	
	-- Emit a sound.
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity is removed.
function ENT:OnRemove()
	self:Explode(); self:Unlock();
	
	-- Check if a statement is true.
	if (self._Entities) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(self._Entities) do
			if ( ValidEntity(v) ) then
				v:Fire("Unlock", "", 0);
			end;
		end;
	end;
end;

-- A function to toggle the entity with checks.
function ENT:ToggleWithChecks(activator)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!self._NextUse or curTime >= self._NextUse) then
		if ( curTime > self:GetSharedVar("ks_Flash") ) then
			if ( curTime > self:GetSharedVar("ks_SmokeCharge") ) then
				self._NextUse = curTime + 3;
				
				-- Check if a statement is true.
				if (!kuroScript.game:PlayerIsCombine(activator) and activator:QueryCharacter("class") != CLASS_CAD) then
					self:SetFlashDuration(3);
				else
					self:Toggle();
				end;
			end;
		end;
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		self:ToggleWithChecks(activator);
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if a statement is true.
	if (self:Health() <= 0) then
		self:ActivateSmokeCharge(damageInfo:GetDamageForce() * 8);
	end;
end;

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false;
end;