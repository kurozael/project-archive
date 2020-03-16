--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity() self:LoadDynamicAdverts(); end;

-- Called when a player's data stream info should be sent.
function PLUGIN:PlayerSendDataStreamInfo(player)
	openAura:StartDataStream(player, "DynamicAdverts", self.dynamicAdverts);
end;