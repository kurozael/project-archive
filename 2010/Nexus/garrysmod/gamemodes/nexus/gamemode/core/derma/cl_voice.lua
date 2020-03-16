--[[
Name: "cl_voice.lua".
Product: "nexus".
--]]

local PANEL = {}

Derma_Hook(PANEL, "Paint", "Paint", "VoiceNotify");
Derma_Hook(PANEL, "PerformLayout", "Layout", "VoiceNotify");
Derma_Hook(PANEL, "ApplySchemeSettings", "Scheme", "VoiceNotify");
	
-- Called when the panel is initialized.
function PANEL:Init()
	self.LabelName = vgui.Create("DLabel", self);
end;

-- A function to set up the panel.
function PANEL:Setup(player)
	if ( !nexus.player.DoesRecognise(player, RECOGNISE_TOTAL) ) then
		local unrecognisedName, usedPhysDesc = nexus.player.GetUnrecognisedName(player);
		
		if (usedPhysDesc and string.len(unrecognisedName) > 24) then
			unrecognisedName = string.sub(unrecognisedName, 1, 21).."...";
		end;
		
		self.Recognises = false;
		self.LabelName:SetText("["..unrecognisedName.."]");
		self.Avatar = vgui.Create("DImage", self);
	else
		self.Recognises = true;
		self.LabelName:SetText( player:Name() );
		self.Avatar = vgui.Create("AvatarImage", self);
	end;
	
	self.Color = g_Team.GetColor( player:Team() );
	
	if (self.Recognises) then
		self.Avatar:SetPlayer(player);
	else
		self.Avatar:SetImage("nexus/unknown");
	end;
	
	self:InvalidateLayout();
end;

derma.DefineControl("VoiceNotify", "", PANEL, "DPanel");