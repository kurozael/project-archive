--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

function Sandbox:OnInitialize()
	for k, v in pairs(_player.GetAll()) do
		v:Spawn();
	end;
end;

function Sandbox:OnUnloaded()
	game.CleanUpMap();
end;

function Sandbox:PlayerShouldTakeDamage(player, attacker)
	return Crow.BaseClass:PlayerShouldTakeDamage(player, attacker);
end;

function Sandbox:DoPlayerDeathThink(player)
	return Crow.BaseClass:PlayerDeathThink(player);
end;