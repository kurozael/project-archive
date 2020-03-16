--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 250;
ITEM.name = "Chinese Pistol";
ITEM.model = "models/weapons/w_pist_fiveseven.mdl";
ITEM.batch = 1;
ITEM.weight = 1.5;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_57";
ITEM.description = "A small pistol with a large magazine.\nThis firearm utilises 5.7x28mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.item:Register(ITEM);