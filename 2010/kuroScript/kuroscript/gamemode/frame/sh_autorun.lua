--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

kuroScript = {};
kuroScript.frame = KS_GAMEMODE;
kuroScript.frame.Name = "DongoScript";
kuroScript.frame.Email = "Dongo@dongo.com";
kuroScript.frame.Author = "Dongo";
kuroScript.frame.Website = "http://thedigitalsoul.net/forum/";

-- Include a file.
include("scheme/sh_frame.lua");
include("scheme/sh_enums.lua");

-- Remove a hook.
hook.Remove("Think", "CheckSchedules");

-- Derive from Sandbox.
kuroScript.frame:DeriveFromSandbox();

-- Register a global networked table.
RegisterNWTableGlobal( {
	{"ks_Minute", 0, NWTYPE_SHORT, REPL_EVERYONE},
	{"ks_Date", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Hour", 0, NWTYPE_SHORT, REPL_EVERYONE},
	{"ks_Day", 0, NWTYPE_SHORT, REPL_EVERYONE}
} );

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_StartActionTime", 0, NWTYPE_FLOAT, REPL_EVERYONE},
	{"ks_InventoryWeight", 0, NWTYPE_NUMBER, REPL_PLAYERONLY},
	{"ks_ActionDuration", 0, NWTYPE_NUMBER, REPL_EVERYONE},
	{"ks_WeaponRaised", false, NWTYPE_BOOL, REPL_EVERYONE},
	{"ks_Initialized", false, NWTYPE_BOOL, REPL_EVERYONE},
	{"ks_FallenOver", false, NWTYPE_BOOL, REPL_PLAYERONLY},
	{"ks_Ragdolled", RAGDOLL_NONE, NWTYPE_CHAR, REPL_EVERYONE},
	{"ks_MaxHealth", 100, NWTYPE_SHORT, REPL_EVERYONE},
	{"ks_MaxArmor", 0, NWTYPE_SHORT, REPL_EVERYONE},
	{"ks_Currency", 0, NWTYPE_NUMBER, REPL_PLAYERONLY},
	{"ks_Ragdoll", NULL, NWTYPE_ENTITY, REPL_EVERYONE},
	{"ks_Jogging", false, NWTYPE_BOOL, REPL_EVERYONE},
	{"ks_Details", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Action", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Gender", 0, NWTYPE_CHAR, REPL_EVERYONE},
	{"ks_Access", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Drunk", 0, NWTYPE_SHORT, REPL_PLAYERONLY},
	{"ks_Class", 0, NWTYPE_NUMBER, REPL_EVERYONE},
	{"ks_Model", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Wages", 0, NWTYPE_SHORT, REPL_PLAYERONLY},
	{"ks_Skin", 0, NWTYPE_SHORT, REPL_EVERYONE},
	{"ks_Name", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Key", 0, NWTYPE_SHORT, REPL_EVERYONE}
} );

-- Set some information.
g_Player, g_Team, g_File = player, team, file;

-- Include some directories.
kuroScript.frame:IncludeDirectory("kuroscript/gamemode/frame/scheme/libraries/");
kuroScript.frame:IncludeDirectory("kuroscript/gamemode/frame/scheme/directory/");
kuroScript.frame:IncludeDirectory("kuroscript/gamemode/frame/scheme/config/");

-- Include the game mount.
kuroScript.frame:IncludeGameMount();

-- Check if a statement is true.
if (kuroScript.game) then
	kuroScript.frame:IncludeMounts("kuroscript/gamemode/mounts/");

	-- Include some directories.
	kuroScript.frame:IncludeDirectory("kuroscript/gamemode/frame/scheme/objects/attributes/");
	kuroScript.frame:IncludeDirectory("kuroscript/gamemode/frame/scheme/objects/items/");
	kuroScript.frame:IncludeDirectory("kuroscript/gamemode/frame/scheme/derma/");

	-- Check if a statement is true.
	if (kuroScript.item) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.item.stored) do
			if (v.base and !v.isBaseItem) then
				if ( !kuroScript.item.Merge(v, v.base) ) then
					kuroScript.item.stored[k] = nil;
				end;
			end;
		end;

		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.item.stored) do
			v.description = v.description or "An item with no description.";
			v.category = v.category or "Miscellaneous";
			v.weight = v.weight or 1;
			v.batch = v.batch or 5;
			v.model = v.model or "models/error.mdl";
			v.skin = v.skin or 0;
			v.cost = v.cost or 0;
			
			-- Check if a statement is true.
			if (v.OnSetup) then
				v:OnSetup();
			end;
		end;
	end;

	-- Check if a statement is true.
	if (kuroScript.command) then
		kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
	end;
else
	Error("The kuroScript game could not be found! Please tell the administrator.");
end;