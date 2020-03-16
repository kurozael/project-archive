--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
	resource.AddFile("materials/models/weapons/baseball_bat/metal_bat.vtf");
	resource.AddFile("materials/models/weapons/baseball_bat/metal_bat.vmt");
	
	for k, v in pairs(_file.Find("../models/weapons/v_basball.*")) do
		resource.AddFile("models/weapons/"..v);
	end;
	
	for k, v in pairs(_file.Find("../models/weapons/w_basball.*")) do
		resource.AddFile("models/weapons/"..v);
	end;
end;

if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 5;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Baseball Bat";
	SWEP.DrawCrosshair = true;
end

SWEP.Instructions = "Primary Fire: Whack.";
SWEP.Purpose = "Beating the shit out the infected folk.";
SWEP.Contact = "";
SWEP.Author	= "kurozael";

SWEP.WorldModel = "models/weapons/w_basball.mdl";
SWEP.ViewModel = "models/weapons/v_basball.mdl";
SWEP.HoldType = "melee";

SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 8;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "";

SWEP.Secondary.NeverRaised = true;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Delay = 1;
SWEP.Secondary.Ammo	= "";

SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW);
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	
	return true;
end;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType);
end;

-- A function to do the SWEP's hit effects.
function SWEP:DoHitEffects()
	local traceLine = self.Owner:GetEyeTraceNoCursor();
	
	if (((traceLine.Hit or traceLine.HitWorld) and self.Owner:GetPos():Distance(traceLine.HitPos) <= 96)) then
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		self:EmitSound("weapons/crossbow/hitbod2.wav");
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("weapons/stunstick/stunstick_swing"..math.random(1, 2)..".wav");
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
	local weaponDelay = self.Primary.Delay;
	
	self:SetNextPrimaryFire(CurTime() + weaponDelay);
	self:SetNextSecondaryFire(CurTime() + weaponDelay);
	
	self:DoAnimations(); self:DoHitEffects();
	
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		local traceLine = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetShootPos():Distance(traceLine.HitPos) <= 96) then
			if (IsValid(traceLine.Entity)) then
				local player = Clockwork.entity:GetPlayer(traceLine.Entity);
				local strength = Clockwork.attributes:Fraction(self.Owner, ATB_STRENGTH, 10, 5);
				
				if (traceLine.Entity:IsPlayer() or traceLine.Entity:IsNPC()) then
					local normal = (traceLine.Entity:GetPos() - self.Owner:GetPos()):Normalize();
					local push = 128 * normal;
					
					traceLine.Entity:SetVelocity(push);
					
					timer.Simple(FrameTime() * 0.5, function()
						if (IsValid(traceLine.Entity)) then
							traceLine.Entity:TakeDamageInfo(Clockwork:FakeDamageInfo(self.Primary.Damage + strength, self, self.Owner, traceLine.HitPos, DMG_CLUB, 2));
						end;
					end);
					
					self.Owner:ProgressAttribute(ATB_STRENGTH, 1, true);
				else
					local physicsObject = traceLine.Entity:GetPhysicsObject();
					
					if (IsValid(physicsObject)) then
						physicsObject:ApplyForceOffset(self.Owner:GetAimVector() * math.max(math.min(physicsObject:GetMass(), 100) * 10, 1024), traceLine.HitPos);
						
						if (!player) then
							timer.Simple(FrameTime() * 0.5, function()
								if (IsValid(traceLine.Entity)) then
									traceLine.Entity:TakeDamageInfo(Clockwork:FakeDamageInfo((self.Primary.Damage / 2) + strength, self, self.Owner, traceLine.HitPos, DMG_CLUB, 2));
								end;
							end);
							
							self.Owner:ProgressAttribute(ATB_STRENGTH, 0.5, true);
						else
							timer.Simple(FrameTime() * 0.5, function()
								if (IsValid(traceLine.Entity)) then
									traceLine.Entity:TakeDamageInfo(Clockwork:FakeDamageInfo(self.Primary.Damage + strength, self, self.Owner, traceLine.HitPos, DMG_CLUB, 2));
								end;
							end);
							
							self.Owner:ProgressAttribute(ATB_STRENGTH, 1, true);
						end;
					end;
				end;
			else
				self.Owner:FireBullets({
					Spread = Vector(0, 0, 0),
					Damage = 1,
					Tracer = 0,
					Force = 1,
					Num = 1,
					Src = self.Owner:GetShootPos(),
					Dir = self.Owner:GetAimVector()
				});
			end;
		end;
		
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;