--[[
Name: "sh_clothes_base.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.rare = true;
ITEM.name = "Clothes Base";
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl";
ITEM.weight = 3;
ITEM.useText = "Wear";
ITEM.category = "Clothing";
ITEM.description = "A suitcase full of clothes.";
ITEM.isBaseItem = true;

-- A function to get the model name.
function ITEM:GetModelName(player, group)
	local name;
	
	-- Check if a statement is true.
	if (!player) then
		player = g_LocalPlayer;
	end;
	
	-- Check if a statement is true.
	if (group) then
		name = string.gsub(string.lower( kuroScript.player.GetDefaultModel(player) ), "^.-/.-/", "");
	else
		name = string.gsub(string.lower( kuroScript.player.GetDefaultModel(player) ), "^.-/.-/.-/", "");
	end;
	
	-- Check if a statement is true.
	if ( !string.find(name, "male") and !string.find(name, "female") ) then
		if (group) then
			group = "group01/";
		else
			group = "";
		end;
		
		-- Check if a statement is true.
		if (SERVER) then
			if (player:QueryCharacter("gender") == GENDER_FEMALE) then
				return group.."female_04.mdl";
			else
				return group.."male_05.mdl";
			end;
		elseif (kuroScript.player.GetGender(player) == GENDER_FEMALE) then
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
	local replacement;
	
	-- Check if a statement is true.
	if (self.GetReplacement) then
		replacement = self:GetReplacement(g_LocalPlayer);
	end;
	
	-- Check if a statement is true.
	if (type(replacement) == "string") then
		return replacement;
	elseif (self.replacement) then
		return self.replacement;
	elseif (self.group) then
		return "models/humans/"..self.group.."/"..self:GetModelName();
	end;
end;

-- Called when a player changes clothes.
function ITEM:OnChangeClothes(player, boolean)
	if (boolean) then
		local replacement;
		
		-- Check if a statement is true.
		if (self.GetReplacement) then
			replacement = self:GetReplacement(player);
		end;
		
		-- Check if a statement is true.
		if (type(replacement) == "string") then
			player:SetModel(replacement);
		elseif (self.replacement) then
			player:SetModel(self.replacement);
		elseif (self.group) then
			player:SetModel( "models/humans/"..self.group.."/"..self:GetModelName(player) );
		end;
	else
		kuroScript.player.SetDefaultModel(player);
		kuroScript.player.SetDefaultSkin(player);
	end;
	
	-- Check if a statement is true.
	if (self.OnChangedClothes) then
		self:OnChangedClothes(player, boolean);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:GetCharacterData("clothes") == self.uniqueID) then
		if (kuroScript.inventory.HasItem(player, self.uniqueID) == 1) then
			kuroScript.player.Notify(player, "You cannot drop this while you are wearing it!");
			
			-- Return false to break the function.
			return false;
		end;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:QueryCharacter("class") == CLASS_CIT) then
		if ( player:Alive() and !player:IsRagdolled() ) then
			kuroScript.game:PlayerWearClothes(player, self, nil, itemEntity);
			
			-- Check if a statement is true.
			if (itemEntity) then
				return true;
			end;
		else
			kuroScript.player.Notify(player, "You cannot do that in this state!");
		end;
	else
		kuroScript.player.Notify(player, "You are not a citizen!");
	end;
	
	-- Return false to break the function.
	return false;
end;

-- Register the item.
kuroScript.item.Register(ITEM);