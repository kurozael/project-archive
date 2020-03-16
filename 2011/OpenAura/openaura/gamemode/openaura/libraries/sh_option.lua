--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.option = {};
openAura.option.keys = {};
openAura.option.sounds = {};

-- A function to set a schema key.
function openAura.option:SetKey(key, value)
	self.keys[key] = value;
end;

-- A function to get a schema key.
function openAura.option:GetKey(key, lowerValue)
	local value = self.keys[key];
	
	if (lowerValue and type(value) == "string") then
		return string.lower(value);
	else
		return value;
	end;
end;

-- A function to set a schema sound.
function openAura.option:SetSound(name, sound)
	self.sounds[name] = sound;
end;

-- A function to get a schema sound.
function openAura.option:GetSound(name)
	return self.sounds[name];
end;

-- A function to play a schema sound.
function openAura.option:PlaySound(name)
	local sound = self:GetSound(name);
	
	if (sound) then
		if (CLIENT) then
			surface.PlaySound(sound);
		else
			openAura.player:PlaySound(nil, sound);
		end;
	end;
end;

openAura.option:SetKey( "default_date", {month = 1, year = 2010, day = 1} );
openAura.option:SetKey( "default_time", {minute = 0, hour = 0, day = 1} );
openAura.option:SetKey( "default_days", {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"} );
openAura.option:SetKey("description_business", "Order items for your business.");
openAura.option:SetKey("description_inventory", "Manage the items in your inventory.");
openAura.option:SetKey("description_directory", "A directory of various topics and information.");
openAura.option:SetKey("description_admin", "Access a variety of server-side options.");
openAura.option:SetKey("description_attributes", "Check the status of your attributes.");
openAura.option:SetKey("model_shipment", "models/items/item_item_crate.mdl");
openAura.option:SetKey("model_cash", "models/props_c17/briefcase001a.mdl");
openAura.option:SetKey("format_singular_cash", "$%a");
openAura.option:SetKey("format_cash", "$%a");
openAura.option:SetKey("name_attributes", "Attributes");
openAura.option:SetKey("name_attribute", "Attribute");
openAura.option:SetKey("name_moderator", "Moderator");
openAura.option:SetKey("name_directory", "Directory");
openAura.option:SetKey("name_inventory", "Inventory");
openAura.option:SetKey("name_business", "Business");
openAura.option:SetKey("name_destroy", "Destroy");
openAura.option:SetKey("schema_logo", "");
openAura.option:SetKey("intro_image", "");
openAura.option:SetKey("menu_music", "music/hl2_song32.mp3");
openAura.option:SetKey("name_cash", "Cash");
openAura.option:SetKey("name_drop", "Drop");
openAura.option:SetKey("top_bars", false);
openAura.option:SetKey("name_use", "Use");
openAura.option:SetKey("gradient", "gui/gradient_up");

openAura.option:SetSound("click_release", "ui/buttonclickrelease.wav");
openAura.option:SetSound("rollover", "ui/buttonrollover.wav");
openAura.option:SetSound("click", "ui/buttonclick.wav");

if (CLIENT) then
	openAura.option.fonts = {};
	openAura.option.colors = {};

	-- A function to set a schema color.
	function openAura.option:SetColor(name, color)
		self.colors[name] = color;
	end;

	-- A function to get a schema color.
	function openAura.option:GetColor(name)
		return self.colors[name];
	end;

	-- A function to set a schema font.
	function openAura.option:SetFont(name, font)
		self.fonts[name] = font;
	end;

	-- A function to get a schema font.
	function openAura.option:GetFont(name)
		return self.fonts[name];
	end;

	openAura.option:SetColor( "positive_hint", Color(100, 175, 100, 255) );
	openAura.option:SetColor( "negative_hint", Color(175, 100, 100, 255) );
	openAura.option:SetColor( "information", Color(100, 50, 50, 255) );
	openAura.option:SetColor( "background", Color(0, 0, 0, 125) );
	openAura.option:SetColor( "target_id", Color(50, 75, 100, 255) );
	openAura.option:SetColor( "white", Color(255, 255, 255, 255) );

	openAura.option:SetFont("schema_description", "aura_MainText");
	openAura.option:SetFont("player_info_text", "aura_MainText");
	openAura.option:SetFont("intro_text_small", "aura_IntroTextSmall");
	openAura.option:SetFont("intro_text_tiny", "aura_IntroTextTiny");
	openAura.option:SetFont("menu_text_small", "aura_MenuTextSmall");
	openAura.option:SetFont("menu_text_huge", "aura_MenuTextHuge");
	openAura.option:SetFont("intro_text_big", "aura_IntroTextBig");
	openAura.option:SetFont("menu_text_tiny", "aura_MenuTextTiny");
	openAura.option:SetFont("date_time_text", "aura_MenuTextSmall");
	openAura.option:SetFont("cinematic_text", "aura_CinematicText");
	openAura.option:SetFont("target_id_text", "aura_MainText");
	openAura.option:SetFont("auto_bar_text", "aura_MainText");
	openAura.option:SetFont("menu_text_big", "aura_MenuTextBig");
	openAura.option:SetFont("chat_box_text", "aura_MainText");
	openAura.option:SetFont("large_3d_2d", "aura_Large3D2D");
	openAura.option:SetFont("hints_text", "aura_IntroTextTiny");
	openAura.option:SetFont("main_text", "aura_MainText");
	openAura.option:SetFont("bar_text", "aura_MainText");
else
	--[[
		Backwards compatability, you shouldn't use this
		function for anything new.
	--]]
	function openAura.option:GetColor(name)
		return name;
	end;
end;