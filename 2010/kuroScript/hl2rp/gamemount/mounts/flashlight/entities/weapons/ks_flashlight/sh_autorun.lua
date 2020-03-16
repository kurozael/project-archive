--[[
Name: "sh_autorun.lua".
Product: "Terminator RP".
--]]

if (SERVER) then
	AddCSLuaFile("sh_autorun.lua");
	
	-- Set some information.
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

-- Check if a statement is true.
if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 6;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Flashlight";
	SWEP.DrawCrosshair = true;
end

-- Set some information.
SWEP.Instructions = "Primary Fire: Toggle.";
SWEP.Contact = "";
SWEP.Purpose = "Illuminating dark areas.";
SWEP.Author	= "kuromeku";

-- Set some information.
SWEP.WorldModel = "models/weapons/w_fists_t.mdl";
SWEP.ViewModel = "models/weapons/v_punch.mdl";
SWEP.HoldType = "fist";

-- Set some information.
SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
-- Set some information.
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Ammo = "";

-- Set some information.
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Ammo	= "";

-- Set some information.
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.LoweredAngles = Angle(60, 60, 60);
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NeverRaised = true;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	if (SERVER) then
		if ( self.Owner:FlashlightIsOn() ) then
			self.Owner:Flashlight(false);
		else
			self.Owner:Flashlight(true);
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;