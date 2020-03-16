--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- Called when a player starts typing.
concommand.Add("aura_typing_start", function(player, command, arguments)
	if ( player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
		if ( arguments and arguments[1] ) then
			hook.Call( "PlayerStartTypingDisplay", openAura, player, arguments[1] );
			
			if (arguments[1] == "w") then
				player:SetSharedVar("typing", TYPING_WHISPER);
			elseif (arguments[1] == "p") then
				player:SetSharedVar("typing", TYPING_PERFORM);
			elseif (arguments[1] == "n") then
				player:SetSharedVar("typing", TYPING_NORMAL);
			elseif (arguments[1] == "r") then
				player:SetSharedVar("typing", TYPING_RADIO);
			elseif (arguments[1] == "y") then
				player:SetSharedVar("typing", TYPING_YELL);
			elseif (arguments[1] == "o") then
				player:SetSharedVar("typing", TYPING_OOC);
			end;
		end;
	end;
end);

-- Called when a player finishes typing.
concommand.Add("aura_typing_finish", function(player, command, arguments)
	if ( IsValid(player) ) then
		if (arguments and arguments[1] and arguments[1] == "1") then
			openAura.plugin:Call("PlayerFinishTypingDisplay", player, true);
		else
			openAura.plugin:Call("PlayerFinishTypingDisplay", player);
		end;
		
		player:SetSharedVar("typing", 0);
	end;
end);