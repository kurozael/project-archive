--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Laser Pistol";
	ITEM.cost = 400;
	ITEM.model = "models/weapons/w_pist_p228.mdl";
	ITEM.batch = 1;
	ITEM.weight = 1.5;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.weaponClass = "cw_laserpistol";
	ITEM.description = "A small and accurate handgun using laser technology.\nThis firearm utilises Energy ammunition.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
	ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);
Clockwork.item:Register(ITEM);