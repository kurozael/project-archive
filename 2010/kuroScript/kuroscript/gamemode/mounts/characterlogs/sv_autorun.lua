--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Add a character log.
function MOUNT:AddCharLog(player, text)
	local day = kuroScript.frame:ZeroNumberToDigits(kuroScript.date.day, 2);
	local hour = kuroScript.frame:ZeroNumberToDigits(kuroScript.time.hour, 2);
	local year = kuroScript.frame:ZeroNumberToDigits(kuroScript.date.year, 4);
	local month = kuroScript.frame:ZeroNumberToDigits(kuroScript.date.month, 2);
	local minute = kuroScript.frame:ZeroNumberToDigits(kuroScript.time.minute, 2);
	
	-- Set some information.
	local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
	local characterKey = player:QueryCharacter("key");
	local steamID = player:SteamID();
	local game = GAME_FOLDER;
	
	-- Set some information.
	local keys = "INSERT INTO charlogs (_Text, _Date, _Time, _Game, _Table, _SteamID, _CharacterKey)";
	local values = "(\""..tmysql.escape(text).."\", \""..day.."/"..month.."/"..year.."\", \""..hour..":"..minute.."\", \""..game.."\", \""..charactersTable.."\", \""..steamID.."\", \""..characterKey.."\")";
	
	-- Add a message in the player's radius.
	kuroScript.chatBox.AddInRadius( player, "charlog", text, player:GetPos(), kuroScript.config.Get("talk_radius"):Get() );
	
	-- Print a debug message.
	kuroScript.frame:PrintDebug(player:Name().." has added a "..string.len(text).." bit character log.");
	
	-- Perform a threaded query.
	tmysql.query(keys.." VALUES "..values);
end;