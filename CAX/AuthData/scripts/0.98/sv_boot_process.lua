local cax_serial = nil;
local cax_session_token = nil;
local cax_slot_limit = nil;

if (cax_slot_limit and game.MaxPlayers() > cax_slot_limit) then
	MsgN("[CloudAuthX] This license key is not authorized to run on servers with more than "..cax_slot_limit.." servers! Visit https://store.cloudsixteen.com to purchase a key with a higher slot limit.");
	RunConsoleCommand("gamemode", "sandbox");
	RunConsoleCommand("changelevel", "gm_construct");
	return;
end;

local playerMeta = FindMetaTable("Player");

playerMeta.ClockworkSteamID64 = playerMeta.ClockworkSteamID64 or playerMeta.SteamID64;

function playerMeta:SteamID64()
	local value = self:ClockworkSteamID64();
	
	if (value == nil) then
		return "";
	else
		return value;
	end;
end;

concommand.Add("gm_save", function(ply) end);

local oldVersion = CloudAuthX.GetVersion;

function CloudAuthX.GetVersion()
	return math.floor(oldVersion());
end;

function AddRestartMessage(message)
	if (CW_RESTART_MESSAGE == nil) then
		CW_RESTART_MESSAGE = message;
	else
		CW_RESTART_MESSAGE = CW_RESTART_MESSAGE..", "..message;
	end;
	
	CW_RESTART_LEVEL = true;
end;

CLOUDAUTHX_VERSION = CloudAuthX.GetVersion();

if (not system.IsLinux()) then
	require("tmysql4");
else
	require("mysqloo");
end;

if (not CW_SCRIPT_SHARED.clientCode) then
	CW_SCRIPT_SHARED.clientCode = "";
end;

CW_SCRIPT_SHARED.clientCode = CW_SCRIPT_SHARED.clientCode..[[
	cax_include("cl_boot_process");
]];

cax_include("sh_networking");

cax_include("sv_sha1");

cax_include("sv_maintenance");

cax_include("sv_patch_files");

cax_include("sv_automodule");

cax_include("mods/sh_phys_desc");

function SimpleBan(name, steamId, duration, reason, fullTime)
	if (not fullTime) then
		duration = os.time() + duration;
	end;
	
	Clockwork.bans.stored[steamId] = {
		unbanTime = duration,
		steamName = name,
		duration = duration,
		reason = reason
	};
end;

function Clockwork:LoadPostSchemaExternals()
	--SimpleBan("Example", "STEAM_EXAMPLE", 0, "CloudSixteen.com ToS Violation");
end;

function Clockwork:LoadPreSchemaExternals()
	cax_include("lib/sh_plugin");
	cax_include("lib/sv_player");
	
	cax_include("sv_cloudax");
	
	cax_include("mods/sv_logo");
	--cax_include("mods/sv_schema_rename");
	cax_include("mods/sv_map_protect");
end;

function GET_URL(url, callback)
	if (CloudAuthX.WebFetch) then
		callback(CloudAuthX.WebFetch(url));
	else
		http.Fetch(url,
			function(body, len, headers, code)
				callback(body);
			end,
			function(error) end
		);
	end;
end;

AUTH_PLUGIN_URL = "http://authx.cloudsixteen.com/data/plugins/";
AUTH_PLUGINS_UPDATED = 0;
AUTH_PLUGIN_NAMES = {};
AUTH_MANIFEST_DATA = {};
AUTH_PLUGIN_DATA = {};
AUTH_TEST = {};

function AUTH_LOAD_PLUGIN()
	local pluginName = string.gsub(AUTH_PLUGIN_NAMES[1], "\n", "");
		pluginName = string.gsub(pluginName, "\r", "");
		
	local fileName = string.gsub(AUTH_MANIFEST_DATA[1], "\n", "");
		fileName = string.gsub(fileName, "\r", "");
		
	math.randomseed(os.time());
	
	GET_URL(AUTH_PLUGIN_URL..pluginName.."/"..fileName.."?id="..math.random(1, 9999999),
		function(body)
			Clockwork.file:Write("gamemodes/clockwork/plugins/"..pluginName.."/"..fileName, body);
			
			table.remove(AUTH_MANIFEST_DATA, 1);
			
			if (#AUTH_MANIFEST_DATA > 0) then
				AUTH_LOAD_PLUGIN()
			else
				AUTH_PLUGINS_UPDATED = AUTH_PLUGINS_UPDATED + 1;
				
				table.remove(AUTH_PLUGIN_NAMES, 1);
				AUTH_LOAD_PLUGIN_MANIFEST();
			end;
		end,
		function(error) end
	);
end;

function AUTH_LOAD_PLUGIN_MANIFEST()
	if (#AUTH_PLUGIN_NAMES == 0) then
		if (AUTH_PLUGINS_UPDATED > 0) then
			AddRestartMessage(AUTH_PLUGINS_UPDATED.." Plugin(s) Updated");
		end;
		
		return;
	end;
	
	local pluginName = AUTH_PLUGIN_NAMES[1];
	local manifestLocation = "clockwork/plugins/"..pluginName.."/manifest.txt";
	local currentVersion = 0;
	
	if (cwFile.Exists(manifestLocation, "LUA")) then
		local AUTH_MANIFEST_DATA = cwFile.Read(manifestLocation, "LUA");
		currentVersion = tonumber(string.Explode("\n", AUTH_MANIFEST_DATA)[1]);
	end;
	
	math.randomseed(os.time());
	
	GET_URL(AUTH_PLUGIN_URL..pluginName.."/manifest.txt?id="..math.random(1, 9999999),
		function(body)
			AUTH_MANIFEST_DATA = string.Explode("\n", body);
			
			local version = tonumber(AUTH_MANIFEST_DATA[1]);
			
			table.remove(AUTH_MANIFEST_DATA, 1);
			
			if (currentVersion < version) then
				AUTH_LOAD_PLUGIN();
			else
				table.remove(AUTH_PLUGIN_NAMES, 1);
				AUTH_LOAD_PLUGIN_MANIFEST();
			end;
		end,
		function(error) end
	 );
end;

AUTH_INITIALIZED = false;

function CloudAuthX:GetToken()
	return cax_session_token;
end;

function AUTH_INITIALIZE()
	math.randomseed(os.time());
	
	GET_URL(AUTH_PLUGIN_URL.."?id="..math.random(1, 9999999),
		function(body)
			if (not AUTH_INITIALIZED) then
				AUTH_PLUGIN_NAMES = string.Explode(",", body);
				AUTH_LOAD_PLUGIN_MANIFEST();
				AUTH_INITIALIZED = true;
			end;
		end,
		function(error)
			MsgN(error);
		end
	);
	
	MsgN("[CloudAuthX] The Plugin Center has been shut down. Visit https://eden.cloudsixteen.com for more information on where to find plugins now.");
end;

hook.Add("Think", "cax.Think", function()
	hook.Remove("Think", "cax.Think");
	AUTH_INITIALIZE();
end);

hook.Add("InitPostEntity", "cax.InitPostEntity", function()
	if (not AUTH_INITIALIZED) then
		AUTH_INITIALIZE();
	end;
end);