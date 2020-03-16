--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 150;
ITEM.name = "Katana";
ITEM.model = "models/weapons/w_katana.mdl";
ITEM.batch = 1;
ITEM.weight = 1.25;
ITEM.access = "T";
ITEM.business = true;
ITEM.category = "Melee";
ITEM.weaponClass = "aura_katana";
ITEM.description = "A katana made by the Japanese that can dice up anything.";
ITEM.meleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(90, 180, 20);
ITEM.attachmentOffsetVector = Vector(0, 6, 0);

openAura.item:Register(ITEM);