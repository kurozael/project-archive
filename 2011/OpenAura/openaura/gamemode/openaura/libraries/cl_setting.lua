--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.setting = {};
openAura.setting.stored = {};

-- A function to add a number slider setting.
function openAura.setting:AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
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
function openAura.setting:AddMultiChoice(category, text, conVar, options, toolTip, Condition)
	local index = #self.stored + 1;
	
	if (options) then
		table.sort(options, function(a, b) return a < b; end);
	else
		options = {};
	end;
	
	self.stored[index] = {
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
function openAura.setting:AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
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
function openAura.setting:AddTextEntry(category, text, conVar, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
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
function openAura.setting:AddCheckBox(category, text, conVar, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
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
function openAura.setting:RemoveByIndex(index)
	self.stored[index] = nil;
end;

-- A function to remove a setting by its convar.
function openAura.setting:RemoveByConVar(conVar)
	for k, v in pairs(self.stored) do
		if (v.conVar == conVar) then
			self.stored[k] = nil;
		end;
	end;
end;

-- A function to remove a setting.
function openAura.setting:Remove(category, text, class, conVar)
	for k, v in pairs(self.stored) do
		if ( (!category or v.category == category)
		and (!conVar or v.conVar == conVar)
		and (!class or v.class == class)
		and (!text or v.text == text) ) then
			self.stored[k] = nil;
		end;
	end;
end;

openAura.setting:AddNumberSlider("Framework", "How much headbob to simulate.", "aura_headbobscale", 0, 1, 1, "The amount to scale the headbob by.");
openAura.setting:AddNumberSlider("Chat Box", "How many chat lines should show.", "aura_maxchatlines", 1, 10, 0, "The amount of chat lines shown at once.");

openAura.setting:AddCheckBox("Framework", "Enable the admin console log.", "aura_showlog", "Whether or not to show the admin console log.", function()
	return openAura.player:IsAdmin(openAura.Client);
end);

openAura.setting:AddCheckBox("Framework", "Enable the twelve hour clock.", "aura_twelvehourclock", "Whether or not to show a twelve hour clock.");
openAura.setting:AddCheckBox("Framework", "Show bars at the top of the screen.", "aura_topbars", "Whether or not to show bars at the top of the screen.");
openAura.setting:AddCheckBox("Framework", "Enable the hints system.", "aura_showhints", "Whether or not to show you any hints.");
openAura.setting:AddCheckBox("Chat Box", "Show timestamps on messages.", "aura_showtimestamps", "Whether or not to show you timestamps on messages.");
openAura.setting:AddCheckBox("Chat Box", "Show messages related to OpenAura.", "aura_showopenaura", "Whether or not to show you any OpenAura messages.");
openAura.setting:AddCheckBox("Chat Box", "Show messages from the server.", "aura_showserver", "Whether or not to show you any server messages.");
openAura.setting:AddCheckBox("Chat Box", "Show out-of-character messages.", "aura_showooc", "Whether or not to show you any out-of-character messages.");
openAura.setting:AddCheckBox("Chat Box", "Show in-character messages.", "aura_showic", "Whether or not to show you any in-character messages.");

openAura.setting:AddCheckBox("Framework", "Enable the admin ESP.", "aura_adminesp", "Whether or not to show the admin ESP.", function()
	return openAura.player:IsAdmin(openAura.Client);
end);