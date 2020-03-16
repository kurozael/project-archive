--[[
Name: "cl_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when the local player should be drawn.
function MOUNT:ShouldDrawLocalPlayer()
	if ( self:IsPlayerInStance(g_LocalPlayer) ) then
		return true;
	end;
end;

-- Called when a player's animation is updated.
function MOUNT:UpdateAnimation(player)
	if ( self:IsPlayerInStance(player) ) then
		player:SetRenderAngles( player:GetSharedVar("sh_StanceAngles") );
	end;
end;

-- Called when the calc view table should be adjusted.
function MOUNT:CalcViewAdjustTable(view)
	if ( self:IsPlayerInStance(g_LocalPlayer) ) then
		local defaultOrigin = view.origin;
		local idleStance = g_LocalPlayer:GetSharedVar("sh_StanceIdle");
		local traceLine = nil;
		local headBone = "ValveBiped.Bip01_Head1";
		local position = g_LocalPlayer:EyePos();
		local angles = g_LocalPlayer:GetSharedVar("sh_StanceAngles"):Forward();
		
		if ( string.find(g_LocalPlayer:GetModel(), "vortigaunt") ) then
			headBone = "ValveBiped.Head";
		end;
		
		if (idleStance) then
			local bonePosition = g_LocalPlayer:GetBonePosition( g_LocalPlayer:LookupBone(headBone) );
			
			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 8);
			end;
		end;
		
		if (defaultOrigin) then
			if (idleStance) then
				traceLine = util.TraceLine( {
					start = position,
					endpos = position + (angles * 16);
					filter = g_LocalPlayer
				} );
			else
				traceLine = util.TraceLine( {
					start = position,
					endpos = position - (angles * 128);
					filter = g_LocalPlayer
				} );
			end;
			
			if (traceLine.Hit) then
				view.origin = traceLine.HitPos + (angles * 4);
				
				if (view.origin:Distance(position) <= 32) then
					view.origin = defaultOrigin;
				end;
			else
				view.origin = traceLine.HitPos;
			end;
		end;
	end;
end;