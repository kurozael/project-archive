--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

--[[
	Here we simply convert all singleton instances
	to easy-to-use libraries to match the rest of the
	scripting style.
--]]

local function InstanceToLibrary(instanceName, libName)
	local instanceObject = _G[instanceName];
	local classInfo = class_info(instanceObject)

	-- Create a new table for the library.
	_G[libName] = {};
	
	-- Transfer all methods to the library.
	for k, v in pairs(classInfo.methods) do
		if (type(instanceObject[k]) == "function") then
			local funcName = k;
			
			_G[libName][funcName] = function(...)
				return instanceObject[funcName](instanceObject, ...);
			end;
		end;
	end;
end;

InstanceToLibrary("NetworkInstance", "network");
InstanceToLibrary("PhysicsInstance", "physics");
InstanceToLibrary("DisplayInstance", "display");
InstanceToLibrary("InputsInstance", "inputs");
InstanceToLibrary("FontsInstance", "fonts");
InstanceToLibrary("SoundsInstance", "sounds");
InstanceToLibrary("RenderInstance", "render");
InstanceToLibrary("CameraInstance", "camera");
InstanceToLibrary("GameInstance", "game");
InstanceToLibrary("FilesInstance", "files");
InstanceToLibrary("TimeInstance", "time");
InstanceToLibrary("LuaInstance", "lua");

-- Load all of the default scripts.
lua.Include("funcs");
lua.Include("enums");

-- Load all of the extensions.
lua.Include("libraries/extensions/string");
lua.Include("libraries/extensions/table");
lua.Include("libraries/extensions/math");

-- Load all of the libraries.
lua.Include("libraries/draw");
lua.Include("libraries/util");
lua.Include("libraries/hooks");
lua.Include("libraries/json");
lua.Include("libraries/tools");
lua.Include("libraries/cursor");
lua.Include("libraries/levels");
lua.Include("libraries/decals");
lua.Include("libraries/timers");
lua.Include("libraries/damage");
lua.Include("libraries/effects");
lua.Include("libraries/states");
lua.Include("libraries/sprites");
lua.Include("libraries/controls");
lua.Include("libraries/emitters");
lua.Include("libraries/entities");
lua.Include("libraries/materials");
lua.Include("libraries/javascript");

-- Import all of the classes.
import("tools", tools.Import);
import("states", states.Import);
import("effects", effects.Import);
import("entities", entities.Import);
import("controls", controls.Import);

entities.SetupInheritance();
states.SetActive("MenuState");

local fileList = util.GrabFilesInDir("lua/lighting/");
local shaderList = util.GrabFilesInDir("lua/lighting/shaders/");
local lightsList = util.GrabFilesInDir("lua/lighting/lights/");

for k, v in ipairs(fileList) do
	if (not util.IsDirectory(v)) then
		lua.Include("lua/lighting/"..v);
	end;
end;

for k, v in ipairs(shaderList) do
	if (not util.IsDirectory(v)) then
		lua.Include("lua/lighting/shaders/"..v);
	end;
end;

for k, v in ipairs(lightsList) do
	if (not util.IsDirectory(v)) then
		lua.Include("lua/lighting/lights/"..v);
	end;
end;

lua.Include("libraries/lighting");

-- Called by the engine to get whether a ray should hit a body.
function OnShouldRayHitBody(body)
	local rayData = util.GetTraceData();
	local entIndex = tonumber(body:GetData());
	local entity = entities.GetByIndex(entIndex);
	
	if (not rayData or not entity or not entity:IsValid()) then
		return false;
	end;
	
	if (entity:GetCollisionType() == COLLISION_NONE) then
		return false;
	end;
	
	if (table.HasValue(rayData.filter, entity)) then
		return false;
	end;
	
	if (rayData.Condition) then
		if (not rayData.Condition(entity)) then
			return false;
		end;
	end;
	
	if (not entity:OnShouldTraceHit()) then
		return false;
	end;
	
	return true;
