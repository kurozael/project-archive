--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called after a player has been drawn.
function PLUGIN:PostPlayerDraw(player)
	local colorWhite = openAura.option:GetColor("white");
	local eyeAngles = openAura.Client:EyeAngles();
	local typing = player:GetSharedVar("typing");
	local font = openAura.option:GetFont("large_3d_2d");
	
	if (typing != 0) then
		local fadeDistance = 192;
		
		if (typing == TYPING_YELL or typing == TYPING_PERFORM) then
			fadeDistance = openAura.config:Get("talk_radius"):Get() * 2;
		elseif (typing == TYPING_WHISPER) then
			fadeDistance = openAura.config:Get("talk_radius"):Get() / 3;
			
			if (fadeDistance > 80) then
				fadeDistance = 80;
			end;
		else
			fadeDistance = openAura.config:Get("talk_radius"):Get();
		end;
		
		if (player:GetPos():Distance( openAura.Client:GetPos() ) <= fadeDistance) then
			if ( player:Alive() and !player:IsRagdolled(RAGDOLL_FALLENOVER) ) then
				if (player:InVehicle() or player:GetMoveType() != MOVETYPE_NOCLIP) then
					local r, g, b, a = player:GetColor();
					local curTime = UnPredictedCurTime();
					
					if (player:GetMaterial() != "sprites/heatwave" and a != 0) then
						local alpha = openAura:CalculateAlphaFromDistance(fadeDistance, openAura.Client, player);
						local position = openAura.plugin:Call("GetPlayerTypingDisplayPosition", player);
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
						
						if (position) then
							local drawText = "";
							
							position = position + eyeAngles:Up();
							eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90);
							eyeAngles:RotateAroundAxis(eyeAngles:Right(), 90);
							
							if (typing == TYPING_WHISPER) then
								drawText = "Whispering...";
							elseif (typing == TYPING_PERFORM) then
								drawText = "Performing...";
							elseif (typing == TYPING_NORMAL) then
								drawText = "Talking...";
							elseif (typing == TYPING_RADIO) then
								drawText = "Radioing...";
							elseif (typing == TYPING_YELL) then
								drawText = "Yelling...";
							elseif (typing == TYPING_OOC) then
								drawText = "Typing...";
							end;
							
							if (drawText != "") then
								local textWidth, textHeight = openAura:GetCachedTextSize(openAura.option:GetFont("main_text"), drawText);
								
								if (textWidth and textHeight) then
									cam.Start3D2D(position, Angle(0, eyeAngles.y, 90), 0.03);
										openAura:OverrideMainFont(font);
											openAura:DrawInfo(drawText, 0, 0, colorWhite, alpha);
										openAura:OverrideMainFont(false);
									cam.End3D2D();
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called to get whether a player should move their mouth.
function PLUGIN:PlayerShouldMoveMouth(player)
	local typing = player:GetSharedVar("typing");
	
	if (typing != 0) then
		return true;
	end;
end;

-- Called when the chat box is closed.
function PLUGIN:ChatBoxClosed(textTyped)
	if (textTyped) then
		RunConsoleCommand("aura_typing_finish", "1");
	else
		RunConsoleCommand("aura_typing_finish");
	end;
end;

-- Called when the chat box text has changed.
function PLUGIN:ChatBoxTextChanged(previousText, newText)
	local prefix = openAura.config:Get("command_prefix"):Get();
	
	if (string.sub(newText, 1, string.len(prefix) + 6) == prefix.."radio ") then
		if (string.sub(previousText, 1, string.len(prefix) + 6) != prefix.."radio ") then
			RunConsoleCommand("aura_typing_start", "r");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 3) == prefix.."me ") then
		if (string.sub(previousText, 1, string.len(prefix) + 3) != prefix.."me ") then
			RunConsoleCommand("aura_typing_start", "p");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 3) == prefix.."pm ") then
		if (string.sub(previousText, 1, string.len(prefix) + 3) != prefix.."pm ") then
			RunConsoleCommand("aura_typing_start", "o");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 2) == prefix.."w ") then
		if (string.sub(previousText, 1, string.len(prefix) + 2) != prefix.."w ") then
			RunConsoleCommand("aura_typing_start", "w");
		end;
	elseif (string.sub(newText, 1, string.len(prefix) + 2) == prefix.."y ") then
		if (string.sub(previousText, 1, string.len(prefix) + 2) != prefix.."y ") then
			RunConsoleCommand("aura_typing_start", "y");
		end;
	elseif (string.sub(newText, 1, 3) == "// ") then
		if (string.sub(previousText, 1, 3) != prefix.."// ") then
			RunConsoleCommand("aura_typing_start", "o");
		end;
	elseif (string.sub(newText, 1, 4) == ".// ") then
		if (string.sub(previousText, 1, 4) != prefix..".// ") then
			RunConsoleCommand("aura_typing_start", "o");
		end;
	elseif (string.len(newText) >= 4 and string.len(previousText) < 4) then
		RunConsoleCommand("aura_typing_start", "n");
	end;
end;