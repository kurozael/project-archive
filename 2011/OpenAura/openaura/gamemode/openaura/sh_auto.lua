--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.Name = "OpenAura";
openAura.Email = "kurozael@gmail.com";
openAura.Author = "kurozael";
openAura.Website = "http://kurozael.com";
openAura.CoreVersion = 1.12;
openAura.SchemaFolder = openAura.Folder;
openAura.OpenAuraFolder = GM.Folder;

include("sh_enums.lua");
include("sh_core.lua");

if (!GetWorldEntity) then
	GetWorldEntity = function()
		return Entity(0);
	end;
end

_player, _team, _file = player, team, file;

openAura:DeriveFromSandbox();
openAura:IncludeDirectory("openaura/gamemode/openaura/libraries/");
openAura:IncludeDirectory("openaura/gamemode/openaura/directory/");
openAura:IncludeDirectory("openaura/gamemode/openaura/moderator/");
openAura:IncludeDirectory("openaura/gamemode/openaura/config/");

if (SERVER) then
	openAura.plugin.unloaded = openAura:RestoreSchemaData("plugins");
		fileio.Write( openAura:SetupFullDirectory("lua/autorun/client/openaura.lua"), [[UNLOADED_PLUGINS = "]]..glon.encode(openAura.plugin.unloaded)..[[";]] );
	AddCSLuaFile("autorun/client/openaura.lua");
elseif (UNLOADED_PLUGINS) then
	openAura.plugin.unloaded = glon.decode(UNLOADED_PLUGINS);
else
	openAura.plugin.unloaded = {};
end;

openAura:RegisterGlobalSharedVar("noMySQL", NWTYPE_BOOL);
openAura:RegisterGlobalSharedVar("noAuth", NWTYPE_BOOL);
openAura:RegisterGlobalSharedVar("minute", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("date", NWTYPE_STRING);
openAura:RegisterGlobalSharedVar("hour", NWTYPE_NUMBER);
openAura:RegisterGlobalSharedVar("day", NWTYPE_NUMBER);

openAura.player:RegisterSharedVar("targetRecognises", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("inventoryWeight", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("fallenOver", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("maxHealth", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("maxArmor", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("banned", NWTYPE_BOOL, true);
openAura.player:RegisterSharedVar("drunk", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("model", NWTYPE_STRING, true);
openAura.player:RegisterSharedVar("wages", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("cash", NWTYPE_NUMBER, true);

openAura.player:RegisterSharedVar("startActionTime", NWTYPE_FLOAT);
openAura.player:RegisterSharedVar("actionDuration", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("weaponRaised", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("initialized", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("forcedAnim", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("ragdolled", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("physDesc", NWTYPE_STRING);
openAura.player:RegisterSharedVar("ragdoll", NWTYPE_ENTITY);
openAura.player:RegisterSharedVar("jogging", NWTYPE_BOOL);
openAura.player:RegisterSharedVar("faction", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("action", NWTYPE_STRING);
openAura.player:RegisterSharedVar("gender", NWTYPE_NUMBER);
openAura.player:RegisterSharedVar("flags", NWTYPE_STRING);
openAura.player:RegisterSharedVar("name", NWTYPE_STRING);
openAura.player:RegisterSharedVar("key", NWTYPE_NUMBER);
openAura:IncludeSchema();

if (openAura.schema) then
	if ( openAura:IncludePlugins("openaura/gamemode/plugins/") ) then
		openAura:IncludeDirectory("openaura/gamemode/openaura/attributes/");
		openAura:IncludeDirectory("openaura/gamemode/openaura/items/");
		openAura:IncludeDirectory("openaura/gamemode/openaura/derma/");
	end;
	
	if (CLIENT) then
		openAura.SpawnIconMaterial = Material("vgui/spawnmenu/hover");
		openAura.DefaultGradient = surface.GetTextureID("gui/gradient_up");
		openAura.GradientTexture = surface.GetTextureID( openAura.option:GetKey("gradient") );
		openAura.OpenAuraSplash = Material("openaura/openAura");
		openAura.ScreenBlur = Material("pp/blurscreen");
	end;
	
	if (openAura.item) then
		local itemsTable = openAura.item:GetAll();
		
		for k, v in pairs(itemsTable) do
			if ( v.base and !openAura.item:Merge(v, v.base) ) then
				itemsTable[k] = nil;
			end;
		end;

		for k, v in pairs(itemsTable) do
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
			
			if ( openAura.item:IsWeapon(v) ) then
				openAura.item.weapons[v.weaponClass] = v;
			end;
			
			openAura.plugin:Call("OpenAuraItemInitialized", v);
		end;
	end;
	
	if (CLIENT and openAura.chatBox) then
		openAura.chatBox:CreateDermaAll();
	end;

	if (openAura.command) then
		openAura:IncludePrefixed("sh_coms.lua");
	end;
	
	openAura.plugin:Call("OpenAuraSchemaLoaded");
else
	Error("OpenAura -> The schema could not be found!");
end;