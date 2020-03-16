--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ 
	We store in the gamemode table so that when it unloads, it automatically cleans up
	any globals that would have otherwise been needless outside of the gamemode.
--]]

--[[ Team Enumerations --]]
CrowBall._TEAM_BLUE = 1;
CrowBall._TEAM_RED = 2;