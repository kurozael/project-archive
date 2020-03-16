--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 475;
ITEM.name = "10mm SMG";
ITEM.model = "models/weapons/w_smg_mp5.mdl";
ITEM.batch = 1;
ITEM.weight = 2.5;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_mp5";
ITEM.description = "A compact sub-machine firearm a dirty exterior.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);