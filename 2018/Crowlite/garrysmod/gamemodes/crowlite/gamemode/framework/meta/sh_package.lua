--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
]]--

CROW_PACKAGE = {__index = CROW_PACKAGE};

CROW_PACKAGE.description = "An undescribed package or gamemode.";
CROW_PACKAGE.folderName = "Unknown";
CROW_PACKAGE.baseDir = "Unknown";
CROW_PACKAGE.author = "Unknown";
CROW_PACKAGE.name = "Unknown";

CROW_PACKAGE.version = {
	string = "1.0",
	major = 1,
	minor = 0,
	patch = 0
};

CROW_PACKAGE.extras = {
	entities = {},
	effects = {},
	weapons = {}
};

CROW_PACKAGE.SetNamespace = function(CROW_PACKAGE, namespace)
	_G[namespace] = CROW_PACKAGE;
end;	
	
CROW_PACKAGE.GetDescription = function(CROW_PACKAGE)
	return CROW_PACKAGE.description;
end;
	
CROW_PACKAGE.GetBaseDir = function(CROW_PACKAGE)
	return CROW_PACKAGE.baseDir;
end;

CROW_PACKAGE.GetVersion = function(CROW_PACKAGE)
	return CROW_PACKAGE.version;
end;
	
CROW_PACKAGE.GetAuthor = function(CROW_PACKAGE)
	return CROW_PACKAGE.author;
end;
	
CROW_PACKAGE.GetName = function(CROW_PACKAGE)
	return CROW_PACKAGE.name;
end;
	
CROW_PACKAGE.Register = function(CROW_PACKAGE)
	Crow.package:Register(CROW_PACKAGE);
end;