--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the Clockwork shared variables are added.
function Schema:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("Hunger", true);
	playerVars:Number("Thirst", true);
	playerVars:Number("Stars");
	playerVars:Number("IsTied");
	
	playerVars:Bool("BeingChloro", true);
	playerVars:Bool("SkullMask");
	playerVars:Bool("Withdrawal", true);
	playerVars:Bool("BeingTied", true);
	playerVars:Bool("Lottery", true);
	playerVars:Bool("Sensor", true);
	playerVars:Bool("Leader");
	
	playerVars:String("Alliance");
	playerVars:Entity("Disguise");
	playerVars:String("Crimes");
	
	globalVars:Number("NoWagesTime");
	globalVars:Number("Lottery");
	globalVars:String("Agenda");
end;