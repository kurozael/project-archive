--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when the client initializes.
function MOUNT:Initialize()
	NX_CONVAR_SHOWAREAS = NEXUS:CreateClientConVar("nx_showareas", 1, true, true);
end;

-- Called when the local player has entered an area.
function MOUNT:PlayerEnteredArea(name, minimum, maximum)
	NEXUS:StartDataStream( "EnteredArea", {name, minimum, maximum} );
end;

-- Called just after the opaque renderables have been drawn.
function MOUNT:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (drawingSkybox) then
		return;
	end;
	
	local colorWhite = nexus.schema.GetColor("white");
	local eyeAngles = EyeAngles();
	local curTime = UnPredictedCurTime();
	local eyePos = EyePos();
	local font = nexus.schema.GetFont("large_3d_2d");
	
	NEXUS:OverrideMainFont(font);
		cam.Start3D(eyePos, eyeAngles);
			for k, v in pairs(self.activeDisplays) do
				local areaTable = v.areaTable;
				
				cam.Start3D2D(areaTable.position, areaTable.angles, (areaTable.scale or 1) * 0.2);
					NEXUS:DrawInfo(areaTable.name, 0, 0, colorWhite, v.alpha, nil, function(x, y, width, height)
						return x, y - (height / 2);
					end, 3);
				cam.End3D2D();
				
				if (v.target == 255) then
					v.alpha = math.Clamp(1 - ( (v.fadeTime - curTime) / 4 ), 0, 1) * 255;
					
					if (v.alpha == 255) then
						v.reverseFade = curTime + 6;
						v.fadeTime = nil;
						v.target = 0;
					end;
				elseif (curTime >= v.reverseFade) then
					if (!v.fadeTime) then
						v.fadeTime = curTime + 2;
					end;
					
					v.alpha = 255 - (math.Clamp(1 - ( (v.fadeTime - curTime) / 2 ), 0, 1) * 255);
					
					if (v.alpha == 0) then
						self.activeDisplays[k] = nil;
					end;
				end;
			end;
		cam.End3D();
	NEXUS:OverrideMainFont(false);
end;

-- Called each tick.
function MOUNT:Tick()
	if ( IsValid(g_LocalPlayer) and g_LocalPlayer:HasInitialized() ) then
		local lastAreaDisplay = self.currentAreaDisplay;
		local didLeave = false;
		local curTime = UnPredictedCurTime();
		
		if (!self.nextCheckAreaDisplays or curTime >= self.nextCheckAreaDisplays) then
			self.nextCheckAreaDisplays = curTime + 1;
			
			for k, v in pairs(self.areaDisplays) do
				if ( nexus.entity.IsInBox(g_LocalPlayer, v.minimum, v.maximum) ) then
					if (self.currentAreaDisplay != v.name) then
						if (!v.expires) then
							self.currentAreaDisplay = v.name;
							
							nexus.mount.Call("PlayerEnteredArea", v.name, v.minimum, v.maximum);
							
							if (lastAreaDisplay) then
								nexus.mount.Call("PlayerExitedArea", lastAreaDisplay, v.name);
							end;
						end;
						
						if (NX_CONVAR_SHOWAREAS:GetInt() == 1 or v.expires) then
							self:AddAreaDisplayDisplay(v);
						end;
						
						self:SetExpired(k);
					end;
					
					return;
				elseif (lastAreaDisplay == v.name) then
					didLeave = v.name;
				end;
			end;
			
			if (didLeave) then
				nexus.mount.Call("PlayerExitedArea", didLeave);
			end;
		end;
	end;
end;