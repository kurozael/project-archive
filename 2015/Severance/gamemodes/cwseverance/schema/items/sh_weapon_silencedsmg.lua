--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Silenced Smg";
	ITEM.model = "models/weapons/cstrike/c_smg_tmp.mdl";
	ITEM.weight = 2.5;
	ITEM.uniqueID = "weapon_silsmg";
	ITEM.weaponClass = "bs_silencedsmg";
	ITEM.description = "A compact sub-machine weapon a dirty exterior.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = false;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);