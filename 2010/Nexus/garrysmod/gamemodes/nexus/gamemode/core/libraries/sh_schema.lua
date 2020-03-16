--[[
Name: "sh_schema.lua".
Product: "nexus".
--]]

nexus.schema = {};
nexus.schema.fonts = {};
nexus.schema.colors = {};
nexus.schema.options = {};

-- A function to set a schema option.
function nexus.schema.SetOption(key, value)
	nexus.schema.options[key] = value;
end;

-- A function to get a schema option.
function nexus.schema.GetOption(key, lowerValue)
	local value = nexus.schema.options[key];
	
	if (lowerValue and type(value) == "string") then
		return string.lower(value);
	else
		return value;
	end;
end;

-- A function to set a schema color.
function nexus.schema.SetColor(name, color)
	nexus.schema.colors[name] = color;
end;

-- A function to get a schema color.
function nexus.schema.GetColor(name, color)
	return nexus.schema.colors[name];
end;

-- A function to set a schema font.
function nexus.schema.SetFont(name, font)
	nexus.schema.fonts[name] = font;
end;

-- A function to get a schema font.
function nexus.schema.GetFont(name, font)
	return nexus.schema.fonts[name];
end;

nexus.schema.SetOption( "default_date", {month = 1, year = 2010, day = 1} );
nexus.schema.SetOption( "default_time", {minute = 0, hour = 0, day = 1} );
nexus.schema.SetOption( "default_days", {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"} );
nexus.schema.SetOption("description_business", "Order items for your business.");
nexus.schema.SetOption("description_inventory", "Manage the items in your inventory.");
nexus.schema.SetOption("description_directory", "A directory of various topics and information.");
nexus.schema.SetOption("description_overwatch", "Access a variety of server-side options.");
nexus.schema.SetOption("description_attributes", "Check the status of your attributes.");
nexus.schema.SetOption("model_shipment", "models/items/item_item_crate.mdl");
nexus.schema.SetOption("model_cash", "models/props_c17/briefcase001a.mdl");
nexus.schema.SetOption("format_singular_cash", "$%a");
nexus.schema.SetOption("format_cash", "$%a");
nexus.schema.SetOption("html_background", "");
nexus.schema.SetOption("name_attributes", "Attributes");
nexus.schema.SetOption("name_attribute", "Attribute");
nexus.schema.SetOption("name_overwatch", "Overwatch");
nexus.schema.SetOption("name_directory", "Directory");
nexus.schema.SetOption("name_inventory", "Inventory");
nexus.schema.SetOption("name_business", "Business");
nexus.schema.SetOption("name_destroy", "Destroy");
nexus.schema.SetOption("intro_image", "");
nexus.schema.SetOption("name_cash", "Cash");
nexus.schema.SetOption("name_drop", "Drop");
nexus.schema.SetOption("name_use", "Use");

nexus.schema.SetColor( "positive_hint", Color(100, 175, 100, 255) );
nexus.schema.SetColor( "negative_hint", Color(175, 100, 100, 255) );
nexus.schema.SetColor( "information", Color(100, 50, 50, 255) );
nexus.schema.SetColor( "background", Color(0, 0, 0, 125) );
nexus.schema.SetColor( "target_id", Color(50, 75, 100, 255) );
nexus.schema.SetColor( "white", Color(255, 255, 255, 255) );

nexus.schema.SetFont("schema_description", "nx_MainText");
nexus.schema.SetFont("player_info_text", "nx_MainText");
nexus.schema.SetFont("intro_text_small", "nx_IntroTextSmall");
nexus.schema.SetFont("intro_text_tiny", "nx_IntroTextTiny");
nexus.schema.SetFont("menu_text_small", "nx_MenuTextSmall");
nexus.schema.SetFont("intro_text_big", "nx_IntroTextBig");
nexus.schema.SetFont("menu_text_tiny", "nx_MenuTextTiny");
nexus.schema.SetFont("date_time_text", "nx_MenuTextSmall");
nexus.schema.SetFont("cinematic_text", "nx_CinematicText");
nexus.schema.SetFont("target_id_text", "nx_MainText");
nexus.schema.SetFont("auto_bar_text", "nx_MainText");
nexus.schema.SetFont("menu_text_big", "nx_MenuTextBig");
nexus.schema.SetFont("chat_box_text", "nx_MainText");
nexus.schema.SetFont("large_3d_2d", "nx_Large3D2D");
nexus.schema.SetFont("hints_text", "nx_IntroTextTiny");
nexus.schema.SetFont("main_text", "nx_MainText");
nexus.schema.SetFont("bar_text", "nx_MainText");