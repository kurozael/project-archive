--[[
Name: "cl_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player's HUD should be painted.
function MOUNT:HUDPaintPlayer(player)
	local typing = player:GetSharedVar("ks_Typing");
	
	-- Check if a statement is true.
	if (typing != 0) then
		local fadeDistance = 192;
		
		-- Check if a statement is true.
		if (typing == TYPING_YELL or typing == TYPING_PERFORM) then
			fadeDistance = kuroScript.config.Get("talk_radius"):Get() * 2;
		elseif (typing == TYPING_WHISPER) then
			fadeDistance = kuroScript.config.Get("talk_radius"):Get() / 3;
			
			-- Check if a statement is true.
			if (fadeDistance > 80) then
				fadeDistance = 80;
			end;
		else
			fadeDistance = kuroScript.config.Get("talk_radius"):Get();
		end;
		
		-- Check if a statement is true.
		if (player:GetPos():Distance( g_LocalPlayer:GetPos() ) <= fadeDistance) then
			if ( player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
				if (player:InVehicle() or player:GetMoveType() != MOVETYPE_NOCLIP) then
					local r, g, b, a = player:GetColor();
					local position = hook.Call("GetPlayerTypingDisplayPosition", kuroScript.frame, player);
					local curTime = UnPredictedCurTime();
					
					-- Check if a statement is true.
					if (player:GetMaterial() != "sprites/heatwave" and a != 0) then
						local alpha = kuroScript.frame:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, player);
						local bounce = math.sin(curTime) * 2;
						local position = hook.Call("GetPlayerTypingDisplayPosition", kuroScript.frame, player);
						
						-- Check if a statement is true.
						if (!position) then
							local bonePosition;
							
							-- Check if a statement is true.
							if ( player:InVehicle() ) then
								bonePosition = player:GetBonePosition( player:LookupBone("ValveBiped.Bip01_Head1") );
								
								-- Check if a statement is true.
								if (!bonePosition) then
									position = player:GetPos() + Vector(0, 0, 128 + bounce);
								end;
							elseif ( player:IsRagdolled() ) then
								local entity = player:GetRagdollEntity();
								
								-- Check if a statement is true.
								if ( ValidEntity(entity) ) then
									bonePosition = entity:GetBonePosition( entity:LookupBone("ValveBiped.Bip01_Head1") );
									
									-- Check if a statement is true.
									if (!bonePosition) then
										position = player:GetPos() + Vector(0, 0, 16 + bounce);
									end;
								end;
							elseif ( player:Crouching() ) then
								bonePosition = player:GetBonePosition( player:LookupBone("ValveBiped.Bip01_Head1") );
								
								-- Check if a statement is true.
								if (!bonePosition) then
									position = player:GetPos() + Vector(0, 0, 64 + bounce);
								end;
							else
								bonePosition = player:GetBonePosition( player:LookupBone("ValveBiped.Bip01_Head1") );
								
								-- Check if a statement is true.
								if (!bonePosition) then
									position = player:GetPos() + Vector(0, 0, 80 + bounce);
								end;
							end;
							
							-- Check if a statement is true.
							if (bonePosition) then
								position = bonePosition + Vector(0, 0, 16 + bounce);
							end;
						end;
						
						-- Check if a statement is true.
						if ( kuroScript.config.Get("typing_visible_only"):Get() ) then
							if ( !kuroScript.player.CanSeePlayer(g_LocalPlayer, player) ) then
								return;
							end;
						end;
						
						-- Check if a statement is true.
						if (position) then
							position = position:ToScreen();
							
							-- Check if a statement is true.
							if (typing == TYPING_WHISPER) then
								y = kuroScript.frame:DrawInfo("Whispering", position.x, position.y, COLOR_WHITE, alpha);
							elseif (typing == TYPING_PERFORM) then
								y = kuroScript.frame:DrawInfo("Performing", position.x, position.y, COLOR_WHITE, alpha);
							elseif (typing == TYPING_LOGGING) then
								y = kuroScript.frame:DrawInfo("Logging", position.x, position.y, COLOR_WHITE, alpha);
							elseif (typing == TYPING_NORMAL) then
								y = kuroScript.frame:DrawInfo("Talking", position.x, position.y, COLOR_WHITE, alpha);
							elseif (typing == TYPING_RADIO) then
								y = kuroScript.frame:DrawInfo("Radioing", position.x, position.y, COLOR_WHITE, alpha);
							elseif (typing == TYPING_YELL) then
								y = kuroScript.frame:DrawInfo("Yelling", position.x, position.y, COLOR_WHITE, alpha);
							elseif (typing == TYPING_OOC) then
								y = kuroScript.frame:DrawInfo("Typing", position.x, position.y, COLOR_WHITE, alpha);
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when the chat box is closed.
function MOUNT:ChatBoxClosed(textTyped)
	if (textTyped) then
		RunConsoleCommand("ks_typing_finish", "1");
	else
		RunConsoleCommand("ks_typing_finish");
	end;
end;

-- Called when the chat box text has changed.
function MOUNT:ChatBoxTextChanged(previousText, newText)
	local prefix = kuroScript.config.Get("command_prefix"):Get();
	
	-- Check if a statement is true.
	if (string.sub(newText, 1, string.len(prefix) + 12) == prefix.."whispername ") then
		if (string.sub(previousText, 1, string.len(prefix) + 12) != prefix.."whispername ") then
			RunConsoleCommand("ks_typing_start", "w");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 9) == prefix.."yellname ") then
		if (string.sub(previousText, 1, string.len(prefix) + 9) != prefix.."yellname ") then
			RunConsoleCommand("ks_typing_start", "y");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 8) == prefix.."charlog ") then
		if (string.sub(previousText, 1, string.len(prefix) + 8) != prefix.."charlog ") then
			RunConsoleCommand("ks_typing_start", "l");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 6) == prefix.."radio ") then
		if (string.sub(previousText, 1, string.len(prefix) + 6) != prefix.."radio ") then
			RunConsoleCommand("ks_typing_start", "r");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 3) == prefix.."me ") then
		if (string.sub(previousText, 1, string.len(prefix) + 3) != prefix.."me ") then
			RunConsoleCommand("ks_typing_start", "p");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 3) == prefix.."pm ") then
		if (string.sub(previousText, 1, string.len(prefix) + 3) != prefix.."pm ") then
			RunConsoleCommand("ks_typing_start", "o");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 2) == prefix.."w ") then
		if (string.sub(previousText, 1, string.len(prefix) + 2) != prefix.."w ") then
			RunConsoleCommand("ks_typing_start", "w");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 2) == prefix.."y ") then
		if (string.sub(previousText, 1, string.len(prefix) + 2) != prefix.."y ") then
			RunConsoleCommand("ks_typing_start", "y");
		end;
	elseif (string.sub(newText, 1, 3) == "// ") then
		if (string.sub(previousText, 1, 3) != prefix.."// ") then
			RunConsoleCommand("ks_typing_start", "o");
		end;
	elseif (string.sub(newText, 1, 4) == ".// ") then
		if (string.sub(previousText, 1, 4) != prefix..".// ") then
			RunConsoleCommand("ks_typing_start", "o");
		end;
	elseif (string.len(newText) >= 4 and string.len(previousText) < 4) then
		RunConsoleCommand("ks_typing_start", "n");
	end;
end;