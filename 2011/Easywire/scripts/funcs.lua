--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

local oldType = type;

-- A function to get the type of an object.
function type(object)
	local classInfo = class_info(object);
	
	if (classInfo and classInfo.name) then
		return classInfo.name;
	elseif (object.__type) then
		return object.__type(object);
	end;
	
	return oldType(object);
end;

-- A function to print a message to the console.
function print(...)
	local arguments = {};
		for k, v in ipairs( {...} ) do
			arguments[#arguments + 1] = tostring(v);
		end;
	g_Display:Print( table.concat(arguments, "\t") );
end;

-- A function to import scripts in a directory.
function import(directory, Callback)
	local files = util.GrabFilesInDir("scripts/"..directory.."/", nil, function(fileName)
		return (fileName ~= "." and fileName ~= "..");
	end);
	
	for k, v in ipairs(files) do
		if ( util.IsDirectory(v) ) then
			import(directory.."/"..v, Callback);
		else
			Callback(directory.."/"..v);
		end;
	end;
end;