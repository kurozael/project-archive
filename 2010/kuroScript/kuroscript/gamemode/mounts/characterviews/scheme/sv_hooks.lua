--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player initially spawns.
function MOUNT:PlayerInitialSpawn(player)
	if (#self.characterViews > 0) then
		datastream.StreamToClients( {player}, "ks_CharacterViews", self.characterViews );
	end;
end;