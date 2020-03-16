--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.cost = 130;
	ITEM.name = "Sledgehammer";
	ITEM.model = "models/weapons/w_sledgehammer.mdl";
	ITEM.batch = 1;
	ITEM.weight = 1.5;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.category = "Melee";
	ITEM.weaponClass = "cw_sledgehammer";
	ITEM.description = "This beast can tear through anything.";
	ITEM.isMeleeWeapon = true;
	ITEM.isAttachment = true;
	ITEM.loweredOrigin = Vector(-12, 2, 0);
	ITEM.loweredAngles = Angle(-25, 15, -80);
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 255, 0);
	ITEM.attachmentOffsetVector = Vector(5, 5, -8);
Clockwork.item:Register(ITEM);