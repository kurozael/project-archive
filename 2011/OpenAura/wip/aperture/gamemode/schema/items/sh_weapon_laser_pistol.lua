--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "LPX-210";
ITEM.cost = 3400;
ITEM.model = "models/weapons/w_pist_p228.mdl";
ITEM.weight = 1.5;
ITEM.business = true;
ITEM.weaponClass = "aura_laserpistol";
ITEM.description = "A small and accurate handgun using laser technology.\nThis firearm utilises X36-9mm ammunition.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.schema:RegisterLeveledWeapon(ITEM);