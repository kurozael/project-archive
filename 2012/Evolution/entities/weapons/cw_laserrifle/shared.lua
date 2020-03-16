--REAL famas!!
--actually has comments!!!

--lines with two dashes (-) in front of them have no effect on the code at all whatsoever


if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if (CLIENT) then
	SWEP.PrintName			= "Laser Rifle"	
	SWEP.Author				= "kurozael"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= true
	SWEP.NameOfSWEP			= "cw_laserrifle" --always make this the name of the folder the SWEP is in.
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "t"
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS" --duh
SWEP.Base					= "rcs_base"
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
	SWEP.HoldType			= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_famas.mdl" --duh
SWEP.WorldModel				= "models/weapons/w_rif_famas.mdl" --duh

SWEP.Weight					= 5 --dont change this
SWEP.AutoSwitchTo			= false --no
SWEP.AutoSwitchFrom			= false --no

SWEP.delaytime				= 0.5
SWEP.Primary.Sound			= Sound("weapons/LaserPistol_Fire.wav")
SWEP.Primary.EmptyWepSound	= Sound("weapons/LaserPistol_NoAmmo.wav")
SWEP.Primary.Recoil			= 0.2 --pushback on shooting, fucking annoying as hell, leave as is
SWEP.Primary.Damage			= 38 --duh
SWEP.Primary.NumShots		= 1 --durr, set to something higher if you want a shotty or soemthing
SWEP.Primary.Cone			= 0.0004 --spread of bullets, set higher if you want inaccurate, set to 0 if you want it dead center
SWEP.Primary.ClipSize		= 30 --duh
SWEP.Primary.Delay			= 0.12 --delay between shots
SWEP.Primary.DefaultClip	= 0 --extra ammo
SWEP.Primary.MaxReserve		= 75
SWEP.Primary.Automatic		= true --set to false for shotguns and pistols
SWEP.Primary.Ammo			= "ar2altfire" --leave as is
SWEP.PistolBurst			= false
SWEP.Tracer = 1;
SWEP.TracerName = "cw_lasertracer"
SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.MoveSpread				= 4 --multiplier for spread when you are moving
SWEP.JumpSpread				= 7 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.7 --multiplier for spread when you are crouching
SWEP.delaytime				= 0.5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (-4.6856, 0, 1.144)
SWEP.IronSightsAng = Vector (0, 0, -1.2628)

function SWEP:DoImpactEffect( tr, dmgtype )

    // having the impact effect on the sky looks strange, ditch it
    if( tr.Hit && !tr.HitSky ) then
    
        local effect = EffectData();
            effect:SetOrigin( tr.HitPos );
            effect:SetNormal( tr.HitNormal );
        util.Effect( "cw_laserimpact", effect );
        
    end

    return true;

end

function SWEP:OnMuzzleFlash()
    local effect = EffectData();
        effect:SetOrigin( self.Owner:GetShootPos() );
        effect:SetEntity( self.Weapon );
        effect:SetAttachment( 1 );
    util.Effect( "cw_lasermuzzle", effect );
end

function SWEP:GetTracerOrigin()

	local pos, ang = Clockwork.entity:GetMuzzlePos( self );
	return pos;

end