--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	This is where any generic exploit or bypass will go. Just a warning in advance,
	this work is not under a free-to-use license and any unauthorized servers will be
	given a DCMA notice by Ideal-Hosting.biz. Thank you for being so understanding
	and woooooh for DRM.
--]]

if (!openAura) then
	return MsgN("[OpenAuth] You need to require the openaura_core module in init.lua!");
end;

require("json");
require("openaura_one");
require("openaura_two");
require("openaura_three");
require("openaura_four");

include("openaura/sv_auto.lua"); 
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("includes/modules/json.lua");