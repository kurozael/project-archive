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
	self:SetModel("models/props_junk/watermelon01.mdl");
	
	-- Set some information.
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	
	-- Set some information.
	self._Dispenser = ents.Create("prop_dynamic");
	self._Dispenser:DrawShadow(false);
	self._Dispenser:SetAngles( self:GetAngles() );
	self._Dispenser:SetParent(self);
	self._Dispenser:SetModel("models/props_combine/combine_dispenser.mdl");
	self._Dispenser:SetPos( self:GetPos() );
	self._Dispenser:Spawn();
	
	-- Delete the entity when this one is removed.
	self:DeleteOnRemove(self._Dispenser);
	
	-- Set some information.
	local minimum = Vector() * -8;
	local maximum = Vector() * 8;
	
	-- Set some information.
	self:SetCollisionBounds(minimum, maximum);
	self:SetCollisionGroup(COLLISION_GROUP_WORLD);
	self:PhysicsInitBox(minimum, maximum);
	self:DrawShadow(false);
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
	self:SetSharedVar("ks_Locked", true);
	
	-- Emit a random sound from the entity.
	self:EmitRandomSound();
end;

-- A function to unlock the entity.
function ENT:Unlock()
	self:SetSharedVar("ks_Locked", false);
	
	-- Emit a random sound from the entity.
	self:EmitRandomSound();
end;

-- A function to set the entity's flash duration.
function ENT:SetFlashDuration(duration)
	self:EmitSound("buttons/combine_button_locked.wav");
	self:SetSharedVar("ks_Flash", CurTime() + duration);
end;

-- A function to create a dummy ration.
function ENT:CreateDummyRation()
	local forward = self:GetForward() * 15;
	local right = self:GetRight() * 0;
	local up = self:GetUp() * -8;
	
	-- Set some information.
	local entity = ents.Create("prop_physics");
	
	-- Set some information.
	entity:SetAngles( self:GetAngles() );
	entity:SetModel("models/weapons/w_package.mdl");
	entity:SetPos(self:GetPos() + forward + right + up);
	entity:Spawn();
	
	-- Return the entity.
	return entity;
end;

-- A function to activate the entity's ration.
function ENT:ActivateRation(activator, duration, force)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!duration) then duration = 24; end;
	
	-- Check if a statement is true.
	if (force or !self._NextActivateRation or curTime >= self._NextActivateRation) then
		self._NextActivateRation = curTime + duration + 2;
		
		-- Set some information.
		self:SetSharedVar("ks_Ration", curTime + duration);
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Ration: "..self:EntIndex(), duration, 1, function()
			if ( ValidEntity(self) ) then
				if ( !ValidEntity(activator) ) then
					activator = nil;
				end;
				
				-- Set some information.
				local frameTime = FrameTime() * 0.5;
				local dispenser = self._Dispenser;
				local entity = self:CreateDummyRation();
				
				-- Check if a statement is true.
				if ( ValidEntity(entity) ) then
					dispenser:EmitSound("ambient/machines/combine_terminal_idle4.wav");
					
					-- Set some information.
					entity:SetNotSolid(true);
					entity:SetParent(dispenser);
					
					-- Set some information.
					timer.Simple(frameTime, function()
						if ( ValidEntity(self) and ValidEntity(entity) ) then
							entity:Fire("SetParentAttachment", "package_attachment", 0);
							
							-- Set some information.
							timer.Simple(frameTime, function()
								if ( ValidEntity(self) and ValidEntity(entity) ) then
									dispenser:Fire("SetAnimation", "dispense_package", 0);
									
									-- Set some information.
									timer.Simple(1.75, function()
										if ( ValidEntity(self) and ValidEntity(entity) ) then
											entity:CallOnRemove("CreateRation", function()
												if ( ValidEntity(entity) ) then
													kuroScript.entity.CreateItem( activator, "ration", entity:GetPos(), entity:GetAngles() );
												end;
											end);
											
											-- Check if a statement is true.
											if (ValidEntity(activator) and !force) then
												if (activator:GetCharacterData("customclass") == "Civil Worker's Union") then
													self:ActivateRation(activator, 8, true);
												end;
											end;
											
											-- Set some information.
											entity:SetNoDraw(true);
											entity:Remove();
										end;
									end);
								end;
							end);
						end;
					end);
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
	
	-- Emit a sound from the entity.
	self:EmitSound( randomSounds[ math.random(1, #randomSounds) ] );
end;

-- Called when the entity's physics should be updated.
function ENT:PhysicsUpdate(physicsObject)
	if ( !self:IsPlayerHolding() and !self:IsConstrained() ) then
		physicsObject:SetVelocity( Vector(0, 0, 0) );
		physicsObject:Sleep();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		local curTime = CurTime();
		local unixTime = os.time();
		
		-- Check if a statement is true.
		if (!self._NextUse or curTime >= self._NextUse) then
			if (activator:QueryCharacter("class") == CLASS_CIT) then
				if ( !self:IsLocked() and unixTime >= activator:GetCharacterData("nextration", 0) ) then
					if (!self._NextActivateRation or curTime >= self._NextActivateRation) then
						self:ActivateRation(activator);
						
						-- Set some information.
						activator:SetCharacterData("nextration", unixTime + kuroScript.config.Get("wages_interval"):Get() * 10);
					end;
				else
					self:SetFlashDuration(3);
				end;
			elseif (!self._NextActivateRation or curTime >= self._NextActivateRation) then
				self:Toggle();
			end;
			
			-- Set some information.
			self._NextUse = curTime + 3;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false;
end;