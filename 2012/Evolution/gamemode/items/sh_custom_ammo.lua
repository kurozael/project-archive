--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Custom Ammo";
ITEM.model = "models/items/boxsrounds.mdl";
ITEM.weight = 1;
ITEM.useText = "Load";
ITEM.category = "Ammunition";
ITEM.description = "Custom rounds which deal a different effect.";

ITEM:AddData("Name", "", true);
ITEM:AddData("Desc", "", true);
ITEM:AddData("Model", "", true);
ITEM:AddData("Found", false);
ITEM:AddData("Rarity", 0, true);
ITEM:AddData("Rounds", 0, true);
ITEM:AddData("Script", "");
ITEM:AddData("IsEquipped", false, true);

ITEM:AddQueryProxy("description", "Desc", true);
ITEM:AddQueryProxy("model", "Model", true);
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

-- A function to get the item's save name.
function ITEM:GetSaveName()
	return self:GetData("Name"):gsub("%s", "_"):gsub("%p", "");
end;

-- A function to make the item fire a round.
function ITEM:FireRound(player, attacker, bulletInfo, bTakeRound)
	if (self:GetData("Rounds") != 0) then
		if (bTakeRound) then
			self:SetData(
				"Rounds", self:GetData("Rounds") - 1
			);
		end;
		
		BULLET = bulletInfo;
		PLAYER = attacker;
		TARGET = player;
		ITEM = self;
			RunString(self:GetData("Script"));
		BULLET = nil;
		PLAYER = nil;
		TARGET = nil;
		ITEM = nil;
		
		if (self:GetData("Rounds") == 0) then
			attacker:TakeItem(self);
		end;
	else
		attacker:TakeItem(self);
	end;
end;

-- Called when the item is saved to a table.
function ITEM:OnSaved(newData)
	local saveName = self:GetSaveName();
	
	if (saveName != "") then
		for k, v in pairs(newData) do
			if (k != "Name"
			and k != "Found") then
				newData[k] = nil;
			end;
		end;
		
		return true;
	else
		return false;
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

-- Called when the item's network data is updated.
function ITEM:OnNetworkDataUpdated(newData)
	if (newData["IsEquipped"] != nil) then
		Clockwork.inventory:Rebuild();
	end;
end;

-- A function to save the item data to the scripts.
function ITEM:SaveToScripts()
	local saveName = self:GetSaveName();
	local saveData = {};
	
	for k, v in pairs(self("data")) do
		if (k != "Name" and k != "Found") then
			saveData[k] = v;
		end;
	end;
	
	Clockwork:SaveSchemaData("itemscripts/"..saveName, saveData);
end;

--[[
	Create a variable local to this script to store
	the loaded item scripts. This could all be converted
	to MySQL for cross-server support.
--]]
local ITEM_SCRIPTS = {};

-- Called when the item is loaded from a table.
function ITEM:OnLoaded()
	local saveName = self:GetSaveName();
	
	if (saveName != "" and !ITEM_SCRIPTS[saveName]) then
		ITEM_SCRIPTS[saveName] = Clockwork:RestoreSchemaData(
			"itemscripts/"..saveName, false
		);
	end;
	
	if (ITEM_SCRIPTS[saveName]) then
		table.Merge(
			self("data"), ITEM_SCRIPTS[saveName]
		);
		
		return true;
	elseif (self:GetData("Script") == "") then
		return false;
	else
		self:SaveToScripts();
		return true;
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	return self:GetData("IsEquipped");
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	if (self:GetData("IsEquipped")) then
		self:SetData("IsEquipped", false);
		return true;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self:GetData("IsEquipped")) then
		return self:OnPlayerUnequipped(player);
	end;
	
	local itemsList = player:GetItemsByID(self("uniqueID"));
	if (!itemsList) then return false; end;
	
	for k, v in pairs(itemsList) do
		if (v:GetData("IsEquipped")) then
			Clockwork.player:Notify(
				player, "You cannot have another set of custom rounds equipped!"
			);
			return false;
		end;
	end;
	
	if (self:GetData("Rounds") == 0) then
		Clockwork.player:Notify(player, "This ammunition box does not have any rounds!");
		return false;
	end;
	
	self:SetData("IsEquipped", true);
	return true;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clientSideInfo = "";
		local itemRarity = self:GetData("Rarity");
		
		clientSideInfo = Clockwork:AddMarkupLine(
			clientSideInfo, "You still need the weapon's original ammunition for these rounds to attach to!", Color(255, 100, 100, 255)
		);
		clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Rounds: "..self:GetData("Rounds"));
		
		if (self:GetData("IsEquipped")) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Equipped: Yes");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Equipped: No");
		end;
		
		if (itemRarity == 1) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Rare", Color(73, 184, 255, 255));
		elseif (itemRarity == 2) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Legendary", Color(255, 85, 85, 255));
		elseif (itemRarity == 3) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Unique", Color(255, 206, 73, 255));
		end;
		
		return (clientSideInfo != "" and clientSideInfo);
	end;
	
	-- Called when the item entity's menu options are needed.
	function ITEM:GetEntityMenuOptions(entity, options)
		if (!Clockwork.player:HasFlags(Clockwork.Client, "s")) then
			return;
		end;
		
		options["Customize"] = function()
			local customData = {};
			
			Derma_StringRequest("Name", "What would you like to set the name to?", "", function(text)
				customData.name = text;
				
			Derma_StringRequest("Model", "What would you like to set the model to?", "", function(text)
				customData.model = text;
				
			Derma_StringRequest("Script", "What would you like to set the script to (BULLET, PLAYER, TARGET, ITEM)?", "", function(text)
				customData.script = text;
				
			Derma_StringRequest("Rounds", "How many rounds do you get out of this ammunition?", "", function(text)
				customData.rounds = tonumber(text);
				
			Derma_StringRequest("Rarity", "How rare is it? 0 for common, 1 for rare, 2 for legendary, or 3 for unique.", "", function(text)
				customData.rarity = math.Clamp(tonumber(text), 0, 3);
			
			Derma_StringRequest("Description", "What would you like to set the description to?", "", function(text)
				customData.desc = text;
				
				if (IsValid(entity)) then
					Clockwork.entity:ForceMenuOption(
						entity, "Customize", customData
					);
				end;
			end); end); end); end); end); end);
		end;
	end;
end;

Clockwork.item:Register(ITEM);