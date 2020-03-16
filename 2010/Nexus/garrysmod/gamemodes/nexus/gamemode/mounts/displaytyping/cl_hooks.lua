--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when a player's HUD should be painted.
function MOUNT:HUDPaintPlayer(player)
	local colorWhite = nexus.schema.GetColor("white");
	local typing = player:GetSharedVar("sh_Typing");
	
	if (typing != 0) then
		local fadeDistance = 192;
		
		if (typing == TYPING_YELL or typing == TYPING_PERFORM) then
			fadeDistance = nexus.config.Get("talk_radius"):Get() * 2;
		elseif (typing == TYPING_WHISPER) then
			fadeDistance = nexus.config.Get("talk_radius"):Get() / 3;
			
			if (fadeDistance > 80) then
				fadeDistance = 80;
			end;
		else
			fadeDistance = nexus.config.Get("talk_radius"):Get();
		end;
		
		if (player:GetPos():Distance( g_LocalPlayer:GetPos() ) <= fadeDistance) then
			if ( player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
				if (player:InVehicle() or player:GetMoveType() != MOVETYPE_NOCLIP) then
					local r, g, b, a = player:GetColor();
					local curTime = UnPredictedCurTime();
					
					if (player:GetMaterial() != "sprites/heatwave" and a != 0) then
						local alpha = NEXUS:CalculateAlphaFromDistance(fadeDistance, g_LocalPlayer, player);
						local position = nexus.mount.Call("GetPlayerTypingDisplayPosition", player);
						local headBone = "ValveBiped.Bip01_Head1";
						
						if ( string.find(player:GetModel(), "vortigaunt") ) then
							headBone = "ValveBiped.Head";
						end;
						
						if (!position) then
							local bonePosition = nil;
							
							if ( player:InVehicle() ) then
								bonePosition = player:GetBonePosition( player:LookupBone(headBone) );
								
								if (!bonePosition) then
									position = player:GetPos() + Vector(0, 0, 128);
								end;
							elseif ( player:IsRagdolled() ) then
								local entity = player:GetRagdollEntity();
								
								if ( IsValid(entity) ) then
									bonePosition = entity:GetBonePosition( entity:LookupBone(headBone) );
									
									if (!bonePosition) then
										position = player:GetPos() + Vector(0, 0, 16);
									end;
								end;
							elseif ( player:Crouching() ) then
								bonePosition = player:GetBonePosition( player:LookupBone(headBone) );
								
								if (!bonePosition) then
									position = player:GetPos() + Vector(0, 0, 64);
								end;
							else
								bonePosition = player:GetBonePosition( player:LookupBone(headBone) );
								
								if (!bonePosition) then
									position = player:GetPos() + Vector(0, 0, 80);
								end;
							end;
							
							if (bonePosition) then
								position = bonePosition + Vector(0, 0, 16);
							end;
						end;
						
						if ( nexus.config.Get("typing_visible_only"):Get() ) then
							if ( !nexus.player.CanSeePlayer(g_LocalPlayer, player) ) then
								return;
							end;
						end;
						
						if (position) then
							position = position:ToScreen();
							
							if (typing == TYPING_WHISPER) then
								NEXUS:DrawInfo("Whispering", position.x, position.y, colorWhite, alpha);
							elseif (typing == TYPING_PERFORM) then
								NEXUS:DrawInfo("Performing", position.x, position.y, colorWhite, alpha);
							elseif (typing == TYPING_NORMAL) then
								NEXUS:DrawInfo("Talking", position.x, position.y, colorWhite, alpha);
							elseif (typing == TYPING_RADIO) then
								NEXUS:DrawInfo("Radioing", position.x, position.y, colorWhite, alpha);
							elseif (typing == TYPING_YELL) then
								NEXUS:DrawInfo("Yelling", position.x, position.y, colorWhite, alpha);
							elseif (typing == TYPING_OOC) then
								NEXUS:DrawInfo("Typing", position.x, position.y, colorWhite, alpha);
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
		RunConsoleCommand("nx_typing_finish", "1");
	else
		RunConsoleCommand("nx_typing_finish");
	end;
end;

-- Called when the chat box text has changed.
function MOUNT:ChatBoxTextChanged(previousText, newText)
	local prefix = nexus.config.Get("command_prefix"):Get();
	
	if (string.sub(newText, 1, string.len(prefix) + 6) == prefix.."radio ") then
		if (string.sub(previousText, 1, string.len(prefix) + 6) != prefix.."radio ") then
			RunConsoleCommand("nx_typing_start", "r");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 3) == prefix.."me ") then
		if (string.sub(previousText, 1, string.len(prefix) + 3) != prefix.."me ") then
			RunConsoleCommand("nx_typing_start", "p");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 3) == prefix.."pm ") then
		if (string.sub(previousText, 1, string.len(prefix) + 3) != prefix.."pm ") then
			RunConsoleCommand("nx_typing_start", "o");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 2) == prefix.."w ") then
		if (string.sub(previousText, 1, string.len(prefix) + 2) != prefix.."w ") then
			RunConsoleCommand("nx_typing_start", "w");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 2) == prefix.."y ") then
		if (string.sub(previousText, 1, string.len(prefix) + 2) != prefix.."y ") then
			RunConsoleCommand("nx_typing_start", "y");
		end;
	elseif (string.sub(newText, 1, 3) == "// ") then
		if (string.sub(previousText, 1, 3) != prefix.."// ") then
			RunConsoleCommand("nx_typing_start", "o");
		end;
	elseif (string.sub(newText, 1, 4) == ".// ") then
		if (string.sub(previousText, 1, 4) != prefix..".// ") then
			RunConsoleCommand("nx_typing_start", "o");
		end;
	elseif (string.len(newText) >= 4 and string.len(previousText) < 4) then
		RunConsoleCommand("nx_typing_start", "n");
	end;
end;