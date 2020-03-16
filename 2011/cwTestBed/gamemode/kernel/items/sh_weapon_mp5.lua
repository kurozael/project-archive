--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "MP5";
ITEM.cost = 3000;
ITEM.model = "models/weapons/w_smg_mp5.mdl";
ITEM.weight = 2.5;
ITEM.business = true;
ITEM.weaponClass = "rcs_mp5";
ITEM.description = "A compact sub-machine firearm a dirty exterior.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

Clockwork.item:Register(ITEM);