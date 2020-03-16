--[[
Name: "cl_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has initialized.
function MOUNT:KuroScriptInitialized()
	KS_CONVAR_RAINEFFECTS = kuroScript.frame:CreateClientConVar("ks_raineffects", 1, true, true);
end;

-- Called each tick.
function MOUNT:Tick()
	if ( kuroScript.frame:SharedVarsHaveInitialized() ) then
		local precipitation = kuroScript.frame:GetSharedVar("ks_Precipitation");
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if ( self.precipitation[precipitation] ) then
			if (!self.nextRain or curTime >= self.nextRain) then
				self.nextRain = curTime + 7;
				
				-- Check if a statement is true.
				if (KS_CONVAR_RAINEFFECTS:GetInt() == 1) then
					local effectData = EffectData();
						effectData:SetMagnitude(self.precipitation[precipitation].amount);
					util.Effect("ks_rain", effectData, true, true);
				end;
				
				-- Check if a statement is true.
				if (self.precipitation[precipitation].amount >= 10) then
					if (!self.nextThunder or curTime > self.nextThunder) then
						surface.PlaySound("ambient/atmosphere/thunder"..math.random(1, 4)..".wav");
						
						-- Set some information.
						self.nextThunder = curTime + math.random(30, 60);
					end;
				end;
				
				-- Check if a statement is true.
				if (self.precipitation[precipitation].sound) then
					if (self.previousPrecipitation != precipitation) then
						if (self.precipitationSound) then
							self.precipitationSound:FadeOut(1);
						end;
						
						-- Set some information.
						self.previousPrecipitation = precipitation;
						self.precipitationSound = CreateSound(g_LocalPlayer, self.precipitation[precipitation].sound);
						self.precipitationSound:Play();
					end;
				end;
			end
		elseif (self.precipitationSound) then
			self.previousPrecipitation = nil;
			self.precipitationSound:FadeOut(1);
			self.precipitationSound = nil;
			self.lastVolume = nil;
		end;
		
		-- Check if a statement is true.
		if (!self.nextSoundCheck or curTime >= self.nextSoundCheck) then
			if (self.precipitationSound) then
				local position = g_LocalPlayer:EyePos();
				local trace = {
					start = position,
					endpos = position + Vector(0, 0, 16384),
					mask = MASK_NPCWORLDSTATIC
				};
				
				-- Set some information.
				trace = util.TraceLine(trace);
				
				-- Check if a statement is true.
				if (!trace.HitSky) then
					if (!self.lastVolume) then
						self.lastVolume = {volume = 0, pitch = 50};
					end;
					
					-- Check if a statement is true.
					if (self.lastVolume.volume == 0.4 and self.lastVolume.pitch == 50) then
						self.lastVolume.volume = math.Approach(self.lastVolume.volume, 0, 0.05);
					else
						self.lastVolume.volume = math.Approach(self.lastVolume.volume, 0.4, 0.1);
						self.lastVolume.pitch = math.Approach(self.lastVolume.pitch, 50, 10);
					end;
				else
					if (!self.lastVolume) then
						self.lastVolume = {volume = 1, pitch = 100};
					end;
					
					-- Set some information.
					self.lastVolume.volume = math.Approach(self.lastVolume.volume, 1, 0.1);
					self.lastVolume.pitch = math.Approach(self.lastVolume.pitch, 100, 10);
				end;
				
				-- Check if a statement is true.
				if ( g_LocalPlayer:IsRagdolled(RAGDOLL_FALLENOVER) ) then
					self.precipitationSound:ChangeVolume(0);
				else
					self.precipitationSound:SetSoundLevel(0.4);
					self.precipitationSound:ChangeVolume(self.lastVolume.volume);
					self.precipitationSound:ChangePitch(self.lastVolume.pitch);
				end;
				
				-- Set some information.
				self.nextSoundCheck = curTime + 2;
			end;
		end;
	end;
end;