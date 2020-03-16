--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.setting = {};
CloudScript.setting.stored = {};

-- A function to add a number slider setting.
function CloudScript.setting:AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
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
function CloudScript.setting:AddMultiChoice(category, text, conVar, options, toolTip, Condition)
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
function CloudScript.setting:AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
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
function CloudScript.setting:AddTextEntry(category, text, conVar, toolTip, Condition)
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
function CloudScript.setting:AddCheckBox(category, text, conVar, toolTip, Condition)
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
function CloudScript.setting:RemoveByIndex(index)
	self.stored[index] = nil;
end;

-- A function to remove a setting by its convar.
function CloudScript.setting:RemoveByConVar(conVar)
	for k, v in pairs(self.stored) do
		if (v.conVar == conVar) then
			self.stored[k] = nil;
		end;
	end;
end;

-- A function to remove a setting.
function CloudScript.setting:Remove(category, text, class, conVar)
	for k, v in pairs(self.stored) do
		if ( (!category or v.category == category)
		and (!conVar or v.conVar == conVar)
		and (!class or v.class == class)
		and (!text or v.text == text) ) then
			self.stored[k] = nil;
		end;
	end;
end;

CloudScript.setting:AddNumberSlider("Framework", "How much headbob to simulate.", "cloud_headbobscale", 0, 1, 1, "The amount to scale the headbob by.");
CloudScript.setting:AddNumberSlider("Chat Box", "How many chat lines should show.", "cloud_maxchatlines", 1, 10, 0, "The amount of chat lines shown at once.");

CloudScript.setting:AddCheckBox("Framework", "Enable the admin console log.", "cloud_showlog", "Whether or not to show the admin console log.", function()
	return CloudScript.player:IsAdmin(CloudScript.Client);
end);

CloudScript.setting:AddCheckBox("Framework", "Enable the twelve hour clock.", "cloud_twelvehourclock", "Whether or not to show a twelve hour clock.");
CloudScript.setting:AddCheckBox("Framework", "Show bars at the top of the screen.", "cloud_topbars", "Whether or not to show bars at the top of the screen.");
CloudScript.setting:AddCheckBox("Framework", "Enable the hints system.", "cloud_showhints", "Whether or not to show you any hints.");
CloudScript.setting:AddCheckBox("Chat Box", "Show timestamps on messages.", "cloud_showtimestamps", "Whether or not to show you timestamps on messages.");
CloudScript.setting:AddCheckBox("Chat Box", "Show messages related to CloudScript.", "cloud_showCloudScript", "Whether or not to show you any CloudScript messages.");
CloudScript.setting:AddCheckBox("Chat Box", "Show messages from the server.", "cloud_showserver", "Whether or not to show you any server messages.");
CloudScript.setting:AddCheckBox("Chat Box", "Show out-of-character messages.", "cloud_showooc", "Whether or not to show you any out-of-character messages.");
CloudScript.setting:AddCheckBox("Chat Box", "Show in-character messages.", "cloud_showic", "Whether or not to show you any in-character messages.");

CloudScript.setting:AddCheckBox("Framework", "Enable the admin ESP.", "cloud_adminesp", "Whether or not to show the admin ESP.", function()
	return CloudScript.player:IsAdmin(CloudScript.Client);
end);