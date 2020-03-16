--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Clothes Base";
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl";
ITEM.weight = 2;
ITEM.useText = "Wear";
ITEM.category = "Clothing";
ITEM.description = "A suitcase full of clothes.";
ITEM.isBaseItem = true;

-- A function to get the model name.
function ITEM:GetModelName(player, group)
	local name;
	
	if (!player) then
		player = openAura.Client;
	end;
	
	if (group) then
		name = string.gsub(string.lower( openAura.player:GetDefaultModel(player) ), "^.-/.-/", "");
	else
		name = string.gsub(string.lower( openAura.player:GetDefaultModel(player) ), "^.-/.-/.-/", "");
	end;
	
	if ( !string.find(name, "male") and !string.find(name, "female") ) then
		if (group) then
			group = "group05/";
		else
			group = "";
		end;
		
		if (SERVER) then
			if (openAura.player:GetGender(player) == GENDER_FEMALE) then
				return group.."female_04.mdl";
			else
				return group.."male_05.mdl";
			end;
		elseif (openAura.player:GetGender(player) == GENDER_FEMALE) then
			return group.."female_04.mdl";
		else
			return group.."male_05.mdl";
		end;
	else
		return name;
	end;
end;

-- Called when the item's client side model is needed.
function ITEM:GetClientSideModel()
	local replacement = nil;
	
	if (self.GetReplacement) then
		replacement = self:GetReplacement(openAura.Client);
	end;
	
	if (type(replacement) == "string") then
		return replacement;
	elseif (self.replacement) then
		return self.replacement;
	elseif (self.group) then
		return "models/humans/"..self.group.."/"..self:GetModelName();
	end;
end;

-- Called when a player changes clothes.
function ITEM:OnChangeClothes(player, isWearing)
	if (isWearing) then
		local replacement = nil;
		
		if (self.GetReplacement) then
			replacement = self:GetReplacement(player);
		end;
		
		if (type(replacement) == "string") then
			player:SetModel(replacement);
		elseif (self.replacement) then
			player:SetModel(self.replacement);
		elseif (self.group) then
			player:SetModel( "models/humans/"..self.group.."/"..self:GetModelName(player) );
		end;
	else
		openAura.player:SetDefaultModel(player);
		openAura.player:SetDefaultSkin(player);
	end;
	
	if (self.OnChangedClothes) then
		self:OnChangedClothes(player, isWearing);
	end;
end;

-- Called when the item's local amount is needed.
function ITEM:GetLocalAmount(amount)
	if (openAura.Client:GetSharedVar("clothes") == self.index) then
		return amount - 1;
	else
		return amount;
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, arguments)
	if (SERVER) then
		return (player:GetCharacterData("clothes") == self.index);
	else
		return (player:GetSharedVar("clothes") == self.index);
	end;
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, arguments)
	openAura.schema:PlayerWearClothes(player, false);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:GetCharacterData("clothes") == self.index) then
		if (player:HasItem(self.uniqueID) == 1) then
			openAura.player:Notify(player, "You cannot drop this while you are wearing it!");
			
			return false;
		end;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if ( player:Alive() and !player:IsRagdolled() ) then
		if (!self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false) then
			openAura.schema:PlayerWearClothes(player, self);
			
			if (itemEntity) then
				return true;
			end;
		end;
	else
		openAura.player:Notify(player, "You don't have permission to do this right now!");
	end;
	
	return false;
end;

openAura.item:Register(ITEM);