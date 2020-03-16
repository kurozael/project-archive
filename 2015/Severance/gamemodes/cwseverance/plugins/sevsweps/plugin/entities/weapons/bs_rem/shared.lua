if (SERVER) then

	AddCSLuaFile( "shared.lua" );

end

if (CLIENT) then

	
--[[ Basic SWEP Information to display to the client. ]]--

	SWEP.PrintName			= "Remington 570"			
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

SWEP.HoldType			= "shotgun"
SWEP.Base				= "bs_base"
SWEP.Category			= "Backsword"
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false; -- Some view models are incorrectly flipped.
SWEP.UseHands = true;

SWEP.ViewModel			= "models/weapons/v_remingt.mdl"
SWEP.WorldModel			= "models/weapons/w_remingt.mdl"

SWEP.DrawAmmo = true; -- Draw our own ammo display?
SWEP.DrawCrosshair = false; -- Draw the crosshair, or draw our own?

SWEP.Weight	= 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom	= false;

--[[ Set the SWEP's primary fire information. --]]

SWEP.Primary.DefaultClip = 2;
SWEP.Primary.ClipSize = 2;
SWEP.Primary.Automatic = false;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Damage	= 40;
SWEP.Primary.Recoil	= 1;
SWEP.Primary.Sound		= Sound("weapons/shotgun/gunfire/shotgun_fire_1.wav")
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "buckshot";
SWEP.Primary.Cone = 0.01;

--[[ Set the SWEP's primary fire information. --]]

SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.ClipSize	= -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

--[[ Define the bullet information for later use. --]]

SWEP.BulletTracerFreq = 1; -- Show a tracer every x bullets.
SWEP.BulletTracerName = nil -- Use a custom effect for the tracer.
SWEP.BulletForce = 5;

--[[ Set up the ironsight's position and angles. --]]

SWEP.IronSightsPos = Vector(-5.52, -2.063, 3.194)
SWEP.IronSightsAng = Vector(0, 0, 0)

--[[ Set up the accuracy for the weapon. --]]

SWEP.CrouchCone				= 0.01 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.02 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.015 -- Accuracy when we're standing still

	/**************************
		Inner Workings
	**************************/

--[[ These are the more deeper parts of the SWEP. It's suggested you DO NOT edit these. --]]
--[[ The only reason you should ever edit these is if you know what you're doing or if you'd like to change how long it takes to load a shell. --]]
--[[ The shell loading time is on line 181, and is set as 0.4 by default. The higher the number the longer it takes and etc.]]

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
		Regular Reload
	**************************/

function SWEP:Reload()
	//if ( CLIENT ) then return end
	
	// Already reloading
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then return end
	
	// Start reloading if we can
	if ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

		if (game.SinglePlayer() ) then
		timer.Simple( 0.5, function()
		self.Weapon:SetNetworkedBool( "reloading", true )
		self.Weapon:SetVar( "reloadtimer", CurTime())
		end)
		else
		self.Weapon:SetNetworkedBool( "reloading", true )
		end
		
	end
end

	/**************************
		Shotgun Reload
	**************************/

	function SWEP:ShotgunReload()
		
		if self.Owner:KeyPressed(IN_ATTACK) then 
			self.Weapon:SetNetworkedBool( "reloading", false )
		end
	
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then
	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime()) then
			
			//  reload 
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end
			
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 )
			if not ( self.Weapon:Clip1() == self.Primary.ClipSize) then 
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			end
			
			// Add ammo
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
			// Finish filling, final pump. Current Clip is = to ClipSize or No more ammo in the reserve
			if ( self.Weapon:Clip1() == self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
				timer.Simple( 0.5, function() 
					if self.Weapon == nil then return end
					self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
					self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
			end ) 
			
		end
	end
end
end

	/**************************
		Think!
	**************************/

function SWEP:Think()
		self:ShotgunReload()

	if ( self.Weapon:GetNetworkedBool( "reloading", true ) ) then
	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime() ) then
			
			// Finished reload -
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end
			
			// Next cycle
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.5 )
			local vm = self.Owner:GetViewModel()
			
			// Add ammo
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self:EmitSound(Sound("weapons/m3/m3_insertshell.wav"))
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
			// Finish filling, final pump
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "reload_end" ) )
			else
			
			end
			
		end
	
	end
	
end