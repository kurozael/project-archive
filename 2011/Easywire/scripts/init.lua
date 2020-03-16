--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

math.randomseed( os.clock() );

-- Load all of the default scripts.
g_Lua:LoadScript("funcs");
g_Lua:LoadScript("enums");

-- Load all of the extensions.
g_Lua:LoadScript("libraries/extensions/string");
g_Lua:LoadScript("libraries/extensions/table");
g_Lua:LoadScript("libraries/extensions/math");

-- Load all of the libraries.
g_Lua:LoadScript("libraries/draw");
g_Lua:LoadScript("libraries/util");
g_Lua:LoadScript("libraries/hooks");
g_Lua:LoadScript("libraries/json");
g_Lua:LoadScript("libraries/wire");
g_Lua:LoadScript("libraries/tools");
g_Lua:LoadScript("libraries/chips");
g_Lua:LoadScript("libraries/levels");
g_Lua:LoadScript("libraries/decals");
g_Lua:LoadScript("libraries/timers");
g_Lua:LoadScript("libraries/damage");
g_Lua:LoadScript("libraries/effects");
g_Lua:LoadScript("libraries/states");
g_Lua:LoadScript("libraries/sprites");
g_Lua:LoadScript("libraries/controls");
g_Lua:LoadScript("libraries/emitters");
g_Lua:LoadScript("libraries/entities");
g_Lua:LoadScript("libraries/materials");

-- Import all of the classes.
import("tools", tools.Import);
import("chips", chips.Import);
import("states", states.Import);
import("effects", effects.Import);
import("entities", entities.Import);
import("controls", controls.Import);

-- Set up the inheritance.
entities.SetupInheritance();
chips.SetupInheritance();

-- Set the default active state.
states.SetActive("MenuState");

-- Called by the engine to get whether a ray should hit a body.
function OnShouldRayHitBody(body)
	local rayData = util.GetTraceData();
	local entIndex = tonumber( body:GetData() );
	local entity = entities.GetByIndex(entIndex);
	
	if ( not rayData or not entity or not entity:IsValid() ) then
		return false;
	end;
	
	if (entity:GetCollisionType() == COLLISION_NONE) then
		return false;
	end;
	
	if ( table.HasValue(rayData.filter, entity) ) then
		return false;
	end;
	
	if (rayData.Condition) then
		if ( not rayData.Condition(entity) ) then
			return false;
		end;
	end;
	
	if ( not entity:OnShouldTraceHit() ) then
		return false;
	end;
	
	return true;
end;

-- Called by the engine when a ray has hit a body.
function OnRayHitBody(body, position, normal, fraction)
	local rayData = util.GetTraceData();
	local entIndex = tonumber( body:GetData() );
	local entity = entities.GetByIndex(entIndex);
	
	if ( rayData and entity and entity:IsValid() ) then
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
	local firstEntity = entities.GetByIndex( tonumber( firstBody:GetData() ) );
	local secondEntity = entities.GetByIndex( tonumber( secondBody:GetData() ) );
	
	entities.Safe(function()
		if ( firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid() ) then
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
	local firstEntity = entities.GetByIndex( tonumber( firstBody:GetData() ) );
	local secondEntity = entities.GetByIndex( tonumber( secondBody:GetData() ) );
	
	entities.Safe(function()
		if ( firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid() ) then
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
	local firstEntity = entities.GetByIndex( tonumber( firstBody:GetData() ) );
	local secondEntity = entities.GetByIndex( tonumber( secondBody:GetData() ) );
	
	entities.Safe(function()
		if ( firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid() ) then
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
	local firstEntity = entities.GetByIndex( tonumber( firstBody:GetData() ) );
	local secondEntity = entities.GetByIndex( tonumber( secondBody:GetData() ) );
	
	entities.Safe(function()
		if ( firstEntity and firstEntity:IsValid()
		and secondEntity and secondEntity:IsValid() ) then
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
	local firstEntity = entities.GetByIndex( tonumber( firstBody:GetData() ) );
	local secondEntity = entities.GetByIndex( tonumber( secondBody:GetData() ) );
	
	if ( firstEntity and firstEntity:IsValid()
	and secondEntity and secondEntity:IsValid() ) then
		if ( not firstEntity:OnShouldCollide(secondEntity)
		or not secondEntity:OnShouldCollide(firstEntity) ) then
			return false;
		end;
	end;
	
	return true;
end;

-- Called by the engine when there is a key event.
function OnKeyEvent(inputEvent)
	if ( not controls.GetFocused() ) then
		hooks.Call("KeyEvent", inputEvent);
	end;
end;

-- Called by the engine when there is a mouse event.
function OnMouseEvent(inputEvent)
	if ( not controls.GetFocused() ) then
		hooks.Call("MouseEvent", inputEvent);
	end;
end;

-- Called when a mouse button is released.
function OnMouseButtonRelease(button)
	if ( controls.HandleInput("MouseButtonRelease", button) ) then
		return;
	end;
	
	hooks.Call("MouseButtonRelease", button);
end;

-- Called when a mouse button is pressed.
function OnMouseButtonPress(button)
	if ( controls.HandleInput("MouseButtonPress", button) ) then
		return;
	end;
	
	hooks.Call("MouseButtonPress", button);
end;

-- Called when a mouse button is double clicked.
function OnMouseDoubleClick(button)
	if ( controls.HandleInput("MouseDoubleClick", button) ) then
		return;
	end;
	
	hooks.Call("MouseButtonDoubleClick", button);
end;

-- Called when a key is released.
function OnKeyRelease(key)
	if ( controls.HandleInput("KeyRelease", key) ) then
		return;
	end;
	
	hooks.Call("KeyRelease", key);
end;

-- Called when a key is pressed.
function OnKeyPress(key)
	if ( controls.HandleInput("KeyPress", key) ) then
		return;
	end;
	
	hooks.Call("KeyPress", key);
end;

-- Called by the engine when the game should be updated.
function OnUpdateGame(deltaTime)
	levels.Update(deltaTime);
		hooks.Call("UpdateGame", deltaTime);
	controls.Update(deltaTime);
end;

-- Called by the engine when the game should be drawn.
function OnDrawGame()
	levels.Draw();
		hooks.Call("DrawDisplay");
	controls.Draw();
end;

-- Called by the engine when the game has initialized.
function OnInitGame()
	hooks.Call("InitGame");
end;

-- Called by the engine when the game is quit.
function OnQuitGame()
	hooks.Call("QuitGame");
end;

-- Called by the engine when there is a quit event.
function OnQuitEvent()
	if (hooks.Call("QuitEvent") ~= false) then
		g_Game:SetRunning(false);
	end;
end;