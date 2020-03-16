SS.Plugins      = {} -- Plugins table.
SS.Plugins.List = {} -- Plugins list.

-------------------------------------------------------------
----[ INITIATE NEW PLUGIN ]--------------------
-------------------------------------------------------------

function SS.Plugins:New(Index)
	local Table = {}
	
	setmetatable(Table, self)
	self.__index = self
	
	Table.Name = Index
	
	return Table
end

-------------------------------------------------------------
----[ RUN PLUGIN HOOKS ]-------------------------
-------------------------------------------------------------

function SS.Plugins.Run(Index, ...)
	for K, V in pairs(SS.Plugins.List) do
		if (V[Index]) then
			local B, Return = pcall(V[Index], unpack(arg))
			
			if !B then
				SS.Lib.Error("PLUGIN HOOK ERROR, "..tostring(Return).."!")
			end
		end
	end
end

SS.Hooks.Add("SS.Plugins.Run", "ServerHook", SS.Plugins.Run)

-------------------------------------------------------------
----[ FINALISE PLUGIN ]----------------------------
-------------------------------------------------------------

function SS.Plugins:Create()
	table.insert(SS.Plugins.List, self)
end

-------------------------------------------------------------
----[ GET A PLUGIN ]----------------------------------
-------------------------------------------------------------

function SS.Plugins.Find(Index)
	for K, V in pairs(SS.Plugins.List) do
		if (V.Name == Index) then
			return V
		end
	end
	
	return false
end

-------------------------------------------------------------
----[ CONFIGURE CONSOLE ]-----------------------
-------------------------------------------------------------

function SS.Plugins.ConfigurePlugin(Player, Command, Args)
	if not (Args) or not (Args[1]) or not (Args[2]) then return end
	
	if (SS.Groups.Rank(SS.Player.Rank(Player)) == 1) then
		local Plugin = Args[2]
		
		if (Args[1] == "Enable") then
			SVAR.Request("Disabled Plugins")[Plugin] = nil
			
			SS.PlayerMessage(Player, Plugin.." has been enabled, a map change is required!", 0)
		else
			SVAR.Request("Disabled Plugins")[Plugin] = Plugin
			
			SS.PlayerMessage(Player, Plugin.." has been disabled, a map change is required!", 0)
		end
		
		timer.Simple(0.005, SS.Plugins.Configure, Player)
	else
		SS.PlayerMessage(Player, "You need to be a "..SS.Groups.ID(1).." to configure plugins!", 1)
	end
end

concommand.Add("ss_configureplugin", SS.Plugins.ConfigurePlugin)

-------------------------------------------------------------
----[ CONFIGURE ]-------------------------------------
-------------------------------------------------------------

function SS.Plugins.Configure(Player)
	local Panel = SS.Panel:New(Player, "Plugin Configuration")
	
	local List = file.Find("../lua/ServerSecure/Plugins/*")

	for K, V in pairs(List) do
		local Lower = string.lower(V)
		
		if not (SVAR.Request("Disabled Plugins")[Lower]) then
			Panel:Button(V, 'ss_configureplugin "Disable" "'..Lower..'"', 150, 250, 100)
		else
			Panel:Button(V, 'ss_configureplugin "Enable" "'..Lower..'"', 255, 100, 100)
		end
	end

	Panel:Send()
end

-------------------------------------------------------------
----[ CHECK PLUGIN ]---------------------------------
-------------------------------------------------------------

function SS.Plugins.Exists(Index)
	for K, V in pairs(SS.Plugins.List) do
		if (V.Name == Index) then
			return true
		end
	end
	
	return false
end

------------------------------------------------
----[ OPEN ALL PLUGINS ]--------------
------------------------------------------------

// New SVAR

SVAR.New("Disabled Plugins", {})

// Find plugins

local List = file.Find("../lua/ServerSecure/Plugins/*")

for K, V in pairs(List) do
	if (file.Exists("../lua/ServerSecure/Plugins/"..V.."/AutoRun.lua")) then
		local Lower = string.lower(V)
		
		if not (SVAR.Request("Disabled Plugins")[Lower]) then
			include("ServerSecure/Plugins/"..V.."/AutoRun.lua")
			
			if (file.Exists("../lua/ServerSecure/Plugins/"..V.."/Client.lua")) then
				SS.Clientside.Add("ServerSecure/Plugins/"..V.."/Client.lua")
			end
			
			Msg("\n\t[Plugin] File - "..V.." loaded")
		end
	end
end