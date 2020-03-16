--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_boot");

-- A function to get whether a text entry is being used.
function Schema:IsTextEntryBeingUsed()
	if (IsValid(self.textEntryFocused)) then
		if (self.textEntryFocused:IsVisible()) then
			return true;
		end;
	end;
end;

Clockwork.config:AddToSystem("intro_text_small", "The small text displayed for the introduction.");
Clockwork.config:AddToSystem("intro_text_big", "The big text displayed for the introduction.");

Clockwork:HookDataStream("RebuildBusiness", function(data)
	if (Clockwork.menu:GetOpen() and Schema.businessPanel) then
		if (Clockwork.menu:GetActiveTab() == Schema.businessPanel) then
			Schema.businessPanel:Rebuild();
		end;
	end;
end);

usermessage.Hook("cwFrequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		Clockwork:RunCommand("SetFreq", text);
	end);
end);

usermessage.Hook("cwObjectPhysDesc", function(msg)
	local entity = msg:ReadEntity();
	
	if (IsValid(entity)) then
		Derma_StringRequest("Description", "What is the physical description of this object?", nil, function(text)
			Clockwork:StartDataStream("ObjectPhysDesc", {text, entity});
		end);
	end;
end);

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Clockwork.plugin:Register(Schema);