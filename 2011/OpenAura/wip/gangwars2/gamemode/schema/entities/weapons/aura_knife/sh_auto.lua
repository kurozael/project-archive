--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (SERVER) then
	AddCSLuaFile("sh_auto.lua");
end;

if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 5;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Knife";
	SWEP.DrawCrosshair = true;
end

SWEP.Instructions = "Primary Fire: Crack.";
SWEP.Purpose = "This weapon can jib up any human and make them bleed.";
SWEP.Contact = "";
SWEP.Author	= "kurozael";

SWEP.WorldModel = "models/weapons/w_knife_t.mdl";
SWEP.ViewModel = "models/weapons/v_knife_t.mdl";
SWEP.HoldType = "fist";

SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 32;
SWEP.Primary.Delay = 0.8;
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
	self:EmitSound("weapons/knife/knife_deploy1.wav");
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
	local trace = self.Owner:GetEyeTraceNoCursor();
	
	if ( ( (trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 64 ) ) then
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		
		if ( IsValid(trace.Entity) and ( trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) ) then
			self:EmitSound("weapons/knife/knife_hit"..math.random(1, 4)..".wav");
		else
			self:EmitSound("weapons/knife/knife_hitwall1.wav");
		end;
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
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
		
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
			if ( IsValid(trace.Entity) ) then
				local player = openAura.entity:GetPlayer(trace.Entity);
				
				if ( trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) then
					local normal = ( trace.Entity:GetPos() - self.Owner:GetPos() ):Normalize();
					local push = 128 * normal;
					
					trace.Entity:SetVelocity(push);
					
					timer.Simple(FrameTime() * 0.5, function()
						if ( IsValid(trace.Entity) ) then
							trace.Entity:TakeDamageInfo( openAura:FakeDamageInfo(self.Primary.Damage, self, self.Owner, trace.HitPos, DMG_CLUB, 2) );
						end;
					end);
				else
					local physicsObject = trace.Entity:GetPhysicsObject();
					
					if ( IsValid(physicsObject) ) then
						physicsObject:ApplyForceOffset(self.Owner:GetAimVector() * math.max(math.min(physicsObject:GetMass(), 100) * 10, 1024), trace.HitPos);
						
						if (!player) then
							timer.Simple(FrameTime() * 0.5, function()
								if ( IsValid(trace.Entity) ) then
									trace.Entity:TakeDamageInfo( openAura:FakeDamageInfo( (self.Primary.Damage * 2), self, self.Owner, trace.HitPos, DMG_CLUB, 2 ) );
								end;
							end);
						else
							timer.Simple(FrameTime() * 0.5, function()
								if ( IsValid(trace.Entity) ) then
									trace.Entity:TakeDamageInfo( openAura:FakeDamageInfo(self.Primary.Damage, self, self.Owner, trace.HitPos, DMG_CLUB, 2) );
								end;
							end);
						end;
					end;
				end;
			else
				self.Owner:FireBullets( {
					Spread = Vector(0, 0, 0),
					Damage = 1,
					Tracer = 0,
					Force = 1,
					Num = 1,
					Src = self.Owner:GetShootPos(),
					Dir = self.Owner:GetAimVector()
				} );
			end;
		end;
		
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;