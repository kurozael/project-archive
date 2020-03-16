--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localize Global Tables ]]--
local table = table;
local os = os;

--[[ Localize Global Functions ]]--
local AddCSLuaFile = AddCSLuaFile;
local include = include;
local Color = Color;
local MsgC = MsgC;

--[[
	Derive from Sandbox, because we want the spawn menu and such!
	We also want the base Sandbox entities and weapons.
]]--
DeriveGamemode("sandbox");

--[[
	If we are autorefreshing, then we want to preserve the global gamemode table, 
	to merge it with the new Crowlite table later.
]]--
if (Crow) then
	PreviousGM = Crow;	
end;

--[[
	Create the new Crowlite gamemode table and have it reference
	the global GM (GameMode) table.
]]--
Crow = GM;

--[[
	If we have stored the gamemode from before the refresh, then we merge it with
	the current table and remove the now unneeded global table after the merge.
]]--
if (PreviousGM) then
	table.Merge(GM, PreviousGM);

	PreviousGM = nil;
end;

--[[ Specify all the gamemode information and build variables. ]]--
Crow.IsDeveloperVersion = true;
Crow.BuildName = "pre-alpha";
Crow.BuildVersion = "0.0.0";
Crow.Website = "http://cloudsixteen.com";
Crow.Author = "Cloud Sixteen";
Crow.Name = "crowlite";

--[[
	@codebase Shared
	@details Called when the gamemode is reloaded with auto-refresh.
]]--
function Crow:OnReloaded()
	print("AAA");
	print(isReloading);
	timer.Simple(0.5, function()
		isReloading = false;
	end);

	print(isReloading);

	if (CLIENT) then
		net.Start("AuthReloadedClient");
		net.SendToServer();
	end;
end;

--[[
	@codebase Shared
	@details Called to get the name of the gamemode to be displayed in the server browser.
]]--
function Crow:GetGameDescription()
	local name = "CW: HL2 RP";
	local isStealthMode = true;

	if (!isStealthMode and Crow.package) then
		local CrowGame = Crow.package:GetActiveGamemode();

		if (CrowGame and CrowGame.name) then
			name = CrowGame.name;
		end;
	end;

	return name;
end;

--[[ These are aliases to avoid variable name conflicts. ]]--
_player, _team, _file, _package = player, team, file, package;

--[[ Include Nest Files ]]--
if (SERVER) then
	AddCSLuaFile("nest/cl_nest.lua");
	AddCSLuaFile("nest/sh_nest.lua");

	include("nest/sh_nest.lua");
	include("nest/sv_nest.lua");
else
	include("nest/sh_nest.lua");
	include("nest/cl_nest.lua");
end;

--[[ Include Meta Objects ]]--
Crow.nest:IncludeDirectory("meta/", true);

--[[ Include the Package Library ]]--
Crow.nest:IncludeFile("crowlite/gamemode/dependencies/sh_package.lua");

--[[ Include Library Files ]]--
Crow.nest:IncludeDirectory("libraries/", true);
Crow.nest:IncludeDirectory("libraries/server/", true);
Crow.nest:IncludeDirectory("libraries/client/", true);

if (SERVER) then
	for k, v in pairs(_player.GetAll()) do
		v.crowAuthed = nil;
	end;

	util.AddNetworkString("AuthReloadedClient");

	net.Receive("AuthReloadedClient", function(len, ply)
		if (!ply.crowAuthed) then
			Crow:PlayerAuthed(ply);

			ply.crowAuthed = true;
		end;
	end);
end;

--[[ Add Default Extras ]]--
Crow.package:AddExtra("/derma/");
Crow.package:AddExtra("/libraries/");
Crow.package:AddExtra("/libraries/server/");
Crow.package:AddExtra("/libraries/client/");
Crow.package:AddExtra("/phrases/");
Crow.package:AddExtra("/hooks/");
Crow.package:AddExtra("/meta/");

--[[ Include Language Phrases ]]--
Crow.nest:IncludeDirectory("phrases/", true);

--[[ Include Crowlite Hooks ]]--
Crow.nest:IncludeDirectory("hooks/", true);