--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the Clockwork shared variables are added.
function Schema:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("HideStealth");
	playerVars:Number("Stamina", true);
	playerVars:Number("NextQuit", true);
	playerVars:Number("Rank");
	playerVars:String("Group");
	playerVars:Entity("SafeZone");
	playerVars:Bool("BeingTied", true);
	playerVars:Bool("Thermal", true);
	playerVars:Bool("Thirsty", true);
	playerVars:Bool("Hungry", true);
	playerVars:Bool("IsTied");
end;