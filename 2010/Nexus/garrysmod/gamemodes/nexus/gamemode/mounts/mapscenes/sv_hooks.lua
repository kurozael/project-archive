--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when a player's data stream info should be sent.
function MOUNT:PlayerSendDataStreamInfo(player)
	if (#self.mapScenes > 0) then
		player.mapScene = self.mapScenes[ math.random(1, #self.mapScenes) ];
		
		if (player.mapScene) then
			NEXUS:StartDataStream(player, "MapScene", player.mapScene);
		end;
	end;
end;

-- Called when a player's visibility should be set up.
function MOUNT:SetupPlayerVisibility(player)
	if (player.mapScene) then
		AddOriginToPVS(player.mapScene.position);
	end;
end;