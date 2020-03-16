--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "FiveSeven";
ITEM.cost = 500;
ITEM.model = "models/weapons/w_pist_fiveseven.mdl";
ITEM.weight = 1.5;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.uniqueID = "weapon_fiveseven";
ITEM.weaponClass = "rcs_57";
ITEM.description = "A small pistol with a large magazine.\nThis firearm utilises 5.7x28mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.item:Register(ITEM);