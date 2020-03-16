--[[
Name: "sv_hint.lua".
Product: "nexus".
--]]

nexus.hint = {};
nexus.hint.stored = {};

-- A function to add a new hint.
function nexus.hint.Add(name, text, Callback)
	nexus.hint.stored[name] = {
		Callback = Callback,
		text = text
	};
end;

-- A function to remove a hint.
function nexus.hint.Remove(name)
	nexus.hint.stored[name] = nil;
end;

-- A function to find a hint.
function nexus.hint.Find(name)
	return nexus.hint.stored[name];
end;

-- A function to distribute a hint.
function nexus.hint.Distribute()
	local hintText, Callback = nexus.hint.Get();
	local hintInterval = nexus.config.Get("hint_interval"):Get();
	
	if (hintText) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v:HasInitialized() and v:GetInfoNum("nx_showhints", 1) == 1) then
				if ( !v:IsViewingStarterHints() ) then
					if (!Callback or Callback(v) != false) then
						nexus.hint.Send(v, hintText, 4, nil, true);
					end;
				end;
			end;
		end;
	end;
end;

-- A function to send a hint to a player.
function nexus.hint.Send(player, text, delay, color, noSound)
	NEXUS:StartDataStream( player, "Hint", {text = NEXUS:ParseData(text), delay = delay, color = color, noSound = noSound} );
end;

-- A function to send a hint to each player.
function nexus.hint.SendAll(text, delay, color)
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			nexus.hint.Send(v, text, delay, color);
		end;
	end;
end;

-- A function to get a hint.
function nexus.hint.Get()
	local hints = {};
	
	for k, v in pairs(nexus.hint.stored) do
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

nexus.hint.Add("OOC", "Type // before your message to talk out-of-character.");
nexus.hint.Add("LOOC", "Type .// or [[ before your message to talk out-of-character locally.");
nexus.hint.Add("Ducking", "Toggle ducking by holding 'sprint' and pressing 'walk' while standing still.");
nexus.hint.Add("Jogging", "Toggle jogging by pressing 'walk' while moving.");
nexus.hint.Add("Directory", "Hold down 'tab' and click *name_directory* to get help.");
nexus.hint.Add("F1 Hotkey", "Press F1 or hold down 'tab' to view the menu.");
nexus.hint.Add("F2 Hotkey", "Press F2 while looking at a door to view the its menu.");

nexus.hint.Add("Context Menu", "Hold 'context' and click on an entity to open its menu.", function(player)
	return !nexus.config.Get("use_opens_entity_menus"):Get();
end);
nexus.hint.Add("Entity Menu", "Press 'use' on an entity to open its menu.", function(player)
	return nexus.config.Get("use_opens_entity_menus"):Get();
end);
nexus.hint.Add("PhysDesc", "Change your character's physical description by typing $command_prefix$CharPhysDesc.", function(player)
	return nexus.command.Get("CharPhysDesc") != nil;
end);
nexus.hint.Add("Give Name", "Press F2 to allow characters within a specific range to recognise you.", function(player)
	return nexus.config.Get("recognise_system"):Get();
end);
nexus.hint.Add("Raise Weapon", "Hold 'reload' to raise or lower your current weapon.", function(player)
	return nexus.config.Get("raised_weapon_system"):Get();
end);
nexus.hint.Add("Target Recognises", "A character's name will flash white if they do not recognise you.", function(player)
	return nexus.config.Get("recognise_system"):Get();
end);