--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "MP5";
	ITEM.cost = 900;
	ITEM.model = "models/weapons/w_smg_mp5.mdl";
	ITEM.weight = 2.5;
	ITEM.classes = {CLASS_BLACKMARKET, CLASS_DISPENSER};
	ITEM.business = true;
	ITEM.uniqueID = "weapon_mp5";
	ITEM.weaponClass = "rcs_mp5";
	ITEM.description = "A compact sub-machine firearm a dirty exterior.\nThis firearm utilises 9x19mm ammunition.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);