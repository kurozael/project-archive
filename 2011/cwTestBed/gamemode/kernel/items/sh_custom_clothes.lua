--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("clothes_base", true);
ITEM.name = "Custom Clothes";

ITEM:AddData("Name", "", true);
ITEM:AddData("Desc", "", true);
ITEM:AddData("Found", false);
ITEM:AddData("Armor", -1, true);
ITEM:AddData("Rarity", 0, true);
ITEM:AddData("Durability", 100, true);

ITEM:AddQueryProxy("armorScale", "Armor", true);
ITEM:AddQueryProxy("description", "Desc", true);
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

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clothesBaseClass = self:GetBaseClass("clothes_base");
		local clientSideInfo = clothesBaseClass.GetClientSideInfo(self);
		local armorScale = self("armorScale");
		local durability = self:GetData("Durability");
		local itemRarity = self:GetData("Rarity");
		
		if (!clientSideInfo) then
			clientSideInfo = "";
		end;
		
		clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Resistance: "..math.floor(armorScale * 100).."%");
	
		if (durability <= 0.25) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Durability: <color=225,100,100>"..math.floor(durability).."%</color>");
		elseif (durability <= 0.5) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Durability: <color=249,162,128>"..math.floor(durability).."%</color>");
		elseif (durability <= 0.75) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Durability: <color=225,188,109>"..math.floor(durability).."%</color>");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Durability: <color=165,249,128>"..math.floor(durability).."%</color>");
		end;
		
		if (armorScale <= 0.1) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Armor: <color=225,100,100>Weak</color>");
		elseif (armorScale < 0.25) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Armor: <color=225,100,100>Low</color>");
		elseif (armorScale < 0.5) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Armor: <color=249,162,128>Medimum</color>");
		elseif (armorScale < 0.75) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Armor: <color=225,188,109>Heavy</color>");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Armor: <color=165,249,128>Godlike</color>");
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
				
			Derma_StringRequest("Armor", "What would you like to set the armor to (from 0 to 1, with 1 being the most protected)?", "", function(text)
				customData.armor = math.Clamp(tonumber(text), 0, 1);
			
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