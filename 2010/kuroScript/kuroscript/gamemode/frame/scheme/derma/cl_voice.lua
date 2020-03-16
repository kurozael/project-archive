--[[
Name: "cl_voice.lua".
Product: "kuroScript".
--]]

local PANEL = {}

-- Hook some derma functions.
Derma_Hook(PANEL, "Paint", "Paint", "VoiceNotify");
Derma_Hook(PANEL, "PerformLayout", "Layout", "VoiceNotify");
Derma_Hook(PANEL, "ApplySchemeSettings", "Scheme", "VoiceNotify");
	
-- Called when the panel is initialized.
function PANEL:Init()
	self.LabelName = vgui.Create("DLabel", self);
	self.Avatar = vgui.Create("AvatarImage", self);
end;

-- A function to set up the panel.
function PANEL:Setup(player)
	if ( !kuroScript.player.KnowsPlayer(player, KNOWN_TOTAL) ) then
		self.LabelName:SetText( kuroScript.config.Get("anonymous_name"):Get() );
	else
		self.LabelName:SetText( player:Name() );
	end;
	
	-- Set some information.
	self.Color = g_Team.GetColor( player:Team() );
	
	-- Set some information.
	self.Avatar:SetPlayer(player);
	
	-- Invalidate the layout.
	self:InvalidateLayout();
end;

-- Define a derma control.
derma.DefineControl("VoiceNotify", "", PANEL, "DPanel");