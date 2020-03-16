--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (!openAura) then
	return MsgN("[OpenAuth] You need to set the gamemode table in cl_init.lua!");
end;

require("glon"); require("json");
include("openaura/cl_auto.lua");