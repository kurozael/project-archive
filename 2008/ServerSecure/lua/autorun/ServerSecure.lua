// ConVar

CreateConVar("ss_enable", "1", FCVAR_NOTIFY)

if (GetConVarNumber("ss_enable") == 1) then
	// Serverside

	include("ServerSecure/AutoRun.lua")

	// Clientside

	AddCSLuaFile("client/ServerSecureMain.lua")
	AddCSLuaFile("client/ServerSecureMenu.lua")
	AddCSLuaFile("client/ServerSecureMeta.lua")
end