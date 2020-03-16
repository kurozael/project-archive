--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.cost = 60;
	ITEM.name = "Baseball Bat";
	ITEM.model = "models/weapons/w_basball.mdl";
	ITEM.batch = 1;
	ITEM.weight = 0.75;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.category = "Melee";
	ITEM.description = "A fairly large baseball bat. It isn't shiny anymore.";
	ITEM.weaponClass = "cw_baseballbat";
	ITEM.isMeleeWeapon = true;
	ITEM.isAttachment = true;
	ITEM.loweredOrigin = Vector(-12, 2, 0);
	ITEM.loweredAngles = Angle(-25, 15, -80);
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(90, 180, 20);
	ITEM.attachmentOffsetVector = Vector(0, 6, 0);
Clockwork.item:Register(ITEM);