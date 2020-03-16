--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Scout";
ITEM.cost = 1700;
ITEM.model = "models/weapons/w_snip_scout.mdl";
ITEM.weight = 4;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.uniqueID = "weapon_scout";
ITEM.weaponClass = "rcs_scout";
ITEM.description = "A long and grey rusted sniper rifle.\nThis firearm utilises 7.65x59mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);