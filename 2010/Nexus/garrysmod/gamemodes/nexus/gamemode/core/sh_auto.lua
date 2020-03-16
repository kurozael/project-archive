--[[
Name: "sh_auto.lua".
Product: "nexus".
--]]

if (!NEXUS) then
	NEXUS = GM;
end;

nexus = {};
NEXUS.Name = "nexus";
NEXUS.Email = "kuropixel@gmail.com";
NEXUS.Author = "kuropixel";
NEXUS.Website = "http://kuropixel.com";
NEXUS.NexusFolder = GM.Folder;
NEXUS.SchemaFolder = NEXUS.Folder;

include("sh_core.lua");
include("sh_enums.lua");

hook.Remove("Think", "CheckSchedules");

if (!GetWorldEntity) then
	GetWorldEntity = function()
		return Entity(0);
	end;
end

g_Player, g_Team, g_File = player, team, file;

NEXUS:DeriveFromSandbox();
	NEXUS:IncludeDirectory("nexus/gamemode/core/libraries/");
	NEXUS:IncludeDirectory("nexus/gamemode/core/directory/");
	NEXUS:IncludeDirectory("nexus/gamemode/core/overwatch/");
	NEXUS:IncludeDirectory("nexus/gamemode/core/config/");
	
	if (SERVER) then
		nexus.mount.unloaded = NEXUS:RestoreSchemaData("unloaded");
		
		local unloadedTable = glon.encode(nexus.mount.unloaded);
		local fileName = os.time()..".txt";
		
		file.Write("nexus/temp/"..fileName, unloadedTable);
		resource.AddFile("data/nexus/temp/"..fileName);
	else
		local recentFile = {};
		
		for k, v in ipairs( file.Find("nexus/temp/*.txt") ) do
			local fileTime = file.Time("nexus/temp/"..v);
			
			if ( !recentFile[1] or fileTime >= recentFile[1] ) then
				recentFile[1] = fileTime;
				recentFile[2] = file.Read("nexus/temp/"..v);
			end;
			
			file.Delete("nexus/temp/"..v);
		end;
		
		if ( recentFile[1] and recentFile[2] ) then
			nexus.mount.unloaded = glon.decode( recentFile[2] );
		else
			nexus.mount.unloaded = {};
		end;
	end;
	
	NEXUS:RegisterGlobalSharedVar("sh_NoMySQL", NWTYPE_BOOL);
	NEXUS:RegisterGlobalSharedVar("sh_Minute", NWTYPE_NUMBER);
	NEXUS:RegisterGlobalSharedVar("sh_Date", NWTYPE_STRING);
	NEXUS:RegisterGlobalSharedVar("sh_Hour", NWTYPE_NUMBER);
	NEXUS:RegisterGlobalSharedVar("sh_Day", NWTYPE_NUMBER);

	nexus.player.RegisterSharedVar("sh_TargetRecognises", NWTYPE_BOOL, true);
	nexus.player.RegisterSharedVar("sh_StartActionTime", NWTYPE_FLOAT);
	nexus.player.RegisterSharedVar("sh_InventoryWeight", NWTYPE_NUMBER, true);
	nexus.player.RegisterSharedVar("sh_ActionDuration", NWTYPE_NUMBER);
	nexus.player.RegisterSharedVar("sh_WeaponRaised", NWTYPE_BOOL);
	nexus.player.RegisterSharedVar("sh_Initialized", NWTYPE_BOOL);
	nexus.player.RegisterSharedVar("sh_ForcedAnim", NWTYPE_NUMBER);
	nexus.player.RegisterSharedVar("sh_FallenOver", NWTYPE_BOOL, true);
	nexus.player.RegisterSharedVar("sh_Ragdolled", NWTYPE_NUMBER);
	nexus.player.RegisterSharedVar("sh_MaxHealth", NWTYPE_NUMBER, true);
	nexus.player.RegisterSharedVar("sh_MaxArmor", NWTYPE_NUMBER, true);
	nexus.player.RegisterSharedVar("sh_PhysDesc", NWTYPE_STRING);
	nexus.player.RegisterSharedVar("sh_Ragdoll", NWTYPE_ENTITY);
	nexus.player.RegisterSharedVar("sh_Jogging", NWTYPE_BOOL);
	nexus.player.RegisterSharedVar("sh_Faction", NWTYPE_NUMBER);
	nexus.player.RegisterSharedVar("sh_Action", NWTYPE_STRING);
	nexus.player.RegisterSharedVar("sh_Gender", NWTYPE_NUMBER);
	nexus.player.RegisterSharedVar("sh_Banned", NWTYPE_BOOL, true);
	nexus.player.RegisterSharedVar("sh_Flags", NWTYPE_STRING);
	nexus.player.RegisterSharedVar("sh_Drunk", NWTYPE_NUMBER, true);
	nexus.player.RegisterSharedVar("sh_Model", NWTYPE_STRING, true);
	nexus.player.RegisterSharedVar("sh_Wages", NWTYPE_NUMBER, true);
	nexus.player.RegisterSharedVar("sh_Cash", NWTYPE_NUMBER, true);
	nexus.player.RegisterSharedVar("sh_Name", NWTYPE_STRING);
	nexus.player.RegisterSharedVar("sh_Key", NWTYPE_NUMBER);
NEXUS:IncludeSchema();

if (SCHEMA) then
	if ( NEXUS:IncludeMounts("nexus/gamemode/mounts/") ) then
		NEXUS:IncludeDirectory("nexus/gamemode/core/attributes/");
		NEXUS:IncludeDirectory("nexus/gamemode/core/items/");
		NEXUS:IncludeDirectory("nexus/gamemode/core/derma/");
	end;
	
	if (nexus.item) then
		local itemTable = nexus.item.GetAll();
		
		for k, v in pairs(itemTable) do
			if ( v.base and !nexus.item.Merge(v, v.base) ) then
				itemTable[k] = nil;
			end;
		end;

		for k, v in pairs(itemTable) do
			v.description = v.description or "An item with no description.";
			v.category = v.category or "Other";
			v.weight = v.weight or 1;
			v.batch = v.batch or 5;
			v.model = v.model or "models/error.mdl";
			v.skin = v.skin or 0;
			v.cost = v.cost or 0;
			
			if (v.OnSetup) then
				v:OnSetup();
			end;
		end;
	end;
	
	if (CLIENT and nexus.chatBox) then
		nexus.chatBox.CreateDermaAll();
	end;

	if (nexus.command) then
		NEXUS:IncludePrefixed("sh_coms.lua");
	end;
else
	Error("The nexus schema could not be found! Please tell the administrator.");
end;