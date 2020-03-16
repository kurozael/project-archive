--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Light Kevlar";
ITEM.cost = 50;
ITEM.model = "models/weapons/w_suitcase_passenger.mdl";
ITEM.weight = 1;
ITEM.useText = "Wear";
ITEM.category = "Clothing";
ITEM.business = true;
ITEM.uniqueID = "kevlar_vest";
ITEM.description = "A kevlar vest that provides you with light bodyarmor.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine2";
ITEM.attachmentModel = "models/kevlarvest/kevlarlite.mdl";
ITEM.attachmentOffsetAngles = Angle(0, 270, 90);
ITEM.attachmentOffsetVector = Vector(0, -3, -56);

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	local model = player:GetModel();
	
	if ( string.find(model, "group%d%d") or string.find(model, "tactical_rebel")
	or string.find(model, "male_experim") ) then
		if (player:Armor() > 0) then
			return true;
		end;
	end;
end;

-- Called when the attachment model scale is needed.
function ITEM:GetAttachmentModelScale(player, entity)
	if ( string.find(player:GetModel(), "female") ) then
		return Vector() * 0.9;
	end;
end;

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if ( string.find(player:GetModel(), "female") ) then
		info.offsetVector = Vector(0, -1.5, -52);
		info.offsetAngle = Angle(10, 270, 80);
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	openAura.player:CreateGear(player, "KevlarVest", self);
	
	if ( openAura.augments:Has(player, AUG_ARMORED) ) then
		player:SetArmor(100);
	else
		player:SetArmor(50);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);