--[[
Name: "sh_setting.lua".
Product: "nexus".
--]]

nexus.setting = {};
nexus.setting.stored = {};

-- A function to add a number slider setting.
function nexus.setting.AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
	local index = #nexus.setting.stored + 1;
	
	nexus.setting.stored[index] = {
		Condition = Condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberSlider",
		text = text
	};
	
	return index;
end;

-- A function to add a multi-choice setting.
function nexus.setting.AddMultiChoice(category, text, conVar, options, toolTip, Condition)
	local index = #nexus.setting.stored + 1;
	
	if (options) then
		table.sort(options, function(a, b) return a < b; end);
	else
		options = {};
	end;
	
	nexus.setting.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		options = options,
		conVar = conVar,
		class = "multiChoice",
		text = text
	};
	
	return index;
end;

-- A function to add a number wang setting.
function nexus.setting.AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
	local index = #nexus.setting.stored + 1;
	
	nexus.setting.stored[index] = {
		Condition = Condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberWang",
		text = text
	};
	
	return index;
end;

-- A function to add a text entry setting.
function nexus.setting.AddTextEntry(category, text, conVar, toolTip, Condition)
	local index = #nexus.setting.stored + 1;
	
	nexus.setting.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "textEntry",
		text = text
	};
	
	return index;
end;

-- A function to add a check box setting.
function nexus.setting.AddCheckBox(category, text, conVar, toolTip, Condition)
	local index = #nexus.setting.stored + 1;
	
	nexus.setting.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "checkBox",
		text = text
	};
	
	return index;
end;

-- A function to remove a setting by its index.
function nexus.setting.RemoveByIndex(index)
	nexus.setting.stored[index] = nil;
end;

-- A function to remove a setting by its convar.
function nexus.setting.RemoveByConVar(conVar)
	for k, v in pairs(nexus.setting.stored) do
		if (v.conVar == conVar) then
			nexus.setting.stored[k] = nil;
		end;
	end;
end;

-- A function to remove a setting.
function nexus.setting.Remove(category, text, class, conVar)
	for k, v in pairs(nexus.setting.stored) do
		if ( (!category or v.category == category)
		and (!conVar or v.conVar == conVar)
		and (!class or v.class == class)
		and (!text or v.text == text) ) then
			nexus.setting.stored[k] = nil;
		end;
	end;
end;

nexus.setting.AddNumberSlider("nexus", "How much headbob to simulate.", "nx_headbobscale", 0, 1, 1, "The amount to scale the headbob by.");
nexus.setting.AddNumberSlider("Chat Box", "How many chat lines should show.", "nx_maxchatlines", 1, 10, 0, "The amount of chat lines shown at once.");

nexus.setting.AddCheckBox("nexus", "Enable the admin console log.", "nx_showlog", "Whether or not to show the admin console log.", function()
	return nexus.player.IsAdmin(g_LocalPlayer);
end);

nexus.setting.AddCheckBox("nexus", "Enable the twelve hour clock.", "nx_twelvehourclock", "Whether or not to show a twelve hour clock.");
nexus.setting.AddCheckBox("nexus", "Enable the hints system.", "nx_showhints", "Whether or not to show you any hints.");
nexus.setting.AddCheckBox("Chat Box", "Show timestamps on messages.", "nx_showtimestamps", "Whether or not to show you timestamps on messages.");
nexus.setting.AddCheckBox("Chat Box", "Show messages related to nexus.", "nx_shownexus", "Whether or not to show you any nexus messages.");
nexus.setting.AddCheckBox("Chat Box", "Show messages from the server.", "nx_showserver", "Whether or not to show you any server messages.");
nexus.setting.AddCheckBox("Chat Box", "Show out-of-character messages.", "nx_showooc", "Whether or not to show you any out-of-character messages.");
nexus.setting.AddCheckBox("Chat Box", "Show in-character messages.", "nx_showic", "Whether or not to show you any in-character messages.");

nexus.setting.AddCheckBox("nexus", "Enable the admin ESP.", "nx_adminesp", "Whether or not to show the admin ESP.", function()
	return nexus.player.IsAdmin(g_LocalPlayer);
end);