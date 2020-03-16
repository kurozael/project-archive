--[[
Name: "sh_setting.lua".
Product: "kuroScript".
--]]

kuroScript.setting = {};
kuroScript.setting.stored = {};

-- A function to add a number slider setting.
function kuroScript.setting.AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, condition)
	local index = #kuroScript.setting.stored + 1;
	
	-- Set some information.
	kuroScript.setting.stored[index] = {
		condition = condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberSlider",
		text = text
	};
	
	-- Return the index.
	return index;
end;

-- A function to add a multi-choice setting.
function kuroScript.setting.AddMultiChoice(category, text, conVar, options, toolTip, condition)
	local index = #kuroScript.setting.stored + 1;
	
	-- Check if a statement is true.
	if (options) then
		table.sort(options, function(a, b) return a < b; end);
	else
		options = {};
	end;
	
	-- Set some information.
	kuroScript.setting.stored[index] = {
		condition = condition,
		category = category,
		toolTip = toolTip,
		options = options,
		conVar = conVar,
		class = "multiChoice",
		text = text
	};
	
	-- Return the index.
	return index;
end;

-- A function to add a number wang setting.
function kuroScript.setting.AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, condition)
	local index = #kuroScript.setting.stored + 1;
	
	-- Set some information.
	kuroScript.setting.stored[index] = {
		condition = condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberWang",
		text = text
	};
	
	-- Return the index.
	return index;
end;

-- A function to add a text entry setting.
function kuroScript.setting.AddTextEntry(category, text, conVar, toolTip, condition)
	local index = #kuroScript.setting.stored + 1;
	
	-- Set some information.
	kuroScript.setting.stored[index] = {
		condition = condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "textEntry",
		text = text
	};
	
	-- Return the index.
	return index;
end;

-- A function to add a check box setting.
function kuroScript.setting.AddCheckBox(category, text, conVar, toolTip, condition)
	local index = #kuroScript.setting.stored + 1;
	
	-- Set some information.
	kuroScript.setting.stored[index] = {
		condition = condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "checkBox",
		text = text
	};
	
	-- Return the index.
	return index;
end;

-- A function to remove a setting by its index.
function kuroScript.setting.RemoveByIndex(index)
	kuroScript.setting.stored[index] = nil;
end;

-- A function to remove a setting.
function kuroScript.setting.Remove(category, text, class, conVar)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.setting.stored) do
		if (!category or v.category == category) then
			if (!conVar or v.conVary == conVar) then
				if (!class or v.class == class) then
					if (!text or v.text == text) then
						kuroScript.setting.stored[k] = nil;
					end;
				end;
			end;
		end;
	end;
end;

-- Add some settings.
kuroScript.setting.AddNumberSlider("kuroScript", "Headbob Scale", "ks_headbobscale", 0, 1, 1, "The amount to scale the headbob by.");
kuroScript.setting.AddNumberSlider("Chat Box", "Maximum Chat Lines", "ks_maxchatlines", 1, 8, 0, "The maximum amount of chat lines shown at once.");

-- Add some settings.
kuroScript.setting.AddCheckBox("kuroScript", "Show kuroScript Log", "ks_showkuroscriptlog", "Whether or not to show you the kuroScript log in the console.", function()
	return g_LocalPlayer:IsAdmin() or g_LocalPlayer:IsUserGroup("operator");
end);

-- Add some settings.
kuroScript.setting.AddCheckBox("kuroScript", "Twelve Hour Clock", "ks_twelvehourclock", "Whether or not to show a twelve hour clock.");
kuroScript.setting.AddCheckBox("kuroScript", "Show Hints", "ks_showhints", "Whether or not to show you any hints.");
kuroScript.setting.AddCheckBox("Chat Box", "Show Timestamps", "ks_showtimestamps", "Whether or not to show you timestamps on messages.");
kuroScript.setting.AddCheckBox("Chat Box", "Show kuroScript", "ks_showkuroscript", "Whether or not to show you any kuroScript messages.");
kuroScript.setting.AddCheckBox("Chat Box", "Show Departure", "ks_showdeparture", "Whether or not to show you any departure messages.");
kuroScript.setting.AddCheckBox("Chat Box", "Show Arrival", "ks_showarrival", "Whether or not to show you any arrival messages.");
kuroScript.setting.AddCheckBox("Chat Box", "Show Server", "ks_showserver", "Whether or not to show you any server messages.");
kuroScript.setting.AddCheckBox("Chat Box", "Show OOC", "ks_showooc", "Whether or not to show you any OOC messages.");
kuroScript.setting.AddCheckBox("Chat Box", "Show IC", "ks_showic", "Whether or not to show you any IC messages.");