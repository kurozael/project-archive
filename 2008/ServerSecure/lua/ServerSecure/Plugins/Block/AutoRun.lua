local Plugin = SS.Plugins:New("Block")

// When player spawns

function Plugin.PlayerSpawn(Player)
	Player:SetCollisionGroup(11)
end

Plugin:Create()