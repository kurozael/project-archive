--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "AK-47";
	ITEM.cost = 1500;
	ITEM.model = "models/weapons/w_rif_ak47.mdl";
	ITEM.weight = 3;
	ITEM.classes = {CLASS_BLACKMARKET};
	ITEM.business = true;
	ITEM.uniqueID = "weapon_ak47";
	ITEM.weaponClass = "rcs_ak47";
	ITEM.description = "A rusted grey and brown rifle.\nThis firearm utilises 5.56x45mm ammunition.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);