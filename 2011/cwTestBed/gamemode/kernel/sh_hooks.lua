--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the Clockwork shared variables are added.
function Clockwork.schema:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("Stamina", true);
	playerVars:Number("NextQuit", true);
	playerVars:String("Group");
	playerVars:Bool("BeingTied", true);
	playerVars:Bool("Thermal", true);
	playerVars:Bool("IsTied");
end;