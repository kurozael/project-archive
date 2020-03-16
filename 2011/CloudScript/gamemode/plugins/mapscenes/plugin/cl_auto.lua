--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript:HookDataStream("MapScene", function(data)
	CloudScript.plugin:Get("Map Scenes").mapScene = data;
end);