--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.stunEffects = {};
openAura.schema.combineOverlay = Material("effects/combine_binocoverlay");
openAura.schema.randomDisplayLines = {
	"Transmitting physical transition vector...",
	"Modulating external temperature levels...",
	"Parsing view ports and data arrays...",
	"Translating Union practicalities...",
	"Updating biosignal co-ordinates...",
	"Parsing OpenAura protocol messages...",
	"Downloading recent dictionaries...",
	"Pinging connection to network...",
	"Updating mainframe connection...",
	"Synchronizing locational data...",
	"Translating radio messages...",
	"Emptying outgoing pipes...",
	"Sensoring proximity...",
	"Pinging loopback...",
	"Idle connection..."
};

openAura:IncludePrefixed("sh_auto.lua");

openAura.directory:AddCategory("Combine Dispatcher", "Commands");
openAura.directory:AddCategory("Civil Protection", "Commands");

openAura.config:AddAuraWatch("server_whitelist_identity", "The identity used for the server whitelist.\nLeave blank for no identity.");
openAura.config:AddAuraWatch("combine_lock_overrides", "Whether or not Combine locks override the door lock.");
openAura.config:AddAuraWatch("intro_text_small", "The small text displayed for the introduction.");
openAura.config:AddAuraWatch("intro_text_big", "The big text displayed for the introduction.");
openAura.config:AddAuraWatch("knockout_time", "The time that a player gets knocked out for (seconds).", 0, 7200);
openAura.config:AddAuraWatch("business_cost", "The amount that it costs to start a business.");
openAura.config:AddAuraWatch("cwu_props", "Whether or not to use Civil Worker's Union props.");
openAura.config:AddAuraWatch("permits", "Whether or not permits are enabled.");

table.sort(openAura.schema.voices, function(a, b) return a.command < b.command; end);
table.sort(openAura.schema.dispatchVoices, function(a, b) return a.command < b.command; end);

for k, v in pairs(openAura.schema.dispatchVoices) do
	openAura.directory:AddCode("Combine Dispatcher", [[
		<div class="auraInfoTitle">]]..string.upper(v.command)..[[</div>
		<div class="auraInfoText">]]..v.phrase..[[</div>
	]], true);
end;

for k, v in pairs(openAura.schema.voices) do
	openAura.directory:AddCode("Civil Protection", [[
		<div class="auraInfoTitle">]]..string.upper(v.command)..[[</div>
		<div class="auraInfoText">]]..v.phrase..[[</div>
	]], true);
end;

openAura:HookDataStream("RebuildBusiness", function(data)
	if ( openAura.menu:GetOpen() and IsValid(openAura.schema.businessPanel) ) then
		if (openAura.menu:GetActivePanel() == openAura.schema.businessPanel) then
			openAura.schema.businessPanel:Rebuild();
		end;
	end;
end);

usermessage.Hook("aura_ObjectPhysDesc", function(msg)
	local entity = msg:ReadEntity();
	
	if ( IsValid(entity) ) then
		Derma_StringRequest("Description", "What is the physical description of this object?", nil, function(text)
			openAura:StartDataStream( "ObjectPhysDesc", {text, entity} );
		end);
	end;
end);

usermessage.Hook("aura_Frequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		openAura:RunCommand("SetFreq", text);
		
		if ( !openAura.menu:GetOpen() ) then
			gui.EnableScreenClicker(false);
		end;
	end);
	
	if ( !openAura.menu:GetOpen() ) then
		gui.EnableScreenClicker(true);
	end;
end);

openAura:HookDataStream("EditObjectives", function(data)
	if ( openAura.schema.objectivesPanel and openAura.schema.objectivesPanel:IsValid() ) then
		openAura.schema.objectivesPanel:Close();
		openAura.schema.objectivesPanel:Remove();
	end;
	
	openAura.schema.objectivesPanel = vgui.Create("aura_Objectives");
	openAura.schema.objectivesPanel:Populate(data or "");
	openAura.schema.objectivesPanel:MakePopup();
	
	gui.EnableScreenClicker(true);
end);

openAura:HookDataStream("EditData", function(data)
	if ( IsValid( data[1] ) ) then
		if ( openAura.schema.dataPanel and openAura.schema.dataPanel:IsValid() ) then
			openAura.schema.dataPanel:Close();
			openAura.schema.dataPanel:Remove();
		end;
		
		openAura.schema.dataPanel = vgui.Create("aura_Data");
		openAura.schema.dataPanel:Populate(data[1], data[2] or "");
		openAura.schema.dataPanel:MakePopup();
		
		gui.EnableScreenClicker(true);
	end;
end);

usermessage.Hook("aura_Stunned", function(msg)
	openAura.schema:AddStunEffect( msg:ReadFloat() );
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

-- A function to add a stun effect.
function openAura.schema:AddStunEffect(duration)
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 1;
	end;
	
	self.stunEffects[#self.stunEffects + 1] = {curTime + duration, duration};
	self.flashEffect = {curTime + (duration * 2), duration * 2, true};
end;

usermessage.Hook("aura_ClearEffects", function(msg)
	openAura.schema.stunEffects = {};
	openAura.schema.flashEffect = nil;
end);

openAura:HookDataStream("CombineDisplayLine", function(data)
	openAura.schema:AddCombineDisplayLine( data[1], data[2] );
end);

openAura.chatBox:RegisterClass("request_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		openAura.chatBox:Add(info.filtered, nil, Color(255, 255, 150, 255), info.name.." requests \""..info.text.."\"");
	end;
end);

openAura.chatBox:RegisterClass("broadcast", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("dispatch", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(150, 100, 100, 255), "Dispatch broadcasts \""..info.text.."\"");
end);

openAura.chatBox:RegisterClass("request", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(175, 125, 100, 255), info.name.." requests \""..info.text.."\"");
end);

-- A function to get a player's scanner entity.
function openAura.schema:GetScannerEntity(player)
	local scannerEntity = player:GetSharedVar("scanner");
	
	if ( IsValid(scannerEntity) ) then
		return scannerEntity;
	end;
end;

-- A function to get whether a text entry is being used.
function openAura.schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if ( self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible() ) then
			return true;
		end;
	end;
end;

-- A function to add a Combine display line.
function openAura.schema:AddCombineDisplayLine(text, color)
	if ( self:PlayerIsCombine(openAura.Client) ) then
		if (!self.combineDisplayLines) then
			self.combineDisplayLines = {};
		end;
		
		table.insert( self.combineDisplayLines, {"<:: "..text, CurTime() + 8, 5, color} );
	end;
end;

-- A function to get whether a player is Combine.
function openAura.schema:PlayerIsCombine(player, bHuman)
	local faction = openAura.player:GetFaction(player);
	
	if ( self:IsCombineFaction(faction) ) then
		if (bHuman) then
			if (faction == FACTION_MPF) then
				return true;
			end;
		elseif (bHuman == false) then
			if (faction == FACTION_MPF) then
				return false;
			else
				return true;
			end;
		else
			return true;
		end;
	end;
end;