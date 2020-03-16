--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when the Clockwork shared variables are added.
function Severance:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("IsTied");
	playerVars:Bool("PermaKilled", true);
	playerVars:Number("Hunger", true);
	playerVars:Number("Thirst", true);
	playerVars:Number("Energy", true);
end;

-- A function to add multiple pitched voices in one for zombies.
function Severance:AddZombieVoice(command, phrase, sound, pitch, volume)
	Clockwork.voices:Add("Infected", command, phrase, sound, nil, nil, pitch or 30, volume);
end;

-- Called when the voice library needs to register voice commands.
function Severance:RegisterVoices()
	for i = 1, 3 do
		Severance:AddZombieVoice("pain"..i, nil, "npc/zombie_poison/pz_pain"..i..".wav");
	end;

	for i = 2, 7 do
		Severance:AddZombieVoice("idle"..i, nil, "npc/zombie/zombie_voice_idle"..i..".wav");
	end;

	Severance:AddZombieVoice("call", nil, "npc/zombie_poison/pz_call1.wav", 120);
end;