--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Whether or not to only display typing notices when visible.
kuroScript.config.Add("typing_visible_only", true, true);

-- Called when a player starts typing.
concommand.Add("ks_typing_start", function(player, command, arguments)
	if ( player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		if ( arguments and arguments[1] ) then
			hook.Call( "PlayerStartTypingDisplay", kuroScript.frame, player, arguments[1] );
			
			-- Check if a statement is true.
			if (arguments[1] == "w") then
				player:SetSharedVar("ks_Typing", TYPING_WHISPER);
			elseif (arguments[1] == "p") then
				player:SetSharedVar("ks_Typing", TYPING_PERFORM);
			elseif (arguments[1] == "l") then
				player:SetSharedVar("ks_Typing", TYPING_LOGGING);
			elseif (arguments[1] == "n") then
				player:SetSharedVar("ks_Typing", TYPING_NORMAL);
			elseif (arguments[1] == "r") then
				player:SetSharedVar("ks_Typing", TYPING_RADIO);
			elseif (arguments[1] == "y") then
				player:SetSharedVar("ks_Typing", TYPING_YELL);
			elseif (arguments[1] == "o") then
				player:SetSharedVar("ks_Typing", TYPING_OOC);
			end;
		end;
	end;
end);

-- Called when a player finishes typing.
concommand.Add("ks_typing_finish", function(player, command, arguments)
	if ( ValidEntity(player) ) then
		if (arguments and arguments[1] and arguments[1] == "1") then
			hook.Call("PlayerFinishTypingDisplay", kuroScript.frame, player, true);
		else
			hook.Call("PlayerFinishTypingDisplay", kuroScript.frame, player);
		end;
		
		-- Set some information.
		player:SetSharedVar("ks_Typing", 0);
	end;
end);