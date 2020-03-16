--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

--[[
	It is not recommended that you change the
	size of the world. This should be constant
	to avoid any issues.
--]]
WORLD_SIZE = 2048;

--[[
	Collision enumerations represent the capabilities
	an entity has in terms of moving and colliding.
--]]
COLLISION_PHYSICS = 1;
COLLISION_STATIC = 2;
COLLISION_NONE = 3;

--[[
	Damage enumerations represent the type of damage
	inflicted by a DamageInfo object.
--]]
DAMAGE_WORLD = 1;
DAMAGE_MELEE = 3;
DAMAGE_BULLET = 2;

--[[
	Flags are special capabilities or data that an
	entity can store about itself.
--]]
FLAG_SPAWNED = 1;

--[[
	Teams represent a group of entities within
	a specific classification.
--]]
TEAM_GENERIC = 1;
TEAM_HUMANS = 2;
TEAM_MONSTERS = 3;

--[[
	Layer enumerations represent the draw order
	of an entity or group of entities.
--]]
LAYER_NONE = 0;
LAYER_BRUSH = 1;
LAYER_ITEMS = 2;
LAYER_PROPS = 3;
LAYER_LIVING = 4;
LAYER_WEAPONS = 5;

--[[
	Material enumerations represent the type
	of material a texture, image or entity has.
--]]
MAT_GENERIC = 0;
MAT_CONCRETE = 1;
MAT_LIQUID = 2;
MAT_BRICK = 3;
MAT_FLESH = 4;
MAT_EARTH = 5;
MAT_METAL = 6;
MAT_GLASS = 7;
MAT_TILE = 8;
MAT_WOOD = 9;