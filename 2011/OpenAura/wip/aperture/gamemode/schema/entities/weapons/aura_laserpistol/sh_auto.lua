--REAL CS BASE
--sorry for no comments to show what everything does im too lazy to do it LOL!

if (SERVER) then

	AddCSLuaFile( "sh_auto.lua" )
	SWEP.Weight				= 5


end

if ( CLIENT ) then
	SWEP.PrintName			= "LPX-210"	
	SWEP.Author				= "kurozael"
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "a"
	SWEP.Slot				= 1
	SWEP.NameOfSWEP			= "aura_laserpistol" --always make this the name of the folder the SWEP is in.
	killicon.AddFont( SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_pistol"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.Tracer = 1;
SWEP.ViewModel				= "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_p228.mdl"
	SWEP.HoldType			= "pistol"
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.TracerName = "aura_LaserTracer"

SWEP.Primary.Sound			= "weapons/fx/nearmiss/bulletltor04.wav"
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 32
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 13
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 65
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "ar2altfire"

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.MoveSpread				= 6 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (4.7567, 0, 2.8329)
SWEP.IronSightsAng = Vector (0, 0, 0)

-- if (CLIENT) then
	-- function SWEP:DoCustomHitEffects(trace)
		-- local effectData = EffectData();
		
		-- effectData:SetStart(trace.HitPos);
		-- effectData:SetOrigin(trace.HitPos);
		-- effectData:SetScale(1);
		
		-- util.Effect("MetalSparks", effectData);
	-- end
-- end