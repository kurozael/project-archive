local Plugin = SS.Plugins:New("Spawnpoint")

// When player spawns

function Plugin.PlayerSpawn(Player)
	if (Player.Spawnpoint) then
		Player:SetPos(Player.Spawnpoint)
	end
end

// Chat command

local PlayerSpawnpoint = SS.Commands:New("PlayerSpawnpoint")

function PlayerSpawnpoint.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		local Trace = Player:TraceLine()
		
		local Position = Trace.HitPos + Vector(0, 0, 16)
		
		Person.Spawnpoint = Position
		
		SS.PlayerMessage(Player, "You have changed "..Person:Name().."'s custom spawnpoint!", 0)
		
		if (Player == Person) then return end
		
		SS.PlayerMessage(Person, Player:Name().." changed your default spawnpoint!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

PlayerSpawnpoint:Create(PlayerSpawnpoint.Command, {"administrator", "playerspawnpoint"}, "Change somebodies default spawnpoint", "<Player>", 1, " ")

// Chat command

local Spawnpoint = SS.Commands:New("Spawnpoint")

function Spawnpoint.Command(Player, Args)
	if (SS.Purchase.Has(Player, "Commands [Spawnpoint]")) then
		local Trace = Player:TraceLine()
		
		local Position = Trace.HitPos + Vector(0, 0, 16)
		
		Player.Spawnpoint = Position
		
		SS.PlayerMessage(Player, "You have set your own custom spawnpoint!", 0)
	else
		SS.PlayerMessage(Player, "You need to purchase this command, type "..SS.Commands.Prefix().."purchase", 1)
	end
end

Spawnpoint:Create(Spawnpoint.Command, {"basic"}, "Set a spawnpoint for yourself")

// Add the spawnpoint purchase

local Spawnpoint = SS.Purchase:New("Commands [Spawnpoint]", "Custom Spawnpoint")

function Spawnpoint.PlayerGivenPurchase(Player, Item, Friendly)
	if (Friendly == "Custom Spawnpoint") then
		SS.PlayerMessage(Player, "Type "..SS.Commands.Prefix().."spawnpoint to set a custom spawnpoint to where you are looking", 0)
	end
end

SS.Hooks.Add("Spawnpoint.PlayerGivenPurchase", "PlayerGivenPurchase", Spawnpoint.PlayerGivenPurchase)

Spawnpoint:Create(5, {"moderator"}, "Commands", "Set your own custom spawnpoint")

Plugin:Create()