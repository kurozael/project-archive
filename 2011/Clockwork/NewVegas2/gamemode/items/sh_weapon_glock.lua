--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.cost = 200;
	ITEM.name = "Glock";
	ITEM.model = "models/weapons/w_pist_glock18.mdl";
	ITEM.batch = 1;
	ITEM.weight = 1.5;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.weaponClass = "rcs_glock";
	ITEM.description = "A dirty pistol with a plastic coating.\nThis firearm utilises 9x19mm ammunition.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
	ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);
Clockwork.item:Register(ITEM);