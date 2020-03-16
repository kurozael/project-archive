--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

function Hangout:DoPlayerDeathThink(player)
	return true;
end;

function Hangout:PostPlayerSpawn(player)
	player:StripWeapons();
end;