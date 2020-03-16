--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the Schema variable.
--]]
Schema:SetGlobalAlias("Severance");

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
Clockwork.kernel:IncludePrefixed("sv_schema.lua");
Clockwork.kernel:IncludePrefixed("cl_schema.lua");
Clockwork.kernel:IncludePrefixed("sh_hooks.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("cl_theme.lua");

--[[ Misc option keys. --]]
Clockwork.option:SetKey("default_date", {month = 1, year = 2013, day = 1});
Clockwork.option:SetKey("default_time", {minute = 0, hour = 0, day = 1});
Clockwork.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");


Clockwork.config:ShareKey("intro_text_small");
Clockwork.config:ShareKey("intro_text_big");

--[[ Quiz. --]]
Clockwork.quiz:SetEnabled(true);
Clockwork.quiz:AddQuestion("Do you understand that roleplaying is slow paced and relaxed?", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("Can you type properly, using capital letters and full-stops?", 2, "yes i can", "Yes, I can.");
Clockwork.quiz:AddQuestion("You do not need weapons to roleplay, do you understand?", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("You do not need items to roleplay, do you understand?", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("What do you think serious roleplaying is about?", 2, "Collecting items and upgrades.", "Developing your character.");

--[[ Flags, there shouldn't be anymore. --]]
Clockwork.flag:Add("y", "Commander", "This flag is meant for C.E.D.A. commanders and administrators.");
Clockwork.flag:Add("S", "Trader", "This flag is meant for traders in the city.");

--[[ Stun Effects. --]]
if (CLIENT) then
	Severance.stunEffects = Severance.stunEffects or {};
else
	Severance.zombieSpawns = Severance.zombieSpawns or {};
	Severance.nextZombieSpawn = Severance.nextZombieSpawn or 0;
end;

for k, v in pairs(cwFile.Find("models/pmc/pmc_4/*.mdl", "GAME")) do
	Clockwork.animation:AddMaleHumanModel("models/pmc/pmc_4/"..v);
end;

--[[ Groups. --]]
local groups = {34, 35, 36, 37, 38, 39, 40, 41};

for k, v in pairs(groups) do
	local groupName = "group"..v;
	
	for k2, v2 in pairs(cwFile.Find("models/humans/"..groupName.."/*.*", "GAME")) do
		local fileName = string.lower(v2);
		
		if (string.find(fileName, "female")) then
			Clockwork.animation:AddFemaleHumanModel("models/humans/"..groupName.."/"..fileName);
		else
			Clockwork.animation:AddMaleHumanModel("models/humans/"..groupName.."/"..fileName);
		end;
	end;
end;

-- A function to check if a player is Zombie.
function Severance:PlayerIsZombie(player)
	return (IsValid(player) and player:GetFaction() == FACTION_INFECTED);
end;