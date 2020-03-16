--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Sledgehammer";
ITEM.cost = 400;
ITEM.model = "models/weapons/w_sledgehammer.mdl";
ITEM.weight = 2;
ITEM.business = true;
ITEM.category = "Melee";
ITEM.weaponClass = "aura_sledgehammer";
ITEM.description = "A long and brutal sledgehammer with a bloody tip.";
ITEM.meleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 255, 0);
ITEM.attachmentOffsetVector = Vector(5, 5, -8);

openAura.schema:RegisterLeveledWeapon(ITEM);