--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
end;

if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 5;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Woodaxe";
	SWEP.DrawCrosshair = true;
end

SWEP.Instructions = "Primary Fire: Whack.";
SWEP.Purpose = "Ever wanted to slice someone in three? Here is your chance.";
SWEP.Contact = "";
SWEP.Author	= "kurozael";

SWEP.WorldModel = "models/weapons/w_axe.mdl";
SWEP.ViewModel = "models/weapons/v_axe/v_axe.mdl";
SWEP.HoldType = "melee";

SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 17;
SWEP.Primary.Delay = 2;
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
	
	if (((traceLine.Hit or traceLine.HitWorld) and self.Owner:GetShootPos():Distance(traceLine.HitPos) <= 64)) then
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		self:EmitSound("weapons/crossbow/hitbod2.wav");
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("npc/vort/claw_swing2.wav");
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
	
	self:DoAnimations(); self:DoHitEffects();
	
	if (SERVER) then
		local traceLine = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetShootPos():Distance(traceLine.HitPos) > 96
		or !IsValid(traceLine.Entity)) then
			return;
		end;
		
		local player = Clockwork.entity:GetPlayer(traceLine.Entity);
		local strength = Clockwork.attributes:Fraction(self.Owner, ATB_STRENGTH, self.Primary.Damage, self.Primary.Damage * 0.5);
		
		if (traceLine.Entity:IsPlayer() or traceLine.Entity:IsNPC()) then
			local normal = (traceLine.Entity:GetPos() - self.Owner:GetPos()):Normalize();
			local push = 128 * normal;
			
			traceLine.Entity:SetVelocity(push);
			
			timer.Simple(FrameTime() * 0.5, function()
				if (IsValid(traceLine.Entity)) then
					traceLine.Entity:TakeDamageInfo(
						Clockwork:FakeDamageInfo(self.Primary.Damage + strength, self, self.Owner, traceLine.HitPos, DMG_CLUB, 2)
					);
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
							traceLine.Entity:TakeDamageInfo(
								Clockwork:FakeDamageInfo((self.Primary.Damage * 2) + strength, self, self.Owner, traceLine.HitPos, DMG_CLUB, 2)
							);
						end;
					end);
					
					self.Owner:ProgressAttribute(ATB_STRENGTH, 0.5, true);
				else
					timer.Simple(FrameTime() * 0.5, function()
						if (IsValid(traceLine.Entity)) then
							traceLine.Entity:TakeDamageInfo(
								Clockwork:FakeDamageInfo(self.Primary.Damage + strength, self, self.Owner, traceLine.HitPos, DMG_CLUB, 2)
							);
						end;
					end);
					
					self.Owner:ProgressAttribute(ATB_STRENGTH, 1, true);
				end;
			end;
		end
		
		self.Owner:ViewPunch(Angle(
			math.Rand(-16, 16), math.Rand(-8, 8) 0
		));
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;