--[[
Name: "sh_auto.lua".
Product: "titan".
--]]

titan = {
	nextCheckCreated = 0,
	onCreatedQueue = {},
	ignoredKeys = {},
	quickTimers = {},
	entityMeta = FindMetaTable("Entity"),
	varClasses = {},
	longTimers = {},
	slowTimers = {},
	netVars = {}
};

if (SERVER) then
	include("sv_enums.lua");
	include("sv_auto.lua");
else
	include("cl_auto.lua");
end;

g_Player = player;
g_Timer = timer;
g_Hook = hook;
g_Team = team;
g_File = file;

if (!titan.originalSetGlobalVar) then
	titan.originalSetGlobalVar = _G["SetGlobalVar"];
end;

if (!titan.originalSetNWVar) then
	titan.originalSetNWVar = titan.entityMeta["SetNetworkedVar"];
end;

titan.entityMeta["SetNetworkedVarProxy"] = function(entity, key, callback)
	if (!entity.fn_Proxies) then
		entity.fn_Proxies = {};
	end;
	
	entity.fn_Proxies[key] = callback;
end;

titan.entityMeta["SetNetworkedVar"] = function(entity, key, value)
	if ( titan:IsKeyIgnored(key) ) then
		return titan.originalSetNWVar(entity, key, value);
	else
		local class = titan:GetVarClass( type(value) );
			
		if (class) then
			entity["SetNetworked"..class.varType](entity, key, value);
		end;
	end;
end;

titan.entityMeta["GetNetworkedVar"] = function(entity, key)
	local entIndex = entity:EntIndex();
	
	if ( titan.netVars[entIndex] ) then
		return titan.netVars[entIndex][key];
	end;
end;

_G["SetGlobalVar"] = function(key, value)
	if ( titan:IsKeyIgnored(key) ) then
		return titan.originalSetGlobalVar(key, value);
	else
		local class = titan:GetVarClass( type(value) );
			
		if (class) then
			entity["SetGlobal"..class.varType](key, value);
		end;
	end;
end;

_G["GetGlobalVar"] = function(key)
	local entIndex = GetWorldEntity():EntIndex();
	
	if ( titan.netVars[entIndex] ) then
		return titan.netVars[entIndex][key];
	end;
end;

-- A function to get a variable class table.
function titan:GetVarClass(value, forceType)
	local realType = forceType or type(value);
	
	if ( realType == "number" and string.find(tostring(value), "%.") ) then
		return self:GetVarClass(value, "float");
	else
		local varClasses = self:GetVarClasses();
		
		if ( varClasses[realType] ) then
			return varClasses[realType];
		end;
	end;
end;

-- A function to get the variable classes.
function titan:GetVarClasses()
	return self.varClasses;
end;

-- A function to add an ignored key.
function titan:AddIgnoredKey(key)
	self.ignoredKeys[key] = true;
end;

titan:AddIgnoredKey("SprintSpeed");
titan:AddIgnoredKey("ServerName");
titan:AddIgnoredKey("WalkSpeed");
titan:AddIgnoredKey("JumpPower");
	
-- A function to get whether an entity is valid.
function titan:IsValidEntity(entity)
	return IsValid(entity) or entity == GetWorldEntity();
end;

-- A function to get whether a key is ignored.
function titan:IsKeyIgnored(key)
	return self.ignoredKeys[key];
end;

-- A function to register a class.
function titan:RegisterClass(varType, realType, masterDefault)
	local originalSet = self.entityMeta["SetNW"..varType];
	local originalGet = self.entityMeta["GetNW"..varType];
	local entIndex;
	
	if (type(realType) != "table") then
		realType = {realType};
	end;
	
	for k, v in ipairs(realType) do
		self.varClasses[v] = {
			default = masterDefault,
			varType = varType
		};
	end;
	
	self.entityMeta["SetNW"..varType] = function(entity, key, value)
		local entIndex = entity:EntIndex();
		
		if ( self:IsKeyIgnored(key) ) then
			return originalSet(entity, key, value);
		end;
		
		if ( !entity.fn_IsReady or !self.netVars[entIndex] ) then
			self.netVars[entIndex] = {};
			
			entity.fn_IsReady = true;
		end;
		
		if (value == nil) then
			value = masterDefault;
		end;
		
		if (self.netVars[entIndex][key] != value) then
			self.netVars[entIndex][key] = value;
			
			if (SERVER) then
				self:UpdateVar(entity, key, value);
			end;
		end;
	end;
	
	self.entityMeta["GetNW"..varType] = function(entity, key, default)
		local entIndex = entity:EntIndex();
		
		if ( self:IsKeyIgnored(key) ) then
			return originalGet(entity, key, default);
		end
		
		if (self.netVars[entIndex] and self.netVars[entIndex][key] != nil) then
			return self.netVars[entIndex][key];
		else
			return masterDefault;
		end;
	end;
	
	self.entityMeta["SetNetworked"..varType] = self.entityMeta["SetNW"..varType];
	self.entityMeta["GetNetworked"..varType] = self.entityMeta["GetNW"..varType];
	
	_G["SetGlobal"..varType] = function(key, value)
		local worldEntity = GetWorldEntity();
		
		if (worldEntity) then
			worldEntity["SetNetworked"..varType](worldEntity, key, value);
		end;
	end
	
	_G["GetGlobal"..varType] = function(key, default)
		local worldEntity = GetWorldEntity();
		
		if (worldEntity) then
			return worldEntity["GetNetworked"..varType](worldEntity, key, default);
		end;
	end;
end;

hook.Add("EntityRemoved", "titan.EntityRemoved", function(entity)
	local entIndex = entity:EntIndex();
	
	if (CLIENT) then
		if (entity == g_LocalPlayer) then
			titan.nextFullUpdate = nil;
			titan.timedOut = true;
		end;
	else
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v.fn_Initialized) then
				v.fn_Vars[entIndex] = nil;
			end;
		end;
		
		titan.netVars[entIndex] = nil;
	end;
end);

titan:RegisterClass("Entity", {"NPC", "Entity", "Player", "Vehicle", "Weapon"}, NULL);
titan:RegisterClass( "Vector", "Vector", Vector(0, 0, 0) );
titan:RegisterClass("Number", "number", 0);
titan:RegisterClass("String", "string", "")
titan:RegisterClass( "Angle", "Angle", Angle(0, 0, 0) );
titan:RegisterClass("Float", "float", 0.0);
titan:RegisterClass("Bool", "boolean", false);
titan:RegisterClass("Int", "number", 0);