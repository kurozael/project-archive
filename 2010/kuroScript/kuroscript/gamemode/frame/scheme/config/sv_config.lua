--[[
Name: "sv_config.lua".
Product: "kuroScript".
--]]

--  The name of the table where the character data is stored.
kuroScript.config.Add("mysql_characters_table", "characters", nil, nil, nil, true, true);

--  The name of the table where the player data is stored.
kuroScript.config.Add("mysql_players_table", "players", nil, nil, nil, true, true);

--  The username that you log in to MySQL with.
kuroScript.config.Add("mysql_username", "", nil, nil, nil, true, true);

--  The password that you log in to MySQL with.
kuroScript.config.Add("mysql_password", "", nil, nil, nil, true, true);

--  The name of the database that we'll be using.
kuroScript.config.Add("mysql_database", "", nil, nil, nil, true, true);

--  The host that your MySQL database is located.
kuroScript.config.Add("mysql_host", "", nil, nil, nil, true, true);

-- The time that a player has to wait to change vocation again.
kuroScript.config.Add("change_vocation_interval", 180);

-- The amount to scale attribute progress by.
kuroScript.config.Add("scale_attribute_progress", 1);

-- The distance at which each player can pickup entities with the physgun (units) (set to 0 for unlimited).
kuroScript.config.Add("physgun_pickup_distance", 256);

-- Whether or not to save the position of each physics entity over a map change.
kuroScript.config.Add("save_physics_positions", true);

-- Whether or not chair entities on the map are replaced with actual chairs.
kuroScript.config.Add("replace_chair_entities", true);

-- Whether or not to enable prop protection.
kuroScript.config.Add("enable_prop_protection", true);

-- The time that a player's ragdoll is immune from damage (seconds).
kuroScript.config.Add("ragdoll_immunity_time", 1);

-- The additional amount of characters that each player can have.
kuroScript.config.Add("additional_characters", 6, true);

-- The time that entities are auto-removed when no players are connected (seconds) (set to 0 for never).
kuroScript.config.Add("auto_remove_entities", 7200);

-- Whether or not the raised weapon system is enabled.
kuroScript.config.Add("raised_weapon_system", true, true);

-- Whether or not to enable prop protection.
kuroScript.config.Add("enable_prop_killing", false);

-- The time that it takes for contraband currency to be distrubuted (seconds).
kuroScript.config.Add("contraband_interval", 720);

-- Whether or not to enable entities to be punted with the gravity gun.
kuroScript.config.Add("enable_gravgun_punt", true);

-- The default inventory weight (kilograms).
kuroScript.config.Add("default_inv_weight", 20, true);

-- The time that it takes for data to be saved (seconds).
kuroScript.config.Add("save_data_interval", 180);

-- The time that a player has to wait for before they can holster a weapon (seconds).
kuroScript.config.Add("holster_wait_time", 1);

-- Whether or not a player's view gets punched when they take damage.
kuroScript.config.Add("damage_view_punch", true);

-- The amount to scale fall damage by.
kuroScript.config.Add("scale_fall_damage", 1);

-- Whether or not known names should be saved.
kuroScript.config.Add("save_known_names", true);

-- The default amount of currency that each player starts with.
kuroScript.config.Add("default_currency", 240);

-- Whether or not the crosshair is enabled.
kuroScript.config.Add("enable_crosshair", true, true);

-- Whether or not the anonymous system is enabled.
kuroScript.config.Add("anonymous_system", false, true);

-- The maximum weight of weapons that each player can equip (kilograms) (set to 0 for unlimited).
kuroScript.config.Add("max_equip_weight", 8);

-- The amount to scale chest damage by.
kuroScript.config.Add("scale_chest_dmg", 0.75);

-- The time that it takes for a player's ragdoll to decay (seconds).
kuroScript.config.Add("body_decay_time", 1200);

-- The message that a player receives when trying to join while banned (!t for the time left, !f for the time format).
kuroScript.config.Add("banned_message", "You are still banned for !t more !f.");

-- The time that it takes for wages currency to be distrubuted (seconds).
kuroScript.config.Add("wages_interval", 720);

-- How to much to scale prop cost by.
kuroScript.config.Add("scale_prop_cost", 1);

-- Whether or not to fade dead NPCs.
kuroScript.config.Add("fade_dead_npcs", true, true);

-- The weight of currency (kilograms).
kuroScript.config.Add("currency_weight", 0.001, true);

-- The name that is given to anonymous players.
kuroScript.config.Add("anonymous_name", "Unknown", true);

-- The amount to scale head damage by.
kuroScript.config.Add("scale_head_dmg", 1);

-- The chance that a player will over when landing from a high drop (from 0 to 1).
kuroScript.config.Add("land_fall_over", 0.75);

-- Whether or not inventory binds should be blocked for players.
kuroScript.config.Add("block_inv_binds", true, true);

-- The amount to scale limb damage by.
kuroScript.config.Add("scale_limb_dmg", 0.5);

-- Whether or not to enable headbob.
kuroScript.config.Add("enable_headbob", true, true);

-- The prefix that is used for chat commands.
kuroScript.config.Add("command_prefix", "/", true);

-- The speed that characters walk at when crouched.
kuroScript.config.Add("crouched_speed", 25);

-- The details that each player begins with.
kuroScript.config.Add("default_details", "", true);

-- The access that each player begins with.
kuroScript.config.Add("default_access", "", true);

-- Whether players can spray their tags.
kuroScript.config.Add("disable_sprays", true);

-- The time that a hint is displayed to each player.
kuroScript.config.Add("hint_interval", 30);

-- The maximum prop size that each player can spawn (units) (set to 0 for unlimited).
kuroScript.config.Add("max_prop_size", 384);

-- The time that a player has to wait to speak out-of-character again (seconds) (set to 0 for never).
kuroScript.config.Add("ooc_interval", 120);

-- The time that it takes for a minute to pass (seconds).
kuroScript.config.Add("minute_time", 1, true);

-- The time that a player has to wait to unlock a door (seconds).
kuroScript.config.Add("unlock_time", 3);

-- Whether or not to enable local voice.
kuroScript.config.Add("local_voice", true, true);

-- The radius of each player that other characters have to be in to hear them talk (units).
kuroScript.config.Add("talk_radius", 288, true);

-- The name that is given to wages.
kuroScript.config.Add("wages_name", "Wages", true);

-- The power that characters jump at.
kuroScript.config.Add("jump_power", 160);

-- The time that a player has to wait before they can spawn again (seconds).
kuroScript.config.Add("spawn_time", 60);

-- The speed that characters walk at.
kuroScript.config.Add("walk_speed", 100);

-- The speed that characters run at.
kuroScript.config.Add("run_speed", 225);

-- Whether it costs to spawn props.
kuroScript.config.Add("prop_cost", true);

-- The amount of currency that each door costs.
kuroScript.config.Add("door_cost", 50, true);

-- The time that a player has to wait to lock a door (seconds).
kuroScript.config.Add("lock_time", 2);

-- The maximum amount of doors a player can own.
kuroScript.config.Add("max_doors", 5);