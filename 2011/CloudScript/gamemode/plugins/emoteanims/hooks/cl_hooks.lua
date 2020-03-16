--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the local player should be drawn.
function PLUGIN:ShouldDrawLocalPlayer()
	if ( self:IsPlayerInStance(CloudScript.Client) ) then
		return true;
	end;
end;

-- Called when a player's animation is updated.
function PLUGIN:UpdateAnimation(player)
	if ( self:IsPlayerInStance(player) ) then
		player:SetRenderAngles( player:GetSharedVar("stanceAngles") );
	end;
end;

-- Called when the calc view table should be adjusted.
function PLUGIN:CalcViewAdjustTable(view)
	if ( self:IsPlayerInStance(CloudScript.Client) ) then
		local defaultOrigin = view.origin;
		local idleStance = CloudScript.Client:GetSharedVar("stanceIdle");
		local traceLine = nil;
		local headBone = "ValveBiped.Bip01_Head1";
		local position = CloudScript.Client:EyePos();
		local angles = CloudScript.Client:GetSharedVar("stanceAngles"):Forward();
		
		if ( string.find(CloudScript.Client:GetModel(), "vortigaunt") ) then
			headBone = "ValveBiped.Head";
		end;
		
		if (idleStance) then
			local bonePosition = CloudScript.Client:GetBonePosition( CloudScript.Client:LookupBone(headBone) );
			
			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 8);
			end;
		end;
		
		if (defaultOrigin) then
			if (idleStance) then
				traceLine = util.TraceLine( {
					start = position,
					endpos = position + (angles * 16);
					filter = CloudScript.Client
				} );
			else
				traceLine = util.TraceLine( {
					start = position,
					endpos = position - (angles * 128);
					filter = CloudScript.Client
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