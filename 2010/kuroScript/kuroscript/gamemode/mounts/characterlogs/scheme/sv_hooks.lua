--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player deletes a character.
function MOUNT:PlayerDeleteCharacter(player, character)
	local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
	local steamID = player:SteamID();
	local game = GAME_FOLDER;
	
	-- Perform a threaded query.
	tmysql.query("DELETE FROM charlogs WHERE _Game = \""..game.."\" AND _Table = \""..charactersTable.."\" AND _SteamID = \""..steamID.."\" AND _CharacterKey = "..character._Key);
end;