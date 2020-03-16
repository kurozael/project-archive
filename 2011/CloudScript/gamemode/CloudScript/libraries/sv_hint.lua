--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.hint = {};
CloudScript.hint.stored = {};

-- A function to add a new hint.
function CloudScript.hint:Add(name, text, Callback)
	self.stored[name] = {
		Callback = Callback,
		text = text
	};
end;

-- A function to remove a hint.
function CloudScript.hint:Remove(name)
	self.stored[name] = nil;
end;

-- A function to find a hint.
function CloudScript.hint:Find(name)
	return self.stored[name];
end;

-- A function to distribute a hint.
function CloudScript.hint:Distribute()
	local hintText, Callback = self:Get();
	local hintInterval = CloudScript.config:Get("hint_interval"):Get();
	
	if (hintText) then
		for k, v in ipairs( _player.GetAll() ) do
			if (v:HasInitialized() and v:GetInfoNum("cloud_showhints", 1) == 1) then
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
function CloudScript.hint:Send(player, text, delay, color, noSound)
	CloudScript:StartDataStream( player, "Hint", {text = CloudScript:ParseData(text), delay = delay, color = color, noSound = noSound} );
end;

-- A function to send a hint to each player.
function CloudScript.hint:SendAll(text, delay, color)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			self:Send(v, text, delay, color);
		end;
	end;
end;

-- A function to get a hint.
function CloudScript.hint:Get()
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

CloudScript.hint:Add("OOC", "Type // before your message to talk out-of-character.");
CloudScript.hint:Add("LOOC", "Type .// or [[ before your message to talk out-of-character locally.");
CloudScript.hint:Add("Ducking", "Toggle ducking by holding :+speed: and pressing :+walk: while standing still.");
CloudScript.hint:Add("Jogging", "Toggle jogging by pressing :+walk: while moving.");
CloudScript.hint:Add("Directory", "Hold down :+showscores: and click *name_directory* to get help.");
CloudScript.hint:Add("F1 Hotkey", "Hold :gm_showhelp: to view your character and roleplay information.");
CloudScript.hint:Add("F2 Hotkey", "Press :gm_showteam: while looking at a door to view the door menu.");
CloudScript.hint:Add("Tab Hotkey", "Press :+showscores: to view the main menu, or hold :+showscores: to temporarily view it.");

CloudScript.hint:Add("Context Menu", "Hold :+menu_context: and click on an entity to open its menu.", function(player)
	return !CloudScript.config:Get("use_opens_entity_menus"):Get();
end);
CloudScript.hint:Add("Entity Menu", "Press :+use: on an entity to open its menu.", function(player)
	return CloudScript.config:Get("use_opens_entity_menus"):Get();
end);
CloudScript.hint:Add("Phys Desc", "Change your character's physical description by typing $command_prefix$CharPhysDesc.", function(player)
	return CloudScript.command:Get("CharPhysDesc") != nil;
end);
CloudScript.hint:Add("Give Name", "Press :gm_showteam: to allow characters within a specific range to recognise you.", function(player)
	return CloudScript.config:Get("recognise_system"):Get();
end);
CloudScript.hint:Add("Raise Weapon", "Hold :+reload: to raise or lower your weapon.", function(player)
	return CloudScript.config:Get("raised_weapon_system"):Get();
end);
CloudScript.hint:Add("Target Recognises", "A character's name will flash white if they do not recognise you.", function(player)
	return CloudScript.config:Get("recognise_system"):Get();
end);