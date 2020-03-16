--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- Whether or not to only display typing notices when visible.
nexus.config.Add("typing_visible_only", true, true);

-- Called when a player starts typing.
concommand.Add("nx_typing_start", function(player, command, arguments)
	if ( player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		if ( arguments and arguments[1] ) then
			hook.Call( "PlayerStartTypingDisplay", NEXUS, player, arguments[1] );
			
			if (arguments[1] == "w") then
				player:SetSharedVar("sh_Typing", TYPING_WHISPER);
			elseif (arguments[1] == "p") then
				player:SetSharedVar("sh_Typing", TYPING_PERFORM);
			elseif (arguments[1] == "n") then
				player:SetSharedVar("sh_Typing", TYPING_NORMAL);
			elseif (arguments[1] == "r") then
				player:SetSharedVar("sh_Typing", TYPING_RADIO);
			elseif (arguments[1] == "y") then
				player:SetSharedVar("sh_Typing", TYPING_YELL);
			elseif (arguments[1] == "o") then
				player:SetSharedVar("sh_Typing", TYPING_OOC);
			end;
		end;
	end;
end);

-- Called when a player finishes typing.
concommand.Add("nx_typing_finish", function(player, command, arguments)
	if ( IsValid(player) ) then
		if (arguments and arguments[1] and arguments[1] == "1") then
			nexus.mount.Call("PlayerFinishTypingDisplay", player, true);
		else
			nexus.mount.Call("PlayerFinishTypingDisplay", player);
		end;
		
		player:SetSharedVar("sh_Typing", 0);
	end;
end);