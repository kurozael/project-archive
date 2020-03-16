--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity() self:LoadAreaNames(); end;

-- Called when a player's character has loaded.
function MOUNT:PlayerCharacterLoaded(player)
	datastream.StreamToClients( {player}, "ks_AreaNames", self.areaNames );
end;