--[[
Name: "sv_hint.lua".
Product: "kuroScript".
--]]

kuroScript.hint = {};
kuroScript.hint.stored = {};

-- A function to add a new hint.
function kuroScript.hint.Add(name, text, callback)
	kuroScript.hint.stored[name] = {
		callback = callback,
		text = text
	};
end;

-- A function to remove a hint.
function kuroScript.hint.Remove(name, text, callback)
	kuroScript.hint.stored[name] = nil;
end;

-- A function to distribute a hint.
function kuroScript.hint.Distribute()
	local hint, callback = kuroScript.hint.Get();
	local listeners = {};
	local k, v;
	
	-- Check if a statement is true.
	if (hint) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v:HasInitialized() and v:GetInfoNum("ks_showhints", 0) == 1) then
				if (!callback or callback(v) != false) then
					listeners[#listeners + 1] = v;
				end;
			end;
		end;
		
		-- Notify the player.
		kuroScript.player.Notify(listeners, hint, 3);
	end;
end;

-- A function to get a hint.
function kuroScript.hint.Get()
	local hints = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.hint.stored) do
		if (!v.callback or v.callback() != false) then
			hints[#hints + 1] = v;
		end;
	end;
	
	-- Check if a statement is true.
	if (#hints > 0) then
		local hint = hints[ math.random(1, #hints) ];
		
		-- Return the hint.
		return kuroScript.frame:ParseData(hint.text), hint.callback;
	end;
end;

-- Add some hints.
kuroScript.hint.Add("OOC", "Do you need to talk out-of-character? Type // before your message.");
kuroScript.hint.Add("LOOC", "Do you need to talk out-of-character, locally? Type .// before your message.");
kuroScript.hint.Add("Admins", "The admins can see everything that you do - you can not get away with anything.");
kuroScript.hint.Add("Ducking", "You can toggle ducking by holding 'Sprint' and pressing 'Walk' while standing still.");
kuroScript.hint.Add("Jogging", "You can toggle jogging by pressing 'Walk' while moving.");
kuroScript.hint.Add("Twisted", "Do the player models appear twisted? Try tabbing out and then back in to the game.");
kuroScript.hint.Add("Disable", "You can disable these hints by going to Settings in the *NAME_MENU*.");
kuroScript.hint.Add("F1 Hotkey", "Press F1 or open the scoreboard to view the *NAME_MENU*.");
kuroScript.hint.Add("F2 Hotkey", "Press F2 while looking at a door to view the door menu.");

-- Add some hints.
kuroScript.hint.Add("Details", "You can set details about your character by using $command_prefix$details.", function(player)
	return kuroScript.command.Get("details") != nil;
end);
kuroScript.hint.Add("Give Name", "Don't forget to tell the character your name after using $command_prefix$givename.", function(player)
	return kuroScript.config.Get("anonymous_system"):Get();
end);
kuroScript.hint.Add("Giving Name", "You can also give your name using $command_prefix$yellname or $command_prefix$whispername.", function(player)
	return kuroScript.config.Get("anonymous_system"):Get();
end);
kuroScript.hint.Add("Toggle Raised", "Say $command_prefix$toggleraised to raise or lower your weapon.", function(player)
	return kuroScript.config.Get("raised_weapon_system"):Get();
end);