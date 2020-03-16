--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = openAura.theme:Begin();

-- Called when fonts should be created.
function THEME:CreateFonts()
	surface.CreateFont("Sansation", ScaleToWideScreen(2048), 600, true, false, "cid_Large3D2D");
	surface.CreateFont("Sansation", ScaleToWideScreen(32), 600, true, false, "cid_IntroTextSmall");
	surface.CreateFont("Sansation", ScaleToWideScreen(22), 600, true, false, "cid_IntroTextTiny");
	surface.CreateFont("Sansation", ScaleToWideScreen(32), 600, true, false, "cid_CinematicText");
	surface.CreateFont("Sansation", ScaleToWideScreen(74), 600, true, false, "cid_IntroTextBig");
	surface.CreateFont("Sansation", ScaleToWideScreen(22), 600, true, false, "cid_TargetIDText");
	surface.CreateFont("Sansation", ScaleToWideScreen(122), 600, true, false, "cid_MenuTextHuge");
	surface.CreateFont("Sansation", ScaleToWideScreen(74), 600, true, false, "cid_MenuTextBig");
	surface.CreateFont("Sansation", ScaleToWideScreen(20), 600, true, false, "cid_MainText");
	surface.CreateFont("Verdana", ScaleToWideScreen(12), 600, true, false, "cid_SmallBarText");
	surface.CreateFont("Verdana", ScaleToWideScreen(17), 600, true, false, "cid_PlayerInfoText");
	surface.CreateFont("Sansation", 36, 600, true, false, "cid_BillboardSmall");
	surface.CreateFont("Sansation", 72, 600, true, false, "cid_BillboardBig");
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	openAura.option:SetColor( "information", Color(200, 100, 100, 255) );
	openAura.option:SetFont("bar_text", "cid_TargetIDText");
	openAura.option:SetFont("main_text", "cid_MainText");
	openAura.option:SetFont("hints_text", "cid_IntroTextTiny");
	openAura.option:SetFont("large_3d_2d", "cid_Large3D2D");
	openAura.option:SetFont("target_id_text", "cid_TargetIDText");
	openAura.option:SetFont("cinematic_text", "cid_CinematicText");
	openAura.option:SetFont("date_time_text", "cid_IntroTextSmall");
	openAura.option:SetFont("menu_text_big", "cid_MenuTextBig");
	openAura.option:SetFont("menu_text_huge", "cid_MenuTextHuge");
	openAura.option:SetFont("menu_text_tiny", "cid_IntroTextTiny");
	openAura.option:SetFont("intro_text_big", "cid_IntroTextBig");
	openAura.option:SetFont("menu_text_small", "cid_IntroTextSmall");
	openAura.option:SetFont("intro_text_tiny", "cid_IntroTextTiny");
	openAura.option:SetFont("intro_text_small", "cid_IntroTextSmall");
	openAura.option:SetFont("player_info_text", "cid_PlayerInfoText");
end;

local DIRTY_TEXTURE = surface.GetTextureID("cidertwo/dirty_final");
local SCRATCH_TEXTURE = surface.GetTextureID("cidertwo/scratch_final");

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