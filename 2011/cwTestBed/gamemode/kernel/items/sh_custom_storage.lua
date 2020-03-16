--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Custom Storage";
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 0.25;
ITEM.useText = "Open";
ITEM.category = "Storage";
ITEM.business = true;
ITEM.isRareItem = false;
ITEM.extraWeight = 0;
ITEM.description = "Just your average storage container.";
ITEM.extraInventory = 0;

ITEM:AddData("Name", "", true);
ITEM:AddData("Desc", "", true);
ITEM:AddData("Found", false);
ITEM:AddData("Rarity", 0, true);
ITEM:AddData("Weight", -1, true);
ITEM:AddData("IsUnpacked", false, true);

ITEM:AddQueryProxy("description", "Desc", true);
ITEM:AddQueryProxy("extraWeight", "Weight", true);
ITEM:AddQueryProxy("name", "Name", true);

-- A function to get the item's rarity color.
function ITEM:GetRarityColor()
	if (self:GetData("Rarity") == 1) then
		return Color(73, 184, 255, 255);
	elseif (self:GetData("Rarity") == 2) then
		return Color(255, 85, 85, 255);
	elseif (self:GetData("Rarity") == 3) then
		return Color(255, 206, 73, 255);
	end;
end;

ITEM:AddQueryProxy("color", ITEM.GetRarityColor);

ITEM:AddQueryProxy("model", function(itemTable)
	if (itemTable:GetData("IsUnpacked")) then
		return "models/props_junk/garbage_bag001a.mdl";
	end;
end);

ITEM:AddQueryProxy("useText", function(itemTable)
	if (itemTable:GetData("IsUnpacked")) then
		return "Pack";
	end;
end);

ITEM:AddQueryProxy("isRareItem", function(itemTable)
	if (itemTable:GetData("IsUnpacked")) then
		return true;
	end;
end);

ITEM:AddQueryProxy("extraInventory", function(itemTable)
	if (itemTable:GetData("IsUnpacked")) then
		return itemTable("extraWeight");
	end;
end);

-- Called when a player attempts to take the item from storage.
function ITEM:CanTakeStorage(player, storageTable)
	local extraWeight = self("extraWeight");
	local target = Clockwork.entity:GetPlayer(storageTable.entity);
	
	if (IsValid(target) and self:GetData("IsUnpacked")
	and target:GetInventoryWeight() > (target:GetMaxWeight() - extraWeight)) then
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

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self:GetData("IsUnpacked")) then
		self:SetData("IsUnpacked", false);
		return true;
	end;
	
	local itemsList = player:GetItemsByID(self("uniqueID"));
	if (!itemsList) then return true; end;
	
	for k, v in pairs(itemsList) do
		if (v("name") == self("name") and v:GetData("IsUnpacked")) then
			Clockwork.player:Notify(
				player, "You cannot have another unpacked "..string.lower(self("name")).."!"
			);
			return false;
		end;
	end;
	
	self:SetData("IsUnpacked", true);
	return true;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	local extraWeight = self("extraWeight");
	local maxWeight = player:GetMaxWeight() - extraWeight;
	
	if (self:GetData("IsUnpacked") and player:GetInventoryWeight() > maxWeight) then
		Clockwork.player:Notify(player, "You cannot drop this while you are carrying items in it!");
		return false;
	end;
end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clientSideInfo = "";
		local extraWeight = self("extraWeight");
		local itemRarity = self:GetData("Rarity");
		
		clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Extra Weight: "..extraWeight.."kg");
		
		if (self:GetData("IsUnpacked")) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Unpacked: Yes");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Unpacked: No");
		end;
		
		if (itemRarity == 1) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Rare", Color(73, 184, 255, 255));
		elseif (itemRarity == 2) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Legendary", Color(255, 85, 85, 255));
		elseif (itemRarity == 3) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Unique", Color(255, 206, 73, 255));
		end;
		
		return (clientSideInfo != "" and clientSideInfo);
	end
	
	-- Called when the item entity's menu options are needed.
	function ITEM:GetEntityMenuOptions(entity, options)
		if (!Clockwork.player:HasFlags(Clockwork.Client, "s")) then
			return;
		end;
		
		options["Customize"] = function()
			local customData = {};
			
			Derma_StringRequest("Name", "What would you like to set the name to?", "", function(text)
				customData.name = text;
				
			Derma_StringRequest("Weight", "What much extra weight can be held with this?", "", function(text)
				customData.weight = tonumber(text);
				
			Derma_StringRequest("Rarity", "How rare is it? 0 for common, 1 for rare, 2 for legendary, or 3 for unique.", "", function(text)
				customData.rarity = math.Clamp(tonumber(text), 0, 3);
				
			Derma_StringRequest("Description", "What would you like to set the description to?", "", function(text)
				customData.desc = text;
				
				if (IsValid(entity)) then
					Clockwork.entity:ForceMenuOption(
						entity, "Customize", customData
					);
				end;
			end); end); end); end);
		end;
	end;
end;

Clockwork.item:Register(ITEM);