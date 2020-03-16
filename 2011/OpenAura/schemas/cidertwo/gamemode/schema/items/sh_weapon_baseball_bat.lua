--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Baseball Bat";
ITEM.cost = 100;
ITEM.model = "models/weapons/w_basball.mdl";
ITEM.weight = 1;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.uniqueID = "aura_baseballbat";
ITEM.business = true;
ITEM.category = "Melee"
ITEM.description = "A fairly large baseball bat. It isn't shiny anymore.";
ITEM.meleeWeapon = true;
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(90, 180, 20);
ITEM.attachmentOffsetVector = Vector(0, 7, 0);

openAura.item:Register(ITEM);