--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	Never edit this file! All config editing should be done
	either through the .cfg files provides or through the
	in-game config editing systems.
--]]

CloudScript.config:Add("mysql_characters_table", "characters", nil, nil, true, true, true);
CloudScript.config:Add("mysql_players_table", "players", nil, nil, true, true, true);
CloudScript.config:Add("mysql_username", "", nil, nil, true, true, true);
CloudScript.config:Add("mysql_password", "", nil, nil, true, true, true);
CloudScript.config:Add("mysql_database", "", nil, nil, true, true, true);
CloudScript.config:Add("mysql_host", "", nil, nil, true, true, true);
CloudScript.config:Add("scale_attribute_progress", 1);
CloudScript.config:Add("messages_must_see_player", false, true);
CloudScript.config:Add("default_attribute_points", 30, true);
CloudScript.config:Add("enable_temporary_damage", true);
CloudScript.config:Add("enable_prop_protection", true);
CloudScript.config:Add("use_local_machine_date", false, nil, nil, nil, nil, true);
CloudScript.config:Add("use_local_machine_time", false, nil, nil, nil, nil, true);
CloudScript.config:Add("use_opens_entity_menus", true, true);
CloudScript.config:Add("shoot_after_raise_time", 1);
CloudScript.config:Add("save_recognised_names", true);
CloudScript.config:Add("save_attribute_boosts", false);
CloudScript.config:Add("ragdoll_immunity_time", 0.5);
CloudScript.config:Add("additional_characters", 2, true);
CloudScript.config:Add("change_class_interval", 180);
CloudScript.config:Add("raised_weapon_system", true, true);
CloudScript.config:Add("prop_kill_protection", true);
CloudScript.config:Add("CloudScript_intro_enabled", true);
CloudScript.config:Add("use_optimised_rates", true, nil, nil, nil, nil, true);
CloudScript.config:Add("sprint_lowers_weapon", true);
CloudScript.config:Add("use_own_group_system", false, true);
CloudScript.config:Add("generator_interval", 720);
CloudScript.config:Add("enable_gravgun_punt", true);
CloudScript.config:Add("default_inv_weight", 20, true);
CloudScript.config:Add("save_data_interval", 180);
CloudScript.config:Add("damage_view_punch", true);
CloudScript.config:Add("enable_heartbeat", true, true);
CloudScript.config:Add("unrecognised_name", "Somebody you do not recognise.", true);
CloudScript.config:Add("scale_fall_damage", 1);
CloudScript.config:Add("limb_damage_system", true, true);
CloudScript.config:Add("enable_vignette", true, true);
CloudScript.config:Add("use_free_aiming", true, true);
CloudScript.config:Add("default_cash", 40);
CloudScript.config:Add("armor_chest_only", false);
CloudScript.config:Add("minimum_physdesc", 32, true);
CloudScript.config:Add("wood_breaks_fall", true);
CloudScript.config:Add("enable_crosshair", true, true);
CloudScript.config:Add("recognise_system", true, true);
CloudScript.config:Add("cash_enabled", true, true, nil, nil, nil, true);
CloudScript.config:Add("default_physdesc", "", true);
CloudScript.config:Add("scale_chest_dmg", 1);
CloudScript.config:Add("body_decay_time", 600);
CloudScript.config:Add("banned_message", "You are still banned for !t more !f.");
CloudScript.config:Add("wages_interval", 720);
CloudScript.config:Add("scale_prop_cost", 1);
CloudScript.config:Add("fade_dead_npcs", true, true);
CloudScript.config:Add("cash_weight", 0.001, true);
CloudScript.config:Add("scale_head_dmg", 4);
CloudScript.config:Add("block_inv_binds", true, true);
CloudScript.config:Add("scale_limb_dmg", 0.5);
CloudScript.config:Add("enable_headbob", true, true);
CloudScript.config:Add("command_prefix", "/", true);
CloudScript.config:Add("crouched_speed", 25);
CloudScript.config:Add("default_flags", "", true);
CloudScript.config:Add("disable_sprays", true);
CloudScript.config:Add("owner_steamid", "STEAM_0:0:0000000", nil, nil, true, true, true);
CloudScript.config:Add("hint_interval", 30);
CloudScript.config:Add("ooc_interval", 120);
CloudScript.config:Add("minute_time", 60, true);
CloudScript.config:Add("unlock_time", 3);
CloudScript.config:Add("local_voice", true, true);
CloudScript.config:Add("talk_radius", 384, true);
CloudScript.config:Add("wages_name", "Wages", true);
CloudScript.config:Add("give_hands", true);
CloudScript.config:Add("give_keys", true);
CloudScript.config:Add("jump_power", 160);
CloudScript.config:Add("spawn_time", 60);
CloudScript.config:Add("walk_speed", 100);
CloudScript.config:Add("run_speed", 225);
CloudScript.config:Add("door_cost", 10, true);
CloudScript.config:Add("lock_time", 2);
CloudScript.config:Add("max_doors", 5);