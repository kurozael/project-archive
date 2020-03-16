--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

local oldType = type;

-- A function to get the type of an object.
function type(object)
	local classInfo = class_info(object);
	
	if (oldType(object) == "table"
	and object.__type) then
		return object.__type(object);
	end;
	
	if (classInfo and classInfo.name) then
		return classInfo.name;
	end;
	
	return oldType(object);
end;

-- A function to print a message to the console.
function print(...)
	local arguments = {};
		for k, v in ipairs({...}) do
			arguments[#arguments + 1] = tostring(v);
		end;
	display.Print(table.concat(arguments, "\t"));
end;

-- A function to import scripts in a directory.
function import(directory, Callback)
	local fileList = util.GrabFilesInDir("lua/"..directory.."/", nil, function(fileName)
		return (fileName ~= "." and fileName ~= "..");
	end);
	
	for k, v in ipairs(fileList) do
		if (util.IsDirectory(v)) then
			import(directory.."/"..v, Callback);
		else
			Callback(directory.."/"..v);
		end;
	end;
end;