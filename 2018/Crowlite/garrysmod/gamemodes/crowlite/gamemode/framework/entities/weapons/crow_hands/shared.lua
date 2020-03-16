--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
end;

if (CLIENT) then
	SWEP.PrintName			= "Hands"
	SWEP.Author 			= "ruben"
	SWEP.Purpose			= "Back in Vietnam, your hands were your saviors. Without your hands you couldn't survive in the jungle."

	SWEP.DrawAmmo 			= false;
	SWEP.DrawCrosshair 		= false;
	SWEP.DrawSecondaryAmmo	= false;
	SWEP.ViewModelFOV		= 50;
	SWEP.ViewModelFlip		= false;
	SWEP.CSMuzzleFlashes	= false;
	
	SWEP.Slot				= 1;
	SWEP.SlotPos			= 1;
end;

SWEP.Category				= "Crowlite"
SWEP.HoldType				= "fist"
SWEP.Spawnable				= true;
SWEP.AdminSpawnable			= true;

SWEP.ViewModel 				= "models/weapons/c_arms.mdl"
SWEP.WorldModel 			= ""
SWEP.UseHands				= true;

SWEP.Primary.ClipSize		= -1;
SWEP.Primary.DefaultClip	= -1;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			="none"
SWEP.DrawAmmo 				= false;

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Damage		= 100;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= ""

SWEP.HitDistance	= 38

local SwingSound = Sound("WeaponFrag.Throw");
local HitSound = Sound("Flesh.ImpactHard");

function SWEP:Initialize()
	self:SetHoldType("fist");
end;

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack");
	self:NetworkVar("Float", 1, "NextIdle");
end;

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel();
	
	self:SetNextIdle(CurTime() + vm:SequenceDuration());
end;

function SWEP:PrimaryAttack()
 	if (self.left == nil) then
		self.left = true;
	else
		self.left = !self.left;
	end;

	local anim = "fists_right";
	local ownerAnim = PLAYER_ATTACK1;
 
 	if (self.left) then
		anim = "fists_left";
	end;

	local vm = self.Owner:GetViewModel();
	
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim));

	self:EmitSound(SwingSound);

	self:UpdateNextIdle();
	self:SetNextMeleeAttack(CurTime() + 0.07);
	self:SetNextPrimaryFire(CurTime() + 0.8);
end;

function SWEP:SecondaryAttack()
end;

function SWEP:DealDamage()
	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence());
	
	local traceLine = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	})

	if (!IsValid(traceLine.Entity)) then 
		traceLine = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		});
	end;

	if (traceLine.Hit && !(game.SinglePlayer() && CLIENT)) then
		self:EmitSound(HitSound);
	end;

	local didHit = false;

	if (SERVER && IsValid(traceLine.Entity) && (traceLine.Entity:IsNPC() || traceLine.Entity:IsPlayer() || traceLine.Entity:Health() > 0)) then
		local dmgInfo = DamageInfo();
		local attacker = self.Owner;
		
		if (!IsValid(attacker)) then
			attacker = self;
		end;
		
		dmgInfo:SetAttacker(attacker);
		dmgInfo:SetInflictor(self);
		dmgInfo:SetDamage(math.random(8, 12));

		if (anim == "fists_left") then
			dmgInfo:SetDamageForce(self.Owner:GetRight() * 4912 + self.Owner:GetForward() * 9998);
		elseif (anim == "fists_right") then
			dmgInfo:SetDamageForce(self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989);
		end;

		traceLine.Entity:TakeDamageInfo(dmgInfo);
		didHit = true;
	end;

	if (SERVER && IsValid(traceLine.Entity)) then
		local physObject = traceLine.Entity:GetPhysicsObject();
		
		if (IsValid(physObject)) then
			physObject:ApplyForceOffset(self.Owner:GetAimVector() * 80 * physObject:GetMass(), traceLine.HitPos);
		end;
	end;
end;

function SWEP:OnDrop()
	self:Remove();
end;

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel();
	
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"));
	
	self:UpdateNextIdle();

	return true;
end;

function SWEP:Think()
	local vm = self.Owner:GetViewModel();
	local curtime = CurTime();
	local idleTime = self:GetNextIdle();

	if (idleTime > 0 && CurTime() > idleTime) then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)));

		self:UpdateNextIdle();
	end;

	local meleeTime = self:GetNextMeleeAttack();

	if (meleeTime > 0 && CurTime() > meleeTime) then
		self:DealDamage();
		self:SetNextMeleeAttack(0);
	end;

	if (SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1) then
	end;
end;