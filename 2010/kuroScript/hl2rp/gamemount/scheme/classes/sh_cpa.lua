--[[
Name: "sh_cpa.lua".
Product: "HL2 RP".
--]]

local CLASS = {};

-- Set some information.
CLASS.whitelist = true;
CLASS.models = {
	female = {"models/police.mdl"},
	male = {"models/police.mdl"}
};

-- Called when a player's name should be assigned for the class.
function CLASS:GetName(player, character)
	return "CPA-RCT.04-"..kuroScript.frame:ZeroNumberToDigits(math.random(1, 99999), 5);
end;

-- Called when a player's model should be assigned for the class.
function CLASS:GetModel(player, character)
	if (character.gender == GENDER_MALE) then
		return self.models.male[1];
	else
		return self.models.female[1];
	end;
end;

-- Called when a player is transferred to the class.
function CLASS:OnTransferred(player, class, name)
	if (class.name == CLASS_OTA) then
		if (name) then
			kuroScript.player.SetName(player, string.gsub(player:QueryCharacter("name"), ".+(%d%d%d%d%d)", "CPA-RCT.04-%1"), true);
		else
			return false, "You need to specify a name as the third argument!";
		end;
	else
		kuroScript.player.SetName( player, self:GetName( player, player:GetCharacter() ) );
	end;
	
	-- Check if a statement is true.
	if (player:QueryCharacter("gender") == GENDER_MALE) then
		player:SetCharacterData("model", self.models.male[1], true);
	else
		player:SetCharacterData("model", self.models.female[1], true);
	end;
end;

-- Register the class.
CLASS_CPA = kuroScript.class.Register(CLASS, "Civil Protection Authority");