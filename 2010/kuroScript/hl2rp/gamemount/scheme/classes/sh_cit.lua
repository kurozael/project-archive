--[[
Name: "sh_cit.lua".
Product: "HL2 RP".
--]]

local CLASS = {};

-- Called when a player is transferred to the class.
function CLASS:OnTransferred(player, class, name)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		if (name) then
			local models = self.models[ string.lower( player:QueryCharacter("gender") ) ];
			
			-- Set some information.
			player:SetCharacterData("model", models[ math.random(#models) ], true);
			
			-- Set some information.
			kuroScript.player.SetName(player, name, true);
		else
			return false, "You need to specify a name as the third argument!";
		end;
	end;
end;

-- Register the class.
CLASS_CIT = kuroScript.class.Register(CLASS, "Citizen");