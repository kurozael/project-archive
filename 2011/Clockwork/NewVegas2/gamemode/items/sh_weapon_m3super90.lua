--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.cost = 575;
	ITEM.name = "Combat Shotgun";
	ITEM.model = "models/weapons/w_shot_m3super90.mdl";
	ITEM.batch = 1;
	ITEM.weight = 4;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.weaponClass = "rcs_m3";
	ITEM.description = "A moderately sized firearm coated in a dull grey.\nThis firearm utilises buckshot ammunition.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);