--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player's data stream info should be sent.
function PLUGIN:PlayerSendDataStreamInfo(player)
	if (#self.mapScenes > 0) then
		player.mapScene = self.mapScenes[ math.random(1, #self.mapScenes) ];
		
		if (player.mapScene) then
			openAura:StartDataStream(player, "MapScene", player.mapScene);
		end;
	end;
end;

-- Called when a player's visibility should be set up.
function PLUGIN:SetupPlayerVisibility(player)
	if (player.mapScene) then
		AddOriginToPVS(player.mapScene.position);
	end;
end;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	PLUGIN:LoadMapScenes();
end;