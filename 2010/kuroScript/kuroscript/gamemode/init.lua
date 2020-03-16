--[[
Name: "init.lua".
Product: "kuroScript".
--]]

require("gamedescription");
require("transmittools");
require("datastream");
require("tmysql");
require("json");
require("glon");

-- Include some files.
include("nwvar/nwvars.lua"); 
include("frame/sv_autorun.lua"); 

-- Add a shared Lua file.
AddCSLuaFile("cl_init.lua");