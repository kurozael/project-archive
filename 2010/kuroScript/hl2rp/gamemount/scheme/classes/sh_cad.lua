--[[
Name: "sh_cad.lua".
Product: "HL2 RP".
--]]

local CLASS = {};

-- Set some information.
CLASS.whitelist = true;
CLASS.models = {
	female = {
		"models/humans/group01/drconnors.mdl"
	},
	male = {
		"models/humans/barnes/oshikawa.mdl",
		"models/characters/gallaha.mdl"
	}
};

-- Called when a player is transferred to the class.
function CLASS:OnTransferred(player, class, name)
	if (class.name != CLASS_CIT) then
		return false;
	end;
end;

-- Register the class.
CLASS_CAD = kuroScript.class.Register(CLASS, "City Administrator");