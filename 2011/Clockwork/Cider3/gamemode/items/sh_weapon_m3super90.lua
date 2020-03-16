--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "M3 Super 90";
	ITEM.cost = 1600;
	ITEM.model = "models/weapons/w_shot_m3super90.mdl";
	ITEM.weight = 4;
	ITEM.classes = {CLASS_BLACKMARKET};
	ITEM.business = true;
	ITEM.uniqueID = "weapon_m3super90";
	ITEM.weaponClass = "rcs_m3";
	ITEM.description = "A moderately sized firearm coated in a dull grey.\nThis firearm utilises buckshot ammunition.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);