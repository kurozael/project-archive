--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.config:AddToSystem("intro_text_small", "The small text displayed for the introduction.");
Clockwork.config:AddToSystem("intro_text_big", "The big text displayed for the introduction.");
Clockwork.config:AddToSystem("Maximum zombies", "max_zombies", "The maximum number of zombies allowed to spawn.", 0, 100);
Clockwork.config:AddToSystem("Hunger Interval", "hunger_interval", "The interval (in seconds) in which Hunger decays.", 1, 10000);
Clockwork.config:AddToSystem("Thirst Interval", "thirst_interval", "The interval (in seconds) in which Thirst decays.", 1, 10000);
Clockwork.config:AddToSystem("Energy Interval", "energy_interval", "The interval (in seconds) in which Energy decays.", 1, 10000);
Clockwork.config:AddToSystem(
	"Maximum spawn interval", 
	"max_spawn_interval", 
	"The maximum amount of time between zombie spawns. (MUST BE HIGHER THAN MINIMUM AMOUNT!)", 
	0, 
	2400
);
Clockwork.config:AddToSystem(
	"Minimum spawn interval", 
	"min_spawn_interval", 
	"The minimum amount of time between zombie spawns. (MUST BE LOWER THAN MAXIMUM AMOUNT!)", 
	0, 
	2300
);
Clockwork.setting:AddCheckBox("Severance", "Render Halos", "cwRenderHalos", "Whether or not to render halo outlines (may cause FPS lag).");

-- A function to add a flash effect.
function Severance:AddFlashEffect()
	local curTime = CurTime();

	self.stunEffects[#self.stunEffects + 1] = {curTime + 10, 10};
	self.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end;

-- A function to get whether a text entry is being used.
function Severance:IsTextEntryBeingUsed()
	if (IsValid(self.textEntryFocused)) then
		if (self.textEntryFocused:IsVisible()) then
			return true;
		end;
	end;
end;

-- A function to make IC chat invisible to ghost mode zombies for no metagaming.
function Severance:ChatBoxAdjustInfo(info)
	if (Clockwork.Client:GetNetworkedVar("GhostMode", true)) then
		if (info.class == "ic" or info.class == "me" or info.class == "whisper"
		or info.class == "looc" or info.class == "it" or info.class == "yell") then
			info.visible = false
		end;
	end;
end;

-- A function to get the admin ESP info.
function Severance:GetAdminESPInfo(info)
	for k, v in ipairs(ents.FindByClass("cw_zombie_*")) do
		local health = v:Health();

		info[#info + 1] = {
			position = v:GetPos() + Vector(0, 0, 64),
			text = {
				{
					text = "Infected",
					color = Color(100, 150, 100, 255)
				},
				{
					text = "Type: " .. v.ZombieType,
					color = Color(100, 200, 100, 255)
				},
				{
					text = "Health: ["..health.." / 100]", 
					color = Clockwork:GetValueColor(health)
				}
			}
		};
	end;
end;

Clockwork.chatBox:RegisterClass("broadcast", "ic", function(info)
	if (IsValid(info.data.bc)) then
		local name = info.data.bc:GetNetworkedString("Name");
		
		if (name != "") then
			info.name = name;
		end;
	end;
	
	Clockwork.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

Clockwork.datastream:Hook("RebuildBusiness", function(data)
	if (Clockwork.menu:GetOpen() and Severance.businessPanel) then
		if (Clockwork.menu:GetActiveTab() == Severance.businessPanel) then
			Severance.businessPanel:Rebuild();
		end;
	end;
end);

usermessage.Hook("cwFrequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		Clockwork.kernel:RunCommand("SetFreq", text);
	end);
end);

usermessage.Hook("cwObjectPhysDesc", function(msg)
	local entity = msg:ReadEntity();
	
	if (IsValid(entity)) then
		Derma_StringRequest("Description", "What is the physical description of this object?", nil, function(text)
			Clockwork.kernel:StartDataStream("ObjectPhysDesc", {text, entity});
		end);
	end;
end);

usermessage.Hook("cwFlashed", function(msg)
	Severance:AddFlashEffect();
end);

usermessage.Hook("cwClearEffects", function(msg)
	Severance.stunEffects = {};
	Severance.flashEffect = nil;
end);