--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = openAura.theme:Begin();

-- Called when fonts should be created.
function THEME:CreateFonts()
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(2048), 600, true, false, "sev_Large3D2D");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(27), 600, true, false, "sev_IntroTextSmall");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(20), 600, true, false, "sev_IntroTextTiny");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(32), 600, true, false, "sev_CinematicText");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(74), 600, true, false, "sev_IntroTextBig");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(20), 600, true, false, "sev_TargetIDText");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(16), 600, true, false, "sev_MainText");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(122), 600, true, false, "sev_MenuTextHuge");
	surface.CreateFont("nu-century-gothic", ScaleToWideScreen(74), 600, true, false, "sev_MenuTextBig");
	surface.CreateFont("Verdana", ScaleToWideScreen(17), 600, true, false, "sev_PlayerInfoText");
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	openAura.option:SetColor( "information", Color(100, 150, 100, 255) );
	openAura.option:SetFont("bar_text", "sev_TargetIDText");
	openAura.option:SetFont("main_text", "sev_MainTextTiny");
	openAura.option:SetFont("hints_text", "sev_IntroTextTiny");
	openAura.option:SetFont("large_3d_2d", "sev_Large3D2D");
	openAura.option:SetFont("target_id_text", "sev_TargetIDText");
	openAura.option:SetFont("cinematic_text", "sev_CinematicText");
	openAura.option:SetFont("date_time_text", "sev_IntroTextSmall");
	openAura.option:SetFont("menu_text_big", "sev_MenuTextBig");
	openAura.option:SetFont("menu_text_huge", "sev_MenuTextHuge");
	openAura.option:SetFont("menu_text_tiny", "sev_IntroTextTiny");
	openAura.option:SetFont("intro_text_big", "sev_IntroTextBig");
	openAura.option:SetFont("menu_text_small", "sev_IntroTextSmall");
	openAura.option:SetFont("intro_text_tiny", "sev_IntroTextTiny");
	openAura.option:SetFont("intro_text_small", "sev_IntroTextSmall");
	openAura.option:SetFont("player_info_text", "sev_PlayerInfoText");
end;

local DIRTY_TEXTURE = surface.GetTextureID("severance/dirty");
local SCRATCH_TEXTURE = surface.GetTextureID("severance/scratch");

-- Called just before a bar is drawn.
function THEME.module:PreDrawBar(barInfo)
	surface.SetDrawColor(255, 255, 255, 150);
	surface.SetTexture(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.width, barInfo.height);
	
	barInfo.drawBackground = false;
	barInfo.drawProgress = false;
	
	if (barInfo.text) then
		barInfo.text = string.upper(barInfo.text);
	end;
end;

-- Called just after a bar is drawn.
function THEME.module:PostDrawBar(barInfo)
	surface.SetDrawColor(barInfo.color.r, barInfo.color.g, barInfo.color.b, barInfo.color.a);
	surface.SetTexture(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.progressWidth, barInfo.height);
end;

-- Called just before the weapon selection info is drawn.
function THEME.module:PreDrawWeaponSelectionInfo(info)
	surface.SetDrawColor( 255, 255, 255, math.min(200, info.alpha) );
	surface.SetTexture(DIRTY_TEXTURE);
	surface.DrawTexturedRect(info.x, info.y, info.width, info.height);
	
	info.drawBackground = false;
end;

-- Called just before the local player's information is drawn.
function THEME.module:PreDrawPlayerInfo(boxInfo, information, subInformation)
	surface.SetDrawColor(255, 255, 255, 100);
	surface.SetTexture(DIRTY_TEXTURE);
	surface.DrawTexturedRect(boxInfo.x, boxInfo.y, boxInfo.width, boxInfo.height);
	
	boxInfo.drawBackground = false;
end;

-- Called after the character menu has initialized.
function THEME.hooks:PostCharacterMenuInit(panel) end;

-- Called every frame that the character menu is open.
function THEME.hooks:PostCharacterMenuThink(panel) end;

-- Called after the character menu is painted.
function THEME.hooks:PostCharacterMenuPaint(panel) end;

-- Called after a character menu panel is opened.
function THEME.hooks:PostCharacterMenuOpenPanel(panel) end;

-- Called after the main menu has initialized.
function THEME.hooks:PostMainMenuInit(panel) end;

-- Called after the main menu is rebuilt.
function THEME.hooks:PostMainMenuRebuild(panel) end;

-- Called after a main menu panel is opened.
function THEME.hooks:PostMainMenuOpenPanel(panel, panelToOpen) end;

-- Called after the main menu is painted.
function THEME.hooks:PostMainMenuPaint(panel) end;

-- Called every frame that the main menu is open.
function THEME.hooks:PostMainMenuThink(panel) end;

openAura.theme:Finish(THEME);