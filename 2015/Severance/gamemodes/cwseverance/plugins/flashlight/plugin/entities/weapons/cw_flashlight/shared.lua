--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	
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

--Client side information, author etc.
if ( CLIENT ) then
	SWEP.PrintName			= "Flashlight"
	SWEP.Author 			= "Zig"
	SWEP.Purpose 			= "A simplistic flashlight made for iluminating areas."

	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV		= 50
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	--Slots are irrelevant in Clockwork and are seriously useless with CLockwork's scrolling selection system.
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter		= ""

end

--Misc SWEP content, these don't really matter except for the hold type, which still sorta doesn't matter because there's no world model.
SWEP.Category			= "Backsword"
SWEP.HoldType			= "fist"

--Are we able to spawn this weapon in the entity menu?
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

--View model information, SWEP.UseHands is vital, it allows the c_models to give you hands!
SWEP.ViewModel 				= "models/weapons/c_flashlight_zm.mdl"
SWEP.WorldModel 			= "" 
SWEP.UseHands				= true

--Primary fire ammo information.
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Damage			= 0
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			=""
SWEP.DrawAmmo 				= false

--Secondary fire ammo information.
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Damage		= 100
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo	= "";

--Called when the player deploys the weapon.
/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ) )
end

-- Called when the player attempts to fire.
/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

		if (SERVER) then
		if (self.Owner:FlashlightIsOn()) then
			self.Owner:Flashlight(false);
		else
			self.Owner:Flashlight(true);
		end;
	end;
end;

-- Called when the layer attempts to alternate fire.
/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack() 
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/
function SWEP:Holster( wep )
	if ( SERVER ) then
		SafeRemoveEntity ( self.projectedlight )
		if IsValid( self.projectedlight ) then
			self.projectedlight:Fire("kill")
		end
	end
	self.Active = false
	--self.projectedlight = nil
return true
end