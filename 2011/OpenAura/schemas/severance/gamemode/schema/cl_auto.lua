--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.stunEffects = {};

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:AddAuraWatch("intro_text_small", "The small text displayed for the introduction.");
openAura.config:AddAuraWatch("intro_text_big", "The big text displayed for the introduction.");

openAura:HookDataStream("RebuildBusiness", function(data)
	if (openAura.menu:GetOpen() and openAura.schema.businessPanel) then
		if (openAura.menu:GetActiveTab() == openAura.schema.businessPanel) then
			openAura.schema.businessPanel:Rebuild();
		end;
	end;
end);

usermessage.Hook("aura_Frequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		openAura:RunCommand("SetFreq", text);
	end);
end);

usermessage.Hook("aura_ObjectPhysDesc", function(msg)
	local entity = msg:ReadEntity();
	
	if ( IsValid(entity) ) then
		Derma_StringRequest("Description", "What is the physical description of this object?", nil, function(text)
			openAura:StartDataStream( "ObjectPhysDesc", {text, entity} );
		end);
	end;
end);

usermessage.Hook("aura_Flashed", function(msg)
	openAura.schema:AddFlashEffect();
end);

-- A function to add a flash effect.
function openAura.schema:AddFlashEffect()
	local curTime = CurTime();
	
	self.stunEffects[#self.stunEffects + 1] = {curTime + 10, 10};
	self.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end;

usermessage.Hook("aura_ClearEffects", function(msg)
	openAura.schema.stunEffects = {};
	openAura.schema.flashEffect = nil;
end);

openAura.chatBox:RegisterClass("broadcast", "ic", function(info)
	if ( IsValid(info.data.bc) ) then
		local name = info.data.bc:GetNetworkedString("name");
		
		if (name != "") then
			info.name = name;
		end;
	end;
	
	openAura.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

-- A function to get whether a text entry is being used.
function openAura.schema:IsTextEntryBeingUsed()
	if ( IsValid(self.textEntryFocused) ) then
		if ( self.textEntryFocused:IsVisible() ) then
			return true;
		end;
	end;
end;