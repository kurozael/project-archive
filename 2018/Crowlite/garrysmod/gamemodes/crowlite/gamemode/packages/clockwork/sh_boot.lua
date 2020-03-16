--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local CrowNest = Crow.nest;

CrowNest:IncludeFile("sh_kernel.lua");
CrowNest:IncludeFile("sv_kernel.lua");
CrowNest:IncludeFile("cl_kernel.lua");

function Clockwork:GetGameDescription()
--	local schemaName = self.kernel:GetSchemaGamemodeName();
--	return "CW: "..schemaName;
end;