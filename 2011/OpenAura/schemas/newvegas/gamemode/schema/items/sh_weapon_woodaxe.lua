--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 90;
ITEM.name = "Woodaxe";
ITEM.model = "models/weapons/w_axe.mdl";
ITEM.batch = 1;
ITEM.weight = 0.9;
ITEM.access = "T";
ITEM.business = true;
ITEM.category = "Melee";
ITEM.weaponClass = "aura_woodaxe";
ITEM.description = "An old unreliable wooden axe - it could do some damage.";
ITEM.meleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 255, 0);
ITEM.attachmentOffsetVector = Vector(5, 5, -8);

openAura.item:Register(ITEM);