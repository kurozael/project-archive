--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "USP-T";
ITEM.cost = 1700;
ITEM.model = "models/weapons/w_pist_usp.mdl";
ITEM.weight = 1.5
ITEM.business = true;
ITEM.weaponClass = "rcs_usp";
ITEM.description = "A light grey pistol with a suppressor.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.schema:RegisterLeveledWeapon(ITEM);