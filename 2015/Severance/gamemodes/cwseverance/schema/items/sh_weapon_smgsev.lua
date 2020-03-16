--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "UZI";
	ITEM.model = "models/weapons/w_smg_mac10.mdl";
	ITEM.weight = 1.5;
	ITEM.uniqueID = "weapon_mac10";
	ITEM.weaponClass = "bs_mac10";
	ITEM.description = "A dirty grey weapon with something engraved into the side.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
	ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);
Clockwork.item:Register(ITEM);