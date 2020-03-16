if (SERVER) then

	AddCSLuaFile( "shared.lua" );

end

if (CLIENT) then

--[[ Basic SWEP Information to display to the client. ]]--

	SWEP.PrintName			= "P228"			
	SWEP.Author				= "Zig"
	SWEP.Purpose			= "A firearm used to harm beings."
	SWEP.Instructions		= "Press LMB to fire and R to reload."
	SWEP.Contact				= "Cloudsixteen.com"
	SWEP.CSMuzzleFlashes = true; -- Use Counter-Strike muzzle flashes?

end;


--[[ Set whether the SWEP is spawnable (by users or by admins). --]]

SWEP.Spawnable = true;
SWEP.AdminSpawnable	= true;

--[[ Misc. SWEP Content --]]

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "Backsword"
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false; -- Some view models are incorrectly flipped.
SWEP.UseHands = true;

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_p228.mdl"

SWEP.DrawAmmo = true; -- Draw our own ammo display?
SWEP.DrawCrosshair = false; -- Draw the crosshair, or draw our own?

--[[ These really aren't important. Keep them at false, and the weight at five. --]]

SWEP.Weight	= 5
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom	= false;

--[[ Set the SWEP's primary fire information. --]]

SWEP.Primary.DefaultClip = 50;
SWEP.Primary.ClipSize = 8;
SWEP.Primary.Automatic = false;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Damage	= 18;
SWEP.Primary.Recoil	= 0.50;
SWEP.Primary.Sound		= Sound("weapons/pistol_silver/gunfire/pistol_fire.wav")
SWEP.Primary.Delay = 0.1;
SWEP.Primary.Ammo = "xbowbolt";
SWEP.Primary.Cone = 0.02;

--[[ Set the SWEP's secondary fire information. --]]

SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.ClipSize	= -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

--[[ Define the bullet information for later use. --]]

SWEP.BulletTracerFreq = 1; -- Show a tracer every x bullets.
SWEP.BulletTracerName = nil -- Use a custom effect for the tracer.
SWEP.BulletForce = 5;

--[[ Set up the ironsight's position and angles. --]]
--[[ These are nil because we are using the Clockwork Framework --]]

SWEP.IronSightsPos = Vector(-6.091, 0, 2.68)
SWEP.IronSightsAng = Vector(0, -0.294, 0.002)

--[[ Set up the accuracy for the weapon. --]]

SWEP.CrouchCone				= 0.0085 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.05 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.015 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.010 -- Accuracy when we're standing still

	/************************************************************
		The Inner Workings
	************************************************************/

	/**************************
		Initialize/cache
	**************************/

function SWEP:Initialize()
util.PrecacheSound(self.Primary.Sound) 
        self:SetWeaponHoldType( self.HoldType )
end 

	/**************************
		Primary Attack
	**************************/

function SWEP:PrimaryAttack()
 
if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound(self.Primary.Sound);
	
		self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
	self:TakePrimaryAmmo(1);

self:ShootEffects()

self:EmitSound(Sound(self.Primary.Sound)) 
 
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Primary.Delay ) 
end

	/**************************
		Deploy
	**************************/

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	return true
end 

	/**************************
		Reload
	**************************/

function SWEP:Reload()
 if ( self:Clip1() ~= self.Primary.ClipSize and self:Ammo1() ~= 0 ) then
        self.Weapon:DefaultReload( ACT_VM_RELOAD );
end
end