end;

-- Called by the engine when a ray has hit a body.
function OnRayHitBody(body, position, normal, fraction)
	local rayData = util.GetTraceData();
	local entIndex = tonumber(body:GetData());
	local entity = entities.GetByIndex(entIndex);
	
	if (rayData and entity and entity:IsValid()) then
		local results = rayData.results;
		local distance = results.startPos:Distance(position);
		
		results.hitMaterial = entity:GetMaterialType();
		results.hitEntity = entity;
		results.distance = distance;
		results.fraction = fraction;
		results.hitPos = position;
		results.didHit = true;
		results.normal = normal;
	end;
end;

-- Called by the engine when two bodies begin contact.
function OnBodiesBeginContact(firstBody, secondBody, position, normal)
	if (not levels.GetActive()) then return; end;
	
	local firstEntity = entities.GetByIndex(tonumber(firstBody:GetData()));
	local secondEntity = entities.GetByIndex(tonumber(secondBody:GetData()));
	
	entities.Safe(function()
		if (firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid()
		and firstEntity ~= secondEntity) then
			local collisionInfo = {
				position = position,
				normal = normal
			};
			
			firstEntity:OnBeginContact(secondEntity, collisionInfo);
			secondEntity:OnBeginContact(firstEntity, collisionInfo);
			
			hooks.Call("EntitiesBeginContact", firstEntity, secondEntity, collisionInfo);
		end;
	end);
end;

-- Called by the engine when two bodies end contact.
function OnBodiesEndContact(firstBody, secondBody, position, normal)
	if (not levels.GetActive()) then return; end;
	
	local firstEntity = entities.GetByIndex(tonumber(firstBody:GetData()));
	local secondEntity = entities.GetByIndex(tonumber(secondBody:GetData()));
	
	entities.Safe(function()
		if (firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid()
		and firstEntity ~= secondEntity) then
			local collisionInfo = {
				position = position,
				normal = normal
			};
			
			firstEntity:OnEndContact(secondEntity, collisionInfo);
			secondEntity:OnEndContact(firstEntity, collisionInfo);
			
			hooks.Call("EntitiesEndContact", firstEntity, secondEntity, collisionInfo);
		end;
	end);
end;

-- Called by the engine before a collision is solved.
function OnPreSolveCollision(firstBody, secondBody, position, normal)
	local firstEntity = entities.GetByIndex(tonumber(firstBody:GetData()));
	local secondEntity = entities.GetByIndex(tonumber(secondBody:GetData()));
	
	entities.Safe(function()
		if (firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid()) then
			local collisionInfo = {
				position = position,
				normal = normal
			};
			
			firstEntity:OnPreSolveCollision(secondEntity, collisionInfo);
			secondEntity:OnPreSolveCollision(firstEntity, collisionInfo);
			
			hooks.Call("PreSolveCollision", firstEntity, secondEntity, collisionInfo);
		end;
	end);
end;

-- Called by the engine after a collision is solved.
function OnPostSolveCollision(firstBody, secondBody, position, normal)
	local firstEntity = entities.GetByIndex(tonumber(firstBody:GetData()));
	local secondEntity = entities.GetByIndex(tonumber(secondBody:GetData()));
	
	entities.Safe(function()
		if (firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid()) then
			local collisionInfo = {
				position = position,
				normal = normal
			};
			
			firstEntity:OnPostSolveCollision(secondEntity, collisionInfo);
			secondEntity:OnPostSolveCollision(firstEntity, collisionInfo);
			
			hooks.Call("PostSolveCollision", firstEntity, secondEntity, collisionInfo);
		end;
	end);
end;

-- Called by the engine to get whether two bodies should collide.
function OnBodiesShouldCollide(firstBody, secondBody)
	local firstEntity = entities.GetByIndex(tonumber(firstBody:GetData()));
	local secondEntity = entities.GetByIndex(tonumber(secondBody:GetData()));
	
	if (firstEntity and firstEntity:IsValid()
	and secondEntity and secondEntity:IsValid()) then
		if (not firstEntity:OnShouldCollide(secondEntity)
		or not secondEntity:OnShouldCollide(firstEntity)) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called when the server has received a network event.
function OnServerEventReceived(connection, name, data)
	hooks.Call("ServerEventReceived", connection, name, data);
end;
	
-- Called when the client has received a network event.
function OnClientEventReceived(name, data)
	hooks.Call("ClientEventReceived", name, data);
end;

-- Called when a client has joined the server.
function OnClientJoin(connection)
	hooks.Call("ClientJoin", connection);
end;
	
-- Called when a client has left the server.
function OnClientLeave(connection)
	hooks.Call("ClientLeave", connection);
end;

-- Called when the client has connected to the server.
function OnConnected() hooks.Call("Connected"); end;
	
-- Called when the client has disconnected from the server.
function OnDisconnected() hooks.Call("Disconnected"); end;

-- Called by the engine when there is a key event.
function OnKeyEvent(inputEvent)
	if (controls.HandleInput("KeyEvent", inputEvent)) then
		return;
	end;
	
	if (not controls.GetFocused()) then
		hooks.Call("KeyEvent", inputEvent);
	end;
end;

-- Called by the engine when there is a mouse event.
function OnMouseEvent(inputEvent)
	if (not controls.GetFocused()) then
		hooks.Call("MouseEvent", inputEvent);
	end;
end;

-- Called when a mouse button is released.
function OnMouseButtonRelease(button)
	if (controls.HandleInput("MouseButtonRelease", button)) then
		return;
	end;
	
	hooks.Call("MouseButtonRelease", button);
end;

-- Called when a mouse button is pressed.
function OnMouseButtonPress(button)
	if (controls.HandleInput("MouseButtonPress", button)) then
		return;
	end;
	
	hooks.Call("MouseButtonPress", button);
end;

-- Called when a mouse button is double clicked.
function OnMouseDoubleClick(button)
	if (controls.HandleInput("MouseDoubleClick", button)) then
		return;
	end;
	
	hooks.Call("MouseButtonDoubleClick", button);
end;

-- Called when a key is released.
function OnKeyRelease(key, str)
	if (controls.HandleInput("KeyRelease", key, str)) then
		return;
	end;
	
	hooks.Call("KeyRelease", key);
end;

-- Called when a key is pressed.
function OnKeyPress(key, str)
	if (controls.HandleInput("KeyPress", key, str)) then
		return;
	end;
	
	hooks.Call("KeyPress", key, str);
end;

-- Called by the engine when the game should be updated.
function OnUpdateGame(deltaTime)
	levels.Update(deltaTime);
		hooks.Call("UpdateGame", deltaTime);
	controls.Update(deltaTime);
end;

-- Called by the engine when the game should be drawn.
function OnDrawGame()
	render.DrawFill(0, 0, display.GetW(), display.GetH(), Color(0.5, 0.5, 0.5, 1));
	
	levels.Draw();
		hooks.Call("DrawDisplay");
	controls.Draw();
end;

-- Called by the engine when the game has initialized.
function OnInitGame()
	hooks.Call("InitGame");
	
	print("///////   Cloud Engine 2D   ///////");
	print("///////   by Conna Wiles    //////");
	print("///////   http://conna.org  ///////");
	print("///////   version 0.1a      ///////");
	print("________________________________________________");
	
	print("This is just a demo of the engine, and in no-way");
	print("reflects an actual game.");
end;

-- Called by the engine when the game is quit.
function OnQuitGame()
	hooks.Call("QuitGame");
end;

-- Called by the engine when there is a quit event.
function OnQuitEvent()
	if (hooks.Call("QuitEvent") ~= false) then
		game.SetRunning(false);
	end;
end;