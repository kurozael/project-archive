--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Custom Script";
ITEM.model = "models/props_junk/garbage_newspaper001a.mdl";
ITEM.weight = 1;
ITEM.useText = "Open";
ITEM.category = "Scripts";
ITEM.description = "An item which can run a custom script.";

ITEM:AddData("Name", "", true);
ITEM:AddData("Desc", "", true);
ITEM:AddData("Model", "", true);
ITEM:AddData("Found", false);
ITEM:AddData("Rarity", 0, true);
ITEM:AddData("Script", "");
ITEM:AddData("Weight", -1, true);
ITEM:AddData("NextUse", -1);
ITEM:AddData("UseText", "", true);
ITEM:AddData("Interval", -1);
ITEM:AddData("Reusable", false);
ITEM:AddData("Category", -1, true);

ITEM:AddQueryProxy("description", "Desc", true);
ITEM:AddQueryProxy("category", "Category", true);
ITEM:AddQueryProxy("useText", "UseText", true);
ITEM:AddQueryProxy("weight", "Weight", true);
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

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self:GetData("Interval") != -1) then
		local nextUse = self:GetData("NextUse");
		
		if (nextUse != -1 and os.time() < nextUse) then
			Clockwork.player:Notify(
				player, "You cannot use this item for another "..math.ceil(nextUse - os.time()).." second(s)!"
			);
			return false;
		end;
		
		self:SetData("NextUse", os.time() + self:GetData("Interval"));
	end;
	
	local bReusable = self:GetData("Reusable");
	
	PLAYER = player; ITEM = self;
		RunString(self:GetData("Script"));
	PLAYER = nil; ITEM = nil;
	
	if (bReusable) then
		return true;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clientSideInfo = "";
		local itemRarity = self:GetData("Rarity");
		
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
				
			Derma_StringRequest("Model", "What would you like to set the model to?", "", function(text)
				customData.model = text;
				
			Derma_StringRequest("Script", "What would you like to set the script to?", "", function(text)
				customData.script = text;
				
			Derma_StringRequest("Weight", "How much does this item weigh in kilograms?", "", function(text)
				customData.weight = tonumber(text);
				
			Derma_StringRequest("Rarity", "How rare is it? 0 for common, 1 for rare, 2 for legendary, or 3 for unique.", "", function(text)
				customData.rarity = math.Clamp(tonumber(text), 0, 3);
				
			Derma_StringRequest("Reusable", "Can this item be used more than once ('yes', 'no' or a number for an interval)?", "", function(text)
				if (tonumber(text)) then
					customData.reusable = true;
					customData.interval = tonumber(text);
				else
					customData.reusable = (string.lower(text) == "yes");
				end;
				
			Derma_StringRequest("Category", "What would you like to set the category to?", "", function(text)
				customData.category = text;
				
			Derma_StringRequest("Use Text", "What would you like to set the use text to (e.g: Use, Open, etc)?", "", function(text)
				customData.useText = text;
				
			Derma_StringRequest("Description", "What would you like to set the description to?", "", function(text)
				customData.desc = text;
				
				if (IsValid(entity)) then
					Clockwork.entity:ForceMenuOption(
						entity, "Customize", customData
					);
				end;
			end); end); end); end); end); end) end); end); end);
		end;
	end;
end;

Clockwork.item:Register(ITEM);