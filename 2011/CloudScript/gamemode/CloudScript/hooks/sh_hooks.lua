--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the CloudScript shared variables are added.
function CloudScript:CloudScriptAddSharedVars(globalVars, playerVars)
	playerVars:Bool("targetRecognises", true);
	playerVars:Float("startActionTime");
	playerVars:Number("actionDuration");
	playerVars:Bool("weaponRaised");
	playerVars:Bool("initialized");
	playerVars:Number("forcedAnim");
	playerVars:Number("ragdolled");
	playerVars:Number("inventoryWeight", true);
	playerVars:Bool("fallenOver", true);
	playerVars:Number("maxHealth", true);
	playerVars:Number("maxArmor", true);
	playerVars:String("physDesc");
	playerVars:Entity("ragdoll");
	playerVars:Bool("banned", true);
	playerVars:Bool("jogging");
	playerVars:Number("drunk", true);
	playerVars:String("model", true);
	playerVars:Number("wages", true);
	playerVars:Number("cash", true);
	playerVars:Number("faction");
	playerVars:String("action");
	playerVars:Number("gender");
	playerVars:String("flags");
	playerVars:Name("name");
	playerVars:Number("key");

	globalVars:Bool("noMySQL");
	globalVars:Number("minute");
	globalVars:String("date");
	globalVars:Number("hour");
	globalVars:Number("day");
end;