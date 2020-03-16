--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.hint = {};
openAura.hint.stored = {};

-- A function to add a new hint.
function openAura.hint:Add(name, text, Callback)
	self.stored[name] = {
		Callback = Callback,
		text = text
	};
end;

-- A function to remove a hint.
function openAura.hint:Remove(name)
	self.stored[name] = nil;
end;

-- A function to find a hint.
function openAura.hint:Find(name)
	return self.stored[name];
end;

-- A function to distribute a hint.
function openAura.hint:Distribute()
	local hintText, Callback = self:Get();
	local hintInterval = openAura.config:Get("hint_interval"):Get();
	
	if (hintText) then
		for k, v in ipairs( _player.GetAll() ) do
			if (v:HasInitialized() and v:GetInfoNum("aura_showhints", 1) == 1) then
				if ( !v:IsViewingStarterHints() ) then
					if (!Callback or Callback(v) != false) then
						self:Send(v, hintText, 4, nil, true);
					end;
				end;
			end;
		end;
	end;
end;

-- A function to send a hint to a player.
function openAura.hint:Send(player, text, delay, color, noSound)
	openAura:StartDataStream( player, "Hint", {text = openAura:ParseData(text), delay = delay, color = color, noSound = noSound} );
end;

-- A function to send a hint to each player.
function openAura.hint:SendAll(text, delay, color)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			self:Send(v, text, delay, color);
		end;
	end;
end;

-- A function to get a hint.
function openAura.hint:Get()
	local hints = {};
	
	for k, v in pairs(self.stored) do
		if (!v.Callback or v.Callback() != false) then
			hints[#hints + 1] = v;
		end;
	end;
	
	if (#hints > 0) then
		local hint = hints[ math.random(1, #hints) ];
		
		if (hint) then
			return hint.text, hint.Callback;
		end;
	end;
end;

openAura.hint:Add("OOC", "Type // before your message to talk out-of-character.");
openAura.hint:Add("LOOC", "Type .// or [[ before your message to talk out-of-character locally.");
openAura.hint:Add("Ducking", "Toggle ducking by holding :+speed: and pressing :+walk: while standing still.");
openAura.hint:Add("Jogging", "Toggle jogging by pressing :+walk: while moving.");
openAura.hint:Add("Directory", "Hold down :+showscores: and click *name_directory* to get help.");
openAura.hint:Add("F1 Hotkey", "Hold :gm_showhelp: to view your character and roleplay information.");
openAura.hint:Add("F2 Hotkey", "Press :gm_showteam: while looking at a door to view the door menu.");
openAura.hint:Add("Tab Hotkey", "Press :+showscores: to view the main menu, or hold :+showscores: to temporarily view it.");

openAura.hint:Add("Context Menu", "Hold :+menu_context: and click on an entity to open its menu.", function(player)
	return !openAura.config:Get("use_opens_entity_menus"):Get();
end);
openAura.hint:Add("Entity Menu", "Press :+use: on an entity to open its menu.", function(player)
	return openAura.config:Get("use_opens_entity_menus"):Get();
end);
openAura.hint:Add("Phys Desc", "Change your character's physical description by typing $command_prefix$CharPhysDesc.", function(player)
	return openAura.command:Get("CharPhysDesc") != nil;
end);
openAura.hint:Add("Give Name", "Press :gm_showteam: to allow characters within a specific range to recognise you.", function(player)
	return openAura.config:Get("recognise_system"):Get();
end);
openAura.hint:Add("Raise Weapon", "Hold :+reload: to raise or lower your weapon.", function(player)
	return openAura.config:Get("raised_weapon_system"):Get();
end);
openAura.hint:Add("Target Recognises", "A character's name will flash white if they do not recognise you.", function(player)
	return openAura.config:Get("recognise_system"):Get();
end);