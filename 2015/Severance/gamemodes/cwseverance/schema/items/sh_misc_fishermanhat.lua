--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Fisherman's Hat";
ITEM.cost = 150;
ITEM.model = "models/bloocobalt/clothes/fisherman_cap.mdl";
ITEM.weight = 1;
ITEM.useText = "Wear";
ITEM.category = "Clothing";
ITEM.business = true;
ITEM.description = "A very nice hat.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Head";
ITEM.attachmentModel = "models/bloocobalt/clothes/fisherman_cap.mdl";
ITEM.attachmentOffsetAngles = Angle(0, 270, 90);
ITEM.attachmentOffsetVector = Vector(0, -3, -56);

-- Called when the attachment model scale is needed.
function ITEM:GetAttachmentModelScale(player, entity)
	if (string.find(player:GetModel(), "female")) then
		return Vector() * 0.9;
	end;
end;

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if (string.find(player:GetModel(), "female")) then
		info.offsetVector = Vector(0, -1.5, -52);
		info.offsetAngle = Angle(10, 270, 80);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();