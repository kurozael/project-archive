--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (!CloudScript) then
	return MsgN("[CloudScript] You need to set the CloudScript table in init.lua!");
end;

require("json"); require("gm_fileio");
require("gm_tmysql"); require("gm_sourcenet3");

include("CloudScript/sh_auto.lua"); 
AddCSLuaFile("cl_init.lua");