------------------------------------------------
----[ CLIENTSIDE ]-----------------------
------------------------------------------------

SS.Clientside       = {} -- Client table.
SS.Clientside.List  = {} -- Clientside list.

// Add clientside file

function SS.Clientside.Add(File)
	AddCSLuaFile(File)
	
	table.insert(SS.Clientside.List, File)
end

// Add clientside folder

function SS.Clientside.Folder(Folder, Extension)
	local Files = file.Find("../lua/"..Folder.."*"..Extension)

	Msg("\n")
	
	for K, V in pairs(Files) do
		SS.Clientside.Add(Folder..V)
		
		Msg("\n\t[Clientside] File - "..V.." loaded")
	end
	
	Msg("\n")
end

// PlayerInitialSpawn hook

function SS.Clientside.PlayerInitialSpawn(Player)
	for K, V in pairs(SS.Clientside.List) do
		Player:IncludeFile(V)
	end
end

// Hook into player initial spawn

SS.Hooks.Add("SS.Clientside.PlayerInitialSpawn", "PlayerInitialSpawn", SS.Clientside.PlayerInitialSpawn)