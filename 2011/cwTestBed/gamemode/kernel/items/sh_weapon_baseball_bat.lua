--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "Baseball Bat";
ITEM.cost = 200;
ITEM.model = "models/weapons/w_basball.mdl";
ITEM.weight = 1;
ITEM.business = true;
ITEM.category = "Weapons";
ITEM.weaponClass = "cw_baseballbat";
ITEM.description = "A fairly large baseball bat. It isn't shiny anymore.";
ITEM.isMeleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(90, 180, 20);
ITEM.attachmentOffsetVector = Vector(0, 7, 0);

Clockwork.item:Register(ITEM);