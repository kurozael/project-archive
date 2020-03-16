--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "M4A1";
	ITEM.cost = 1400;
	ITEM.model = "models/weapons/w_rif_m4a1.mdl";
	ITEM.weight = 3;
	ITEM.classes = {CLASS_BLACKMARKET};
	ITEM.business = true;
	ITEM.uniqueID = "weapon_m4a1";
	ITEM.weaponClass = "rcs_m4a1";
	ITEM.description = "A smooth black firearm with a shiny tint.\nThis firearm utilises 5.56x45mm ammunition.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);