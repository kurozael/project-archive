if SERVER then
	--[ START LOADING ]--
	
	Msg("\n\n**[ Loading ServerSecure by Conna ]**\n")

	------------------------------------------------
	----[ MAIN VARIABLES ]----------------
	------------------------------------------------
	
	SS 	          = {} -- Main table
	SS.Player     = {} -- Player functions.
	
	------------------------------------------------
	----[ INCLUDE ]----------------------------
	------------------------------------------------
	
	include("Core/Hooks.lua") -- Hooks before anything!
	
	------------------------------------------------
	----[ MODULES ]--------------------------
	------------------------------------------------
	
	// Commands
	
	include("Core/Commands/Chat.lua")
	include("Core/Commands/Console.lua")
	
	// Modules
	
	local Modules = file.FindInLua("ServerSecure/Core/Modules/*.lua")
	
	for K, V in pairs(Modules) do
		include("Core/Modules/"..V)
	end
	
	------------------------------------------------
	----[ INCLUDE FILES ]-------------------
	------------------------------------------------
	
	include("Core/Lib.lua")
	
	// Vars
	
	SS.Lib.FileInclude("ServerSecure/Core/VARS/", ".lua")
	
	// Other
	
	include("Core/Config.lua")
	include("Core/Purchases.lua")
	include("Core/Plugins.lua")
	
	// Core
	
	include("Core/Core.lua")
	
	// Folder search
	
	SS.Lib.FolderSearch("ServerSecure/Purchases/", ".lua")
	SS.Lib.FolderSearch("ServerSecure/Commands/", ".lua")
	
	// Clientside
	
	SS.Clientside.Folder("ServerSecure/Core/Clientside/", ".lua")
	
	// Custom content
	
	Msg("\n")
	
	SS.Lib.AddCustomContent("sounds/ServerSecure/")
	SS.Lib.AddCustomContent("models/ServerSecure/")
	SS.Lib.AddCustomContent("materials/ServerSecure/")
	
	Msg("\n\n**[ Loaded ServerSecure ]**\n\n")
end