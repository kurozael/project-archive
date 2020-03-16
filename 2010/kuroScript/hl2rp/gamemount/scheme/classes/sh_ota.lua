--[[
Name: "sh_ota.lua".
Product: "HL2 RP".
--]]

local CLASS = {};

-- Set some information.
CLASS.whitelist = true;
CLASS.models = {
	female = {"models/combine_soldier.mdl"},
	male = {"models/combine_soldier.mdl"}
};

-- Called when a player's name should be assigned for the class.
function CLASS:GetName(player, character)
	local unitID = math.random(1, 99999);
	
	-- Return the name.
	return "OTA-ECHO.OWS-"..kuroScript.frame:ZeroNumberToDigits(unitID, 5);
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
	if (class.name == CLASS_CPA) then
		kuroScript.player.SetName(player, string.gsub(player:QueryCharacter("name"), ".+(%d%d%d%d%d)", "OTA-ECHO.OWS-%1"), true);
	else
		kuroScript.player.SetName(player, self:GetName( player, player:GetCharacter() ), true);
	end;
	
	-- Check if a statement is true.
	if (player:QueryCharacter("gender") == GENDER_MALE) then
		player:SetCharacterData("model", self.models.male[1], true);
	else
		player:SetCharacterData("model", self.models.female[1], true);
	end;
end;

-- Register the class.
CLASS_OTA = kuroScript.class.Register(CLASS, "Overwatch Transhuman Arm");