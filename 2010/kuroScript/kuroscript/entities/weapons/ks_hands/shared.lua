--[[
Name: "shared.lua".
Product: "kuroScript".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
	-- Add some resources files.
	resource.AddFile("models/weapons/v_punch.mdl");
	resource.AddFile("models/weapons/w_fists_t.mdl");
	
	-- Set some information.
	SWEP.ActivityTranslate = {
		[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_FIST,
		[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_FIST,
		[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_FIST,
		[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1,
		[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_FIST,
		[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_FIST,
		[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_FIST,
		[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_FIST
	};
end;

-- Check if a statement is true.
if (CLIENT) then
	SWEP.Slot = 5;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Hands";
	SWEP.DrawCrosshair = true;
end

-- Set some information.
SWEP.Instructions = "Primary Fire: Punch.\nSecondary Fire: Knock.";
SWEP.Contact = "";
SWEP.Purpose = "Punching characters and knocking on doors.";
SWEP.Author	= "kuromeku";

-- Set some information.
SWEP.WorldModel = "models/weapons/w_fists_t.mdl";
SWEP.ViewModel = "models/weapons/v_punch.mdl";
SWEP.HoldType = "fist";

-- Set some information.
SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
-- Set some information.
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 4;
SWEP.Primary.Ammo = "";

-- Set some information.
SWEP.Secondary.NeverRaised = true;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Ammo	= "";

-- Set some information.
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.LoweredAngles = Angle(60, 60, 60);
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);

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

-- A function to punch an entity.
function SWEP:PunchEntity()
	local bounds = Vector(0, 0, 0);
	local startPosition = self.Owner:GetShootPos();
	local finishPosition = startPosition + (self.Owner:GetAimVector() * 64);
	
	-- Emit a sound from the weapon.
	self.Weapon:EmitSound("weapons/crossbow/hitbod2.wav");
	
	-- Check if a statement is true.
	if (SERVER) then
		self.Weapon:CallOnClient("PunchEntity", "");
		
		-- Set some information.
		local entity = self.Owner:TraceHullAttack(startPosition, finishPosition, bounds, bounds, self.Primary.Damage, DMG_CLUB, 1, true);
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) and !entity:IsPlayer() ) then
			if (entity.OnTakeDamage) then
				local damageInfo = kuroScript.frame:FakeDamageInfo(self.Primary.Damage, self, self.Owner, -1, finishPosition, DMG_CLUB, 1);
				
				-- Call an entity hook.
				entity:OnTakeDamage(damageInfo);
			end;
		end;
	end;
end;

-- A function to play the knock sound.
function SWEP:PlayKnockSound()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayKnockSound", "");
	end;
	
	-- Emit a sound from the weapon.
	self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav");
end;

-- A function to play the punch animation.
function SWEP:PlayPunchAnimation()
	if (SERVER) then
		self.Owner:EmitSound("npc/vort/claw_swing2.wav");
		
		-- Check if a statement is true.
		if (math.random(1, 2) == 2) then
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
		else
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK);
		end;
	end;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	if (SERVER) then
		if ( hook.Call("PlayerCanThrowPunch", kuroScript.frame, self.Owner) ) then
			self:PlayPunchAnimation();
			
			-- Set the owner's animation.
			self.Owner:SetAnimation(PLAYER_ATTACK1);
			
			-- Check if a statement is true.
			if (self.Owner.LagCompensation) then
				self.Owner:LagCompensation(true);
			end;
			
			-- Set some information.
			local trace = self.Owner:GetEyeTraceNoCursor();
			
			-- Check if a statement is true.
			if (self.Owner.LagCompensation) then
				self.Owner:LagCompensation(false);
			end;
			
			-- Check if a statement is true.
			if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
				if ( ValidEntity(trace.Entity) ) then
					if (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") then
						if ( trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 10
						and hook.Call("PlayerCanPunchKnockout", kuroScript.frame, self.Owner, trace.Entity) ) then
							kuroScript.player.SetRagdollState(trace.Entity, RAGDOLL_KNOCKEDOUT, 15);
							
							-- Call a gamemode hook.
							hook.Call("PlayerPunchKnockout", kuroScript.frame, self.Owner, trace.Entity);
						elseif ( hook.Call("PlayerCanPunchEntity", kuroScript.frame, self.Owner, trace.Entity) ) then
							self:PunchEntity();
							
							-- Call a gamemode hook.
							hook.Call("PlayerPunchEntity", kuroScript.frame, self.Owner, trace.Entity);
						end;
						
						-- Check if a statement is true.
						if ( trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) then
							local normal = ( trace.Entity:GetPos() - self.Owner:GetPos() ):Normalize();
							local push = 128 * normal;
							
							-- Set some information.
							trace.Entity:SetVelocity(push);
						end;
					elseif ( ValidEntity( trace.Entity:GetPhysicsObject() ) ) then
						if ( hook.Call("PlayerCanPunchEntity", kuroScript.frame, self.Owner, trace.Entity) ) then
							self:PunchEntity();
							
							-- Call a gamemode hook.
							hook.Call("PlayerPunchEntity", kuroScript.frame, self.Owner, trace.Entity);
						end;
					elseif (trace.Hit) then
						self:PunchEntity();
					end;
				elseif (trace.Hit) then
					self:PunchEntity();
				end;
			end;
			
			-- Call a gamemode hook.
			hook.Call("PlayerPunchThrown", kuroScript.frame, self.Owner);
			
			-- Set some information.
			local info = {
				primaryFire = 0.5,
				secondaryFire = 0.5
			};
			
			-- Call a gamemode hook.
			hook.Call("PlayerAdjustNextPunchInfo", kuroScript.frame, self.Owner, info);
			
			-- Set some information.
			self.Weapon:SetNextPrimaryFire(CurTime() + info.primaryFire);
			self.Weapon:SetNextSecondaryFire(CurTime() + info.secondaryFire);
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		-- Set some information.
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		-- Check if a statement is true.
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
		
		-- Check if a statement is true.
		if ( ValidEntity(trace.Entity) and kuroScript.entity.IsDoor(trace.Entity) ) then
			if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
				if ( hook.Call("PlayerCanKnockOnDoor", kuroScript.frame, self.Owner, trace.Entity) ) then
					self:PlayKnockSound();
					
					-- Set some information.
					self.Weapon:SetNextPrimaryFire(CurTime() + 0.25);
					self.Weapon:SetNextSecondaryFire(CurTime() + 0.25);
					
					-- Call a gamemode hook.
					hook.Call("PlayerKnockOnDoor", kuroScript.frame, self.Owner, trace.Entity);
				end;
			end;
		end;
	end;
end;