--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 775;
ITEM.name = "Sniper Rifle";
ITEM.model = "models/weapons/w_snip_awp.mdl";
ITEM.batch = 1;
ITEM.weight = 4;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_awp";
ITEM.description = "A rusted sniper rifle with a green tint.\nThis firearm utilises 7.65x59mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);