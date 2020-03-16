--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

if (SERVER) then
	AddCSLuaFile("sh_autorun.lua");
	
	-- Add some resources files.
	resource.AddFile("materials/models/weapons/v_stunstick/v_stunstick_diffuse.vmt");
	resource.AddFile("materials/models/weapons/v_stunstick/v_stunstick_diffuse.vtf");
	resource.AddFile("materials/models/weapons/v_stunstick/v_stunstick_normal.vtf");
	
	-- Add some resources files.
	resource.AddFile("models/weapons/v_stunstick.dx80.vtx");
	resource.AddFile("models/weapons/v_stunstick.dx90.vtx");
	resource.AddFile("models/weapons/v_stunstick.sw.vtx");
	resource.AddFile("models/weapons/v_stunstick.mdl");
	resource.AddFile("models/weapons/v_stunstick.phy");
	resource.AddFile("models/weapons/v_stunstick.vvd");
end;

-- Check if a statement is true.
if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 5;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Stunstick";
	SWEP.DrawCrosshair = true;
end

-- Set some information.
SWEP.Instructions = "Primary Fire: Stun.\nSecondary Fire: Push/Knock.";
SWEP.Purpose = "Stunning disobedient characters, pushing them away and knocking on doors.";
SWEP.Contact = "";
SWEP.Author	= "kuromeku";

-- Set some information.
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl";
SWEP.ViewModel = "models/weapons/v_stunstick.mdl";
SWEP.HoldType = "melee";

-- Set some information.
SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
-- Set some information.
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 10;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "";

-- Set some information.
SWEP.Secondary.NeverRaised = true;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Delay = 1;
SWEP.Secondary.Ammo	= "";

-- Set some information.
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);

-- Check if a statement is true.
if (CLIENT) then
	SWEP.FirstPersonGlowSprite = Material("sprites/light_glow02_add_noz");
	SWEP.ThirdPersonGlowSprite = Material("sprites/light_glow02_add");
end;

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW);
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	
	-- Return true to break the function.
	return true;
end;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType);
	end;
end;

-- A function to play the knock sound.
function SWEP:PlayKnockSound()
	if (SERVER) then
		self:CallOnClient("PlayKnockSound", "");
	end;
	
	-- Emit a sound from the weapon.
	self:EmitSound("physics/wood/wood_crate_impact_hard2.wav");
end;

-- A function to play the push sound.
function SWEP:PlayPushSound()
	if (SERVER) then
		self:CallOnClient("PlayPushSound", "");
	end;
	
	-- Emit a sound from the weapon.
	self:EmitSound("weapons/crossbow/hitbod2.wav");
end;

-- A function to do the SWEP's hit effects.
function SWEP:DoHitEffects()
	local trace = self.Owner:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if ( ( (trace.Hit or trace.HitWorld) and self.Owner:GetPos():Distance(trace.HitPos) <= 96 ) ) then
		self:EmitSound("weapons/stunstick/spark"..math.random(1, 2)..".wav");
		
		-- Check if a statement is true.
		if ( ValidEntity(trace.Entity) and ( trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) ) then
			self:SendWeaponAnim(ACT_VM_MISSCENTER);
			self:EmitSound("weapons/stunstick/stunstick_fleshhit"..math.random(1, 2)..".wav");
		elseif ( ValidEntity(trace.Entity) and kuroScript.entity.GetPlayer(trace.Entity) ) then
			self:SendWeaponAnim(ACT_VM_MISSCENTER);
			self:EmitSound("weapons/stunstick/stunstick_fleshhit"..math.random(1, 2)..".wav");
		else
			self:SendWeaponAnim(ACT_VM_MISSCENTER);
			self:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav");
		end;
		
		-- Set some information.
		local effectData = EffectData();
		
		-- Set some information.
		effectData:SetStart(trace.HitPos);
		effectData:SetOrigin(trace.HitPos);
		effectData:SetNormal(trace.HitNormal);
		
		-- Check if a statement is true.
		if ( ValidEntity(trace.Entity) ) then
			effectData:SetEntity(trace.Entity);
		end;
		
		-- Set some information.
		util.Effect("StunstickImpact", effectData, true, true);
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("weapons/stunstick/stunstick_swing"..math.random(1, 2)..".wav");
	end;
end;

-- Called when the weapon is lowered.
function SWEP:OnLowered()
	self:EmitSound("weapons/stunstick/spark"..math.random(1, 3)..".wav");
	
	-- Check if a statement is true.
	if (SERVER) then
		self:CallOnClient("OnLowered", "");
		
		-- Check if a statement is true.
		if (kuroScript.animation.getModelClass( self.Owner:GetModel() ) == "civilProtection") then
			self.Owner:SetForcedAnimation("deactivatebaton", 1);
		end;
	end;
end;

-- Called when the weapon is raised.
function SWEP:OnRaised()
	self:EmitSound("weapons/stunstick/spark"..math.random(1, 3)..".wav");
	
	-- Check if a statement is true.
	if (SERVER) then
		self:CallOnClient("OnRaised", "");
		
		-- Check if a statement is true.
		if (kuroScript.animation.getModelClass( self.Owner:GetModel() ) == "civilProtection") then
			self.Owner:SetForcedAnimation("activatebaton", 1);
		end;
	end;
end;

-- Called when the world model is drawn.
function SWEP:DrawWorldModel()
	self:DrawModel();
	
	-- Check if a statement is true.
	if ( kuroScript.player.GetWeaponRaised(self.Owner) ) then
		local attachment = self:GetAttachment(1);
		local curTime = CurTime();
		local scale = math.abs(math.sin(curTime) * 4);
		local alpha = math.abs(math.sin(curTime) / 4);
		
		-- Set some information.
		self.ThirdPersonGlowSprite:SetMaterialFloat("$alpha", 0.7 + alpha);
		
		-- Check if a statement is true.
		if (attachment and attachment.Pos) then
			cam.Start3D( EyePos(), EyeAngles() );
				render.SetMaterial(self.ThirdPersonGlowSprite);
				render.DrawSprite( attachment.Pos, 8 + scale, 8 + scale, Color(255, 255, 255, 255 ) );
			cam.End3D();
		end;
	end;
end;

-- Called when the view model is drawn.
function SWEP:ViewModelDrawn()
	if ( kuroScript.player.GetWeaponRaised(self.Owner) ) then
		if ( self:IsCarriedByLocalPlayer() ) then
			local viewModel = g_LocalPlayer:GetViewModel();
			
			-- Check if a statement is true.
			if ( ValidEntity(viewModel) ) then
				local attachment = viewModel:GetAttachment( viewModel:LookupAttachment("sparkrear") );
				local curTime = CurTime();
				local scale = math.abs(math.sin(curTime) * 4);
				local alpha = math.abs(math.sin(curTime) / 4);
				local i;
				
				-- Set some information.
				self.FirstPersonGlowSprite:SetMaterialFloat("$alpha", 0.7 + alpha);
				self.ThirdPersonGlowSprite:SetMaterialFloat("$alpha", 0.5 + alpha);
				
				-- Check if a statement is true.
				if (attachment and attachment.Pos) then
					cam.Start3D( EyePos(), EyeAngles() );
						render.SetMaterial(self.ThirdPersonGlowSprite);
						render.DrawSprite( attachment.Pos, 8 + scale, 8 + scale, Color(255, 255, 255, 255 ) );
						
						-- Set some information.
						self.FirstPersonGlowSprite:SetMaterialFloat("$alpha", 0.5 + alpha);
						
						-- Loop through a range of values.
						for i = 1, 9 do
							local attachment = viewModel:GetAttachment( viewModel:LookupAttachment("spark"..i.."a") );
							
							-- Check if a statement is true.
							if (attachment.Pos) then
								if (i == 1 or i == 2 or i == 9) then
									render.SetMaterial(self.ThirdPersonGlowSprite);
								else
									render.SetMaterial(self.FirstPersonGlowSprite);
								end;
								
								-- Draw a sprite.
								render.DrawSprite( attachment.Pos, 1, 1, Color(255, 255, 255, 255) );
							end;
						end;
						
						-- Loop through a range of values.
						for i = 1, 9 do
							local attachment = viewModel:GetAttachment( viewModel:LookupAttachment("spark"..i.."b") );
							
							-- Check if a statement is true.
							if (attachment.Pos) then
								if (i == 1 or i == 2 or i == 9) then
									render.SetMaterial(self.ThirdPersonGlowSprite);
								else
									render.SetMaterial(self.FirstPersonGlowSprite);
								end;
								
								-- Draw a sprite.
								render.DrawSprite( attachment.Pos, 1, 1, Color(255, 255, 255, 255) );
							end;
						end;
					cam.End3D();
				end;
			end;
		end;
	end;
end;

-- A function to do the SWEP's animations.
function SWEP:DoAnimations(idle)
	if (!idle) then
		self.Owner:SetAnimation(PLAYER_ATTACK1);
	end;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	
	-- Do the animations and hit effects.
	self:DoAnimations(); self:DoHitEffects();
	
	-- Check if a statement is true.
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		-- Get an eye trace from the player.
		local trace = self.Owner:GetEyeTraceNoCursor();
		local bounds = Vector(0, 0, 0);
		local startPosition = self.Owner:GetShootPos();
		local finishPosition = startPosition + (self.Owner:GetAimVector() * 96);
		
		-- Check if a statement is true.
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 96) then
			if ( ValidEntity(trace.Entity) ) then
				local player = kuroScript.entity.GetPlayer(trace.Entity);
				local strength = kuroScript.attributes.Get(self.Owner, ATB_STRENGTH) or 0;
				
				-- Check if a statement is true.
				if ( trace.Entity:IsPlayer() ) then
					local normal = ( trace.Entity:GetPos() - self.Owner:GetPos() ):Normalize();
					local push = 128 * normal;
					
					-- Set some information.
					trace.Entity:SetVelocity(push);
					
					-- Check if a statement is true.
					if (trace.Entity:Health() > 10) then
						self.Owner:TraceHullAttack(startPosition, finishPosition, bounds, bounds, 1 + (0.04 * strength), DMG_CLUB, 2, true);
					end;
					
					-- Call a mount hook.
					kuroScript.mount.Call("PlayerStunEntity", self.Owner, trace.Entity);
				elseif ( ValidEntity( trace.Entity:GetPhysicsObject() ) ) then
					trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 256, trace.HitPos);
					
					-- Check if a statement is true.
					if (!player or player:Health() > 10) then
						if (!player) then
							local damage = 5 + (0.0666666667 * strength);
							local entity = self.Owner:TraceHullAttack(startPosition, finishPosition, bounds, bounds, damage, DMG_CLUB, 2, true);
							
							-- Check if a statement is true.
							if ( ValidEntity(entity) ) then
								if (entity.OnTakeDamage) then
									local damageInfo = kuroScript.frame:FakeDamageInfo(damage, self, self.Owner, -1, finishPosition, DMG_CLUB, 2);
									
									-- Call an entity hook.
									entity:OnTakeDamage(damageInfo);
								end;
							end;
						else
							self.Owner:TraceHullAttack(startPosition, finishPosition, bounds, bounds, 1 + (0.04 * strength), DMG_CLUB, 2, true);
						end;
					end;
					
					-- Call a mount hook.
					kuroScript.mount.Call("PlayerStunEntity", self.Owner, trace.Entity);
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		-- Get an eye trace from the player.
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		-- Check if a statement is true.
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 96) then
			if ( ValidEntity(trace.Entity) ) then
				if ( self.Owner:GetShootPos():Distance(trace.HitPos) <= 64 and kuroScript.entity.IsDoor(trace.Entity) ) then
					self:SetNextPrimaryFire(CurTime() + 0.25);
					self:SetNextSecondaryFire(CurTime() + 0.25);
					
					-- Check if a statement is true.
					if ( hook.Call("PlayerCanKnockOnDoor", kuroScript.frame, self.Owner, trace.Entity) ) then
						self:PlayKnockSound();
						
						-- Call a gamemode hook.
						hook.Call("PlayerKnockOnDoor", kuroScript.frame, self.Owner, trace.Entity);
					end;
				else
					self:PlayPushSound();
					
					-- Set some information.
					self:SetNextPrimaryFire(CurTime() + 0.5);
					self:SetNextSecondaryFire(CurTime() + 0.5);
					
					-- Check if a statement is true.
					if (kuroScript.animation.getModelClass( self.Owner:GetModel() ) == "civilProtection") then
						self.Owner:SetForcedAnimation("pushplayer", 1);
					end;
					
					-- Check if a statement is true.
					if ( trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) then
						if (self.Owner:GetPos():Distance(trace.HitPos) <= 96) then
							local normal = ( trace.Entity:GetPos() - self.Owner:GetPos() ):Normalize();
							local push = 256 * normal;
							
							-- Set some information.
							trace.Entity:SetVelocity(push);
						end;
					elseif ( ValidEntity( trace.Entity:GetPhysicsObject() ) ) then
						trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 256, trace.HitPos);
					end;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
end;