--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

CROW_LIBRARY = {__index = CROW_LIBRARY};

--[[
	@codebase Shared
	@details A function to add a library's function to a metatable easily.
	@params String The name of the metatable that will have the new function inserted into (Player, Entity, etc).
	@params String The name of the function in the library that will be added to the specified metatable.
	@params String The name that the function will be stored in the metatable as, this is optional, will default to the original function's name.
]]--
function CROW_LIBRARY:AddToMeta(metaName, funcName, newName)
	local metaTable = metaName;
	
	if (type(metaName) == "string") then
		metaTable = FindMetaTable(metaName);
	end;
	
	metaTable[newName or funcName] = function(...)
		return self[funcName](self, ...);
	end;
end;