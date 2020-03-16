--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.option = {};
CloudScript.option.keys = {};
CloudScript.option.sounds = {};

-- A function to set a schema key.
function CloudScript.option:SetKey(key, value)
	self.keys[key] = value;
end;

-- A function to get a schema key.
function CloudScript.option:GetKey(key, lowerValue)
	local value = self.keys[key];
	
	if (lowerValue and type(value) == "string") then
		return string.lower(value);
	else
		return value;
	end;
end;

-- A function to set a schema sound.
function CloudScript.option:SetSound(name, sound)
	self.sounds[name] = sound;
end;

-- A function to get a schema sound.
function CloudScript.option:GetSound(name)
	return self.sounds[name];
end;

-- A function to play a schema sound.
function CloudScript.option:PlaySound(name)
	local sound = self:GetSound(name);
	
	if (sound) then
		if (CLIENT) then
			surface.PlaySound(sound);
		else
			CloudScript.player:PlaySound(nil, sound);
		end;
	end;
end;

CloudScript.option:SetKey( "default_date", {month = 1, year = 2010, day = 1} );
CloudScript.option:SetKey( "default_time", {minute = 0, hour = 0, day = 1} );
CloudScript.option:SetKey( "default_days", {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"} );
CloudScript.option:SetKey("description_business", "Order items for your business.");
CloudScript.option:SetKey("description_inventory", "Manage the items in your inventory.");
CloudScript.option:SetKey("description_directory", "A directory of various topics and information.");
CloudScript.option:SetKey("description_system", "Access a variety of server-side options.");
CloudScript.option:SetKey("description_attributes", "Check the status of your attributes.");
CloudScript.option:SetKey("model_shipment", "models/items/item_item_crate.mdl");
CloudScript.option:SetKey("model_cash", "models/props_c17/briefcase001a.mdl");
CloudScript.option:SetKey("format_singular_cash", "$%a");
CloudScript.option:SetKey("format_cash", "$%a");
CloudScript.option:SetKey("name_attributes", "Attributes");
CloudScript.option:SetKey("name_attribute", "Attribute");
CloudScript.option:SetKey("name_system", "System");
CloudScript.option:SetKey("name_directory", "Directory");
CloudScript.option:SetKey("name_inventory", "Inventory");
CloudScript.option:SetKey("name_business", "Business");
CloudScript.option:SetKey("name_destroy", "Destroy");
CloudScript.option:SetKey("schema_logo", "");
CloudScript.option:SetKey("intro_image", "");
CloudScript.option:SetKey("menu_music", "music/hl2_song32.mp3");
CloudScript.option:SetKey("name_cash", "Cash");
CloudScript.option:SetKey("name_drop", "Drop");
CloudScript.option:SetKey("top_bars", false);
CloudScript.option:SetKey("name_use", "Use");
CloudScript.option:SetKey("gradient", "gui/gradient_up");

CloudScript.option:SetSound("click_release", "ui/buttonclickrelease.wav");
CloudScript.option:SetSound("rollover", "ui/buttonrollover.wav");
CloudScript.option:SetSound("click", "ui/buttonclick.wav");

if (CLIENT) then
	CloudScript.option.fonts = {};
	CloudScript.option.colors = {};

	-- A function to set a schema color.
	function CloudScript.option:SetColor(name, color)
		self.colors[name] = color;
	end;

	-- A function to get a schema color.
	function CloudScript.option:GetColor(name)
		return self.colors[name];
	end;

	-- A function to set a schema font.
	function CloudScript.option:SetFont(name, font)
		self.fonts[name] = font;
	end;

	-- A function to get a schema font.
	function CloudScript.option:GetFont(name)
		return self.fonts[name];
	end;

	CloudScript.option:SetColor( "positive_hint", Color(100, 175, 100, 255) );
	CloudScript.option:SetColor( "negative_hint", Color(175, 100, 100, 255) );
	CloudScript.option:SetColor( "information", Color(100, 50, 50, 255) );
	CloudScript.option:SetColor( "background", Color(0, 0, 0, 125) );
	CloudScript.option:SetColor( "target_id", Color(50, 75, 100, 255) );
	CloudScript.option:SetColor( "white", Color(255, 255, 255, 255) );

	CloudScript.option:SetFont("schema_description", "cloud_MainText");
	CloudScript.option:SetFont("player_info_text", "cloud_MainText");
	CloudScript.option:SetFont("intro_text_small", "cloud_IntroTextSmall");
	CloudScript.option:SetFont("intro_text_tiny", "cloud_IntroTextTiny");
	CloudScript.option:SetFont("menu_text_small", "cloud_MenuTextSmall");
	CloudScript.option:SetFont("menu_text_huge", "cloud_MenuTextHuge");
	CloudScript.option:SetFont("intro_text_big", "cloud_IntroTextBig");
	CloudScript.option:SetFont("menu_text_tiny", "cloud_MenuTextTiny");
	CloudScript.option:SetFont("date_time_text", "cloud_MenuTextSmall");
	CloudScript.option:SetFont("cinematic_text", "cloud_CinematicText");
	CloudScript.option:SetFont("target_id_text", "cloud_MainText");
	CloudScript.option:SetFont("auto_bar_text", "cloud_MainText");
	CloudScript.option:SetFont("menu_text_big", "cloud_MenuTextBig");
	CloudScript.option:SetFont("chat_box_text", "cloud_MainText");
	CloudScript.option:SetFont("large_3d_2d", "cloud_Large3D2D");
	CloudScript.option:SetFont("hints_text", "cloud_IntroTextTiny");
	CloudScript.option:SetFont("main_text", "cloud_MainText");
	CloudScript.option:SetFont("bar_text", "cloud_MainText");
else
	--[[
		Backwards compatability, you shouldn't use this
		function for anything new.
	--]]
	function CloudScript.option:GetColor(name)
		return name;
	end;
end;