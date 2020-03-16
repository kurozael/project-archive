--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (SERVER) then
 AddCSLuaFile("sh_auto.lua");
 
 SWEP.Weight = 5;

end;

if (CLIENT) then
 SWEP.ViewModelFlip = false;
 SWEP.NameOfSWEP = "rcs_remington";
 SWEP.IconLetter = "k";
 SWEP.PrintName = "Remington .870";
 SWEP.SlotPos = 2;
 SWEP.Author = "kurozael";

 killicon.AddFont( SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) );
end;

SWEP.PlayReloadSounds = true;
SWEP.AdminSpawnable = true;
SWEP.AutoSwitchFrom = false;
SWEP.ViewModelFOV = 60;
SWEP.AutoSwitchTo = false;
SWEP.DefaultVFOV = 60;
SWEP.Penetrating = true;
SWEP.ViewModel = "models/weapons/v_remingt.mdl";
SWEP.IsShotgun = true;
SWEP.Spawnable = true;
SWEP.HoldType = "ar2";
SWEP.WorldModel = "models/weapons/w_remingt.mdl";
SWEP.Category = "RealCS";
SWEP.Weight = 5;
SWEP.Base = "rcs_base_shotgun";

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.MaxReserve = 24;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = 2;
SWEP.Primary.NumShots = 4;
SWEP.Primary.Recoil = 0.4;
SWEP.Primary.Damage = 40;
SWEP.Primary.Sound = Sound("Weapon_M3.Single");
SWEP.Primary.Delay = 0.95;
SWEP.Primary.Cone = 0.03;
SWEP.Primary.Ammo = "buckshot";
SWEP.EjectDelay = 0.53;

SWEP.Primary.SpreadIncrease = 0.21 / 15;
SWEP.Primary.MaxSpread = 0.03;
SWEP.Primary.Handle = 0.5;

SWEP.CrouchSpread = 1;
SWEP.MoveSpread = 1;
SWEP.JumpSpread = 3;

SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector (-5.5645, -6.0997, 3.2753)
SWEP.IronSightsAng = Vector (0, 0, 0)