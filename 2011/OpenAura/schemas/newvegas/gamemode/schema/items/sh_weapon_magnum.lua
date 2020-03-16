--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 375;
ITEM.name = ".32 Pistol";
ITEM.model = "models/weapons/w_357.mdl";
ITEM.batch = 1;
ITEM.weight = 1.5;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_magnum";
ITEM.description = "An extremely powerful silver pistol.\nThis firearm utilises .357 ammunition.";
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.item:Register(ITEM);