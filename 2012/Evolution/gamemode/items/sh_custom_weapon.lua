--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base", true);
ITEM.name = "Custom Weapon";
ITEM.batch = 1;
ITEM.damageScale = 100;
ITEM.hasFlashlight = false;

ITEM:AddData("Name", "", true);
ITEM:AddData("Desc", "", true);
ITEM:AddData("Found", false);
ITEM:AddData("Rarity", 0, true);
ITEM:AddData("Damage", -1, true);
ITEM:AddData("LastKey", -1);
ITEM:AddData("Durability", 100, true);

ITEM:AddQueryProxy("hasFlashlight", "Flashlight", true);
ITEM:AddQueryProxy("damageScale", "Damage", true);
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
		local weaponBaseClass = self:GetBaseClass("weapon_base");
		local clientSideInfo = weaponBaseClass.GetClientSideInfo(self);
		local damageScale = self("damageScale");
		local durability = self:GetData("Durability");
		local itemRarity = self:GetData("Rarity");
		
		if (!clientSideInfo) then
			clientSideInfo = "";
		end;
		
		clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Damage Scale: "..math.floor(damageScale).."%");
		
		if (self("hasFlashlight")) then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Has Flashlight: Yes");
		else
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, "Has Flashlight: No");
		end;
		
		local durabilityColor = Color((255 / 100) * (100 - durability), (255 / 100) * durability, 0, 255);
		clientSideInfo = Clockwork:AddMarkupLine(
			clientSideInfo, "Durability: "..math.floor(durability).."%", durabilityColor
		);
		
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
		if (Clockwork.player:HasFlags(Clockwork.Client, "s")) then
			options["Customize"] = function()
				local customData = {};
				
				Derma_StringRequest("Name", "What would you like to set the name to?", "", function(text)
					customData.name = text;
					
				Derma_StringRequest("Rarity", "How rare is this weapon (0 for common, 1 for rare, 2 for legendary, or 3 for unique)?", "", function(text)
					customData.rarity = math.Clamp(tonumber(text), 0, 3);
					
				Derma_StringRequest("Damage", "How much should we scale weapon damage by (the default is 100%)?", "", function(text)
					customData.damage = math.Clamp(tonumber(text), 0, 500);
					
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
		
		local weaponBaseClass = self:GetBaseClass("weapon_base");
		
		if (weaponBaseClass) then
			weaponBaseClass.GetEntityMenuOptions(self, entity, options);
		end;
	end;
end;

Clockwork.item:Register(ITEM);