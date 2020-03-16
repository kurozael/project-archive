--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Kevlar Vest";
ITEM.cost = (200 * 0.5);
ITEM.batch = 3;
ITEM.model = "models/weapons/w_suitcase_passenger.mdl";
ITEM.weight = 1;
ITEM.useText = "Wear";
ITEM.category = "Equipment";
ITEM.business = true;
ITEM.description = "A kevlar vest that provides you with light bodyarmor.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine2";
ITEM.attachmentModel = "models/kevlarvest/kevlarvest.mdl";
ITEM.attachmentOffsetAngles = Angle(0, 270, 90);
ITEM.attachmentOffsetVector = Vector(0, -3, -56);

--[[ The amount of armor each kevlar starts with. --]]
ITEM:AddData("Armor", 200, true);
ITEM:AddData("IsEquipped", false, true);

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	local model = player:GetModel();
	
	if (string.find(model, "group%d%d") or string.find(model, "tactical_rebel")) then
		if (player:Armor() > 0) then
			return true;
		end;
	end;
end;

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

-- Called when the item is given to a player.
function ITEM:OnGiveToPlayer(player)
	self:SetData("IsEquipped", false);
end;

-- Called when the item is taken from a player.
function ITEM:OnTakeFromPlayer(player)
	self:SetData("IsEquipped", false);
end;

-- Called when a player's gear should be restored for the item.
function ITEM:OnRestorePlayerGear(player)
	if (self:GetData("IsEquipped")) then
		Clockwork.player:CreateGear(player, "KevlarVest", self, true);
		player:SetMaxArmor(200);
		player:SetArmor(self:GetData("Armor"));
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	return self:GetData("IsEquipped");
end;

-- Called when the item's network data is updated.
function ITEM:OnNetworkDataUpdated(newData)
	if (newData["IsEquipped"] != nil) then
		Clockwork.inventory:Rebuild();
	end;
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	if (self:GetData("IsEquipped")) then
		self:SetData("IsEquipped", false);
		player:SetArmor(0);
		return true;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local itemsList = player:GetItemsByID(self("uniqueID"));
	
	if (itemsList) then
		for k, v in pairs(itemsList) do
			v:SetData("IsEquipped", false);
		end;
	end;
	
	if (self:GetData("Armor") == 0) then
		return;
	end;
	
	Clockwork.player:CreateGear(player, "KevlarVest", self, true);
		player:SetMaxArmor(200);
		player:SetArmor(self:GetData("Armor"));
	self:SetData("IsEquipped", true);
	
	return true;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clientSideInfo = "";
		local itemArmor = self:GetData("Armor");
		
		if (self:GetData("IsEquipped")) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Equipped: Yes");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Equipped: No");
		end;
		
		local armorColor = Color((255 / 200) * (200 - itemArmor), (255 / 200) * itemArmor, 0, 255);
		clientSideInfo = Clockwork:AddMarkupLine(
			clientSideInfo, "Armor: "..(itemArmor / 2).."%", armorColor
		);
		
		return (clientSideInfo != "" and clientSideInfo);
	end
end;

Clockwork.item:Register(ITEM);