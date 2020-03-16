if (SERVER) then

	AddCSLuaFile( "shared.lua" );

end

if (CLIENT) then

--[[ Basic SWEP Information to display to the client. ]]--

	SWEP.PrintName			= "Scout"			
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

SWEP.HoldType			= "ar2"
SWEP.Base				= "bs_sniper_base"
SWEP.Category			= "Backsword"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false; -- Some view models are incorrectly flipped.
SWEP.UseHands = true;

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_scout.mdl"

SWEP.DrawAmmo = true; -- Draw our own ammo display?
SWEP.DrawCrosshair = false; -- Draw the crosshair, or draw our own?

--[[ These really aren't important. Keep them at false, and the weight at five. --]]

SWEP.Weight	= 5
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom	= false;

--[[ Set the SWEP's primary fire information. --]]

SWEP.Primary.DefaultClip = 8;
SWEP.Primary.ClipSize = 8;
SWEP.Primary.Automatic = false;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Damage	= 22;
SWEP.Primary.Recoil	= 0.50;
SWEP.Primary.Sound	= Sound("weapons/hunting_rifle/gunfire/hunting_rifle_fire_1.wav")
SWEP.ReloadHolster	= 0.1

SWEP.Primary.Delay = 1.3; -- Make sure we keep this at 1.3 so the bolt animation can play! (If it's a bolt action rifle, of course.)
SWEP.Primary.Ammo = "ar2";
SWEP.Primary.Cone = 0.0001;

--[[ Basic Scope Options. ]]--

SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.ScopeScale 			= 0.55 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZoom				= 6 -- How much is the zoom on the scope?
SWEP.IronsightTime 			= 0.35 -- How long does it take to zoom in?
SWEP.BoltAction				= true

--Only Select one... Only one.
SWEP.Scope1			= true
SWEP.Scope2			= false
SWEP.Scope3			= false
SWEP.Scope4			= false
SWEP.Scope5			= false
SWEP.Scope6			= false

--[[ Set the SWEP's secondary fire information. --]]

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 100
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "smg2"

--[[ Define the bullet information for later use. --]]

SWEP.BulletTracerFreq = 1; -- Show a tracer every x bullets.
SWEP.BulletTracerName = nil -- Use a custom effect for the tracer.
SWEP.BulletForce = 5;

--[[ Set up the accuracy for the weapon. --]]

SWEP.CrouchCone				= 0.001 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.009 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.015 -- Accuracy when we're standing still