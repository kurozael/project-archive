--[[
Name: "sh_titan.lua".
Product: "titan".
--]]

require("glon");

include("titan/sh_auto.lua");

if (SERVER) then
	AddCSLuaFile("sh_titan.lua");
	AddCSLuaFile("titan/sh_auto.lua");
	AddCSLuaFile("titan/cl_auto.lua");
end;