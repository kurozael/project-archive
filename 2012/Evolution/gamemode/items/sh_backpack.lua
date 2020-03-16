--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Backpack";
ITEM.cost = (400 * 0.5);
ITEM.batch = 1;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 1;
ITEM.useText = "Unpack";
ITEM.business = true;
ITEM.category = "Equipment";
ITEM.description = "An small personal backpack which can hold minimal items.";
ITEM.isRareItem = false;
ITEM.extraInvKG = 4;
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine2";
ITEM.attachmentModel = "models/fallout 3/backpack_1.mdl";
ITEM.attachmentModelScale = Vector(1.3, 1.3, 1.3);
ITEM.attachmentOffsetAngles = Angle(0, 274, 100);
ITEM.attachmentOffsetVector = Vector(-2, 2, -8);

--[[ Define the possible backpack upgrades here. --]]
local BACKPACK_UPGRADES = {
	"models/fallout 3/backpack_1.mdl",
	"models/fallout 3/backpack_2.mdl",
	"models/fallout 3/backpack_3.mdl",
	"models/fallout 3/backpack_4.mdl",
	"models/fallout 3/backpack_5.mdl",
	"models/fallout 3/backpack_6.mdl"
};

--[[ The level defines which model the backpack has. --]]
ITEM:AddData("Level", 1, true);
ITEM:AddData("IsUnpacked", false, true);

-- Called when the item's attachment model is queried.
function ITEM:OnQueryAttachmentModel()
	return BACKPACK_UPGRADES[self:GetData("Level")];
end;

ITEM:AddQueryProxy("attachmentModel", ITEM.OnQueryAttachmentModel);

-- Called when the item's extra weight is queried.
function ITEM:OnQueryExtraWeight()
	return self.extraInvKG + (4 * (self:GetData("Level") - 1));
end;

ITEM:AddQueryProxy("extraInvKG", ITEM.OnQueryExtraWeight);

-- Called when the item's extra inventory is queried.
function ITEM:OnQueryExtraInventory()
	if (self:GetData("IsUnpacked")) then
		return self("extraInvKG");
	end;
end;

ITEM:AddQueryProxy("addInvSpace", ITEM.OnQueryExtraInventory);

-- Called when the item's use text is queried.
function ITEM:OnQueryUseText()
	if (self:GetData("IsUnpacked")) then
		return "Pack";
	end;
end;

ITEM:AddQueryProxy("useText", ITEM.OnQueryUseText);

-- Called when the item's rarity level is queried.
function ITEM:OnQueryRarityLevel()
	if (self:GetData("IsUnpacked")) then
		return true;
	end;
end;

ITEM:AddQueryProxy("isRareItem", ITEM.OnQueryRarityLevel);

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	if (self:GetData("IsUnpacked")) then return true; end;
end;

-- Called when a player attempts to take the item from storage.
function ITEM:CanTakeStorage(player, storageTable)
	local extraInvKG = self("extraInvKG");
	local target = Clockwork.entity:GetPlayer(storageTable.entity);
	
	if (IsValid(target) and self:GetData("IsUnpacked")
	and target:GetInventoryWeight() > (target:GetMaxWeight() - extraInvKG)) then
		return false;
	end;
end;

-- Called when the item is given to a player.
function ITEM:OnGiveToPlayer(player)
	self:SetData("IsUnpacked", false);
end;

-- Called when the item is taken from a player.
function ITEM:OnTakeFromPlayer(player)
	self:SetData("IsUnpacked", false);
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	return self:GetData("IsUnpacked");
end;

-- Called when the item's network data is updated.
function ITEM:OnNetworkDataUpdated(newData)
	if (newData["IsUnpacked"] != nil) then
		Clockwork.inventory:Rebuild();
	end;
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	if (self:GetData("IsUnpacked")) then
		local extraInvKG = self("extraInvKG");
		local maxWeight = player:GetMaxWeight() - extraInvKG;
		
		if (self:GetData("IsUnpacked")
		and player:GetInventoryWeight() > maxWeight) then
			Clockwork.player:Notify(player, "You cannot pack this while you are carrying items in it!");
			return false;
		end;
		
		self:SetData("IsUnpacked", false);
		return true;
	end;
end;

-- Called when a player's gear should be restored for the item.
function ITEM:OnRestorePlayerGear(player)
	if (self:GetData("IsUnpacked")) then
		Clockwork.player:CreateGear(player, "Backpack", self, true);
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self:GetData("IsUnpacked")) then
		return self:OnPlayerUnequipped(player);
	end;
	
	local itemsList = player:GetItemsByID(self("uniqueID"));
	if (!itemsList) then return false; end;
	
	for k, v in pairs(itemsList) do
		if (v:GetData("IsUnpacked")) then
			Clockwork.player:Notify(
				player, "You cannot have another unpacked "..string.lower(self("name")).."!"
			);
			return false;
		end;
	end;
	
	Clockwork.player:CreateGear(
		player, "Backpack", self, true
	);
	
	self:SetData("IsUnpacked", true);
	return true;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	local extraInvKG = self("extraInvKG");
	local maxWeight = player:GetMaxWeight() - extraInvKG;
	
	if (self:GetData("IsUnpacked") and player:GetInventoryWeight() > maxWeight) then
		Clockwork.player:Notify(player, "You cannot drop this while you are carrying items in it!");
		return false;
	end;
end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clientSideInfo = "";
		local extraInvKG = self("extraInvKG");
		local itemLevel = self:GetData("Level");
		
		clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Extra Weight: "..extraInvKG.."kg");
		
		if (self:GetData("IsUnpacked")) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Unpacked: Yes");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Unpacked: No");
		end;
		
		if (self:IsInstance()) then
			local levelColor = Color((255 / 6) * (6 - itemLevel), (255 / 6) * itemLevel, 0, 255);
			clientSideInfo = Clockwork:AddMarkupLine(
				clientSideInfo, "Level: "..self:GetData("Level"), levelColor
			);
		end;
		
		return (clientSideInfo != "" and clientSideInfo);
	end
end;

Clockwork.item:Register(ITEM);