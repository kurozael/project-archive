--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.Name = "CloudScript";
CloudScript.Email = "kurozael@gmail.com";
CloudScript.Author = "kurozael";
CloudScript.Website = "http://kurozael.com";
CloudScript.CoreVersion = 1.0;
CloudScript.SchemaFolder = CloudScript.Folder;
CloudScript.CloudScriptFolder = GM.Folder;

if (SERVER) then
	AddCSLuaFile("hooks/sh_hooks.lua");
	AddCSLuaFile("hooks/sv_hooks.lua");
	AddCSLuaFile("hooks/cl_hooks.lua");
	AddCSLuaFile("sh_auto.lua");
	AddCSLuaFile("sh_core.lua");
	AddCSLuaFile("sh_enum.lua");
	
	include("hooks/sv_hooks.lua");
else
	include("hooks/cl_hooks.lua");
end;

include("hooks/sh_hooks.lua");
include("sh_enum.lua");
include("sh_core.lua");

if (!GetWorldEntity) then
	GetWorldEntity = function()
		return Entity(0);
	end;
end

_player, _team, _file = player, team, file;

CloudScript:DeriveFromSandbox();
CloudScript:IncludeDirectory("CloudScript/gamemode/CloudScript/libraries/");
CloudScript:IncludeDirectory("CloudScript/gamemode/CloudScript/directory/");
CloudScript:IncludeDirectory("CloudScript/gamemode/CloudScript/config/");

if (CLOUD_SCRIPT_SHARED) then
	CLOUD_SCRIPT_SHARED = glon.decode(CLOUD_SCRIPT_SHARED);
else
	CLOUD_SCRIPT_SHARED = {};
end;

if (CLIENT) then
	local unloadedPlugins = CLOUD_SCRIPT_SHARED.unloadedPlugins;
		if (unloadedPlugins) then
			CloudScript.plugin.unloaded = unloadedPlugins;
		else
			CloudScript.plugin.unloaded = {};
		end;
	CLOUD_SCRIPT_SHARED.unloadedPlugins = nil;
else
	CLOUD_SCRIPT_SHARED.unloadedPlugins = CloudScript:RestoreSchemaData("plugins");
end;

CloudScript:IncludeSchema();

if (CloudScript.schema) then
	if ( CloudScript:IncludePlugins("CloudScript/gamemode/plugins/") ) then
		CloudScript:IncludeDirectory("CloudScript/gamemode/CloudScript/objects/system/");
		CloudScript:IncludeDirectory("CloudScript/gamemode/CloudScript/objects/items/");
		CloudScript:IncludeDirectory("CloudScript/gamemode/CloudScript/objects/derma/");
	end;
	
	if (CLIENT) then
		CloudScript.SpawnIconMaterial = Material("vgui/spawnmenu/hover");
		CloudScript.DefaultGradient = surface.GetTextureID("gui/gradient_up");
		CloudScript.GradientTexture = surface.GetTextureID( CloudScript.option:GetKey("gradient") );
		CloudScript.CloudScriptSplash = Material("CloudScript/CloudScript");
		CloudScript.ScreenBlur = Material("pp/blurscreen");
	end;
	
	if (CloudScript.item) then
		local itemsTable = CloudScript.item:GetAll();
		
		for k, v in pairs(itemsTable) do
			if ( v.base and !CloudScript.item:Merge(v, v.base) ) then
				itemsTable[k] = nil;
			end;
		end;

		for k, v in pairs(itemsTable) do
			v.description = v.description or "An item with no description.";
			v.networked = {};
			v.category = v.category or "Other";
			v.weight = v.weight or 1;
			v.batch = v.batch or 5;
			v.model = v.model or "models/error.mdl";
			v.skin = v.skin or 0;
			v.cost = v.cost or 0;
			v.data = v.data or {};
			
			if (v.OnSetup) then v:OnSetup(); end;
			
			if ( CloudScript.item:IsWeapon(v) ) then
				CloudScript.item.weapons[v.weaponClass] = v;
			end;
			
			CloudScript.plugin:Call("CloudScriptItemInitialized", v);
		end;
	end;
	
	if (CLIENT and CloudScript.chatBox) then
		CloudScript.chatBox:CreateDermaAll();
	end;

	if (CloudScript.command) then
		CloudScript:IncludePrefixed("plugin/sh_coms.lua");
	end;
	
	CloudScript.plugin:Call("CloudScriptSchemaLoaded");
else
	Error("[CloudScript] The schema could not be located or does not exist!");
end;

if (SERVER) then
	CloudScript.plugin:Call("CloudScriptSaveShared", CLOUD_SCRIPT_SHARED);
	
	local filePath = CloudScript:SetupFullDirectory("lua/autorun/client/CloudScript.lua");
	local saveData = [[CLOUD_SCRIPT_SHARED = "]]..glon.encode(CLOUD_SCRIPT_SHARED)..[[";]];
	
	fileio.Write(filePath, saveData);
	AddCSLuaFile("autorun/client/CloudScript.lua");
else
	CloudScript.plugin:Call("CloudScriptLoadShared", CLOUD_SCRIPT_SHARED);
end;

local sharedVars = CloudScript:GetSharedVars();

CloudScript.plugin:Call("CloudScriptAddSharedVars",
	sharedVars:Global(true),
	sharedVars:Player(true)
);