--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.entity = {};

-- A function to register an entity's shared vars.
function openAura.entity:RegisterSharedVars(entity, sharedVars)
	if (!entity.sharedVars) then
		entity.sharedVars = {};
	end;
	
	for k, v in pairs(sharedVars) do
		entity.sharedVars[ v[1] ] = v[2];
	end;
end;

-- A function to check if an entity is a door.
function openAura.entity:IsDoor(entity)
	if ( IsValid(entity) ) then
		local class = entity:GetClass();
		local model = entity:GetModel();
		
		if (class and model) then
			class = string.lower(class);
			model = string.lower(model);
			
			if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
			or ( class == "prop_dynamic" and string.find(model, "door") ) or class == "func_movelinear") then
				return true;
			end;
		end;
	end;
end;

-- A function to get whether an entity is decaying.
function openAura.entity:IsDecaying(entity)
	return entity.decaying;
end;

-- A function to check if an entity is in a box.
function openAura.entity:IsInBox(entity, minimum, maximum)
	local position = entity:GetPos();
	
	if ( entity:IsPlayer() or entity:IsNPC() ) then
		position = entity:GetShootPos();
	end;
	
	if ( ( position.x >= math.min(minimum.x, maximum.x) and position.x <= math.max(minimum.x, maximum.x) )
	and ( position.y >= math.min(minimum.y, maximum.y) and position.y <= math.max(minimum.y, maximum.y) )
	and ( position.z >= math.min(minimum.z, maximum.z) and position.z <= math.max(minimum.z, maximum.z) ) ) then
		return true;
	else
		return false;
	end;
end;

-- A function to get a ragdoll entity's pelvis position.
function openAura.entity:GetPelvisPosition(entity)
	local position = entity:GetPos();
	local bone = entity:LookupBone("ValveBiped.Bip01_Pelvis");

	if (bone) then
		local bonePosition = entity:GetBonePosition(bone);
		
		if (bonePosition) then
			position = bonePosition;
		end;
	end;
	
	return position;
end;

-- A function to get whether an entity can see a position.
function openAura.entity:CanSeePosition(entity, position, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = position;
	trace.filter = {entity};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether an entity can see an NPC.
function openAura.entity:CanSeeNPC(entity, target, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = target:GetShootPos();
	trace.filter = {entity, target};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether an entity can see a player.
function openAura.entity:CanSeePlayer(entity, target, allowance, ignoreEnts)
	if (target:GetEyeTraceNoCursor().Entity == entity) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = entity:LocalToWorld( entity:OBBCenter() );
		trace.endpos = target:GetShootPos();
		trace.filter = {entity, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether an entity can see an entity.
function openAura.entity:CanSeeEntity(entity, target, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = entity:LocalToWorld( entity:OBBCenter() );
	trace.endpos = target:LocalToWorld( target:OBBCenter() );
	trace.filter = {entity, target};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether a door is unownable.
function openAura.entity:IsDoorUnownable(entity)
	return entity:GetNetworkedBool("unownable");
end;

-- A function to get whether a door is false.
function openAura.entity:IsDoorFalse(entity)
	return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == "false";
end;

-- A function to get whether a door is hidden.
function openAura.entity:IsDoorHidden(entity)
	return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == "hidden";
end;

-- A function to get a door's name.
function openAura.entity:GetDoorName(entity)
	return entity:GetNetworkedString("name");
end;

-- A function to get a door's text.
function openAura.entity:GetDoorText(entity)
	return entity:GetNetworkedString("text");
end;

-- A function to get whether an entity is a player ragdoll.
function openAura.entity:IsPlayerRagdoll(entity)
	local player = entity:GetNetworkedEntity("player");
	
	if ( IsValid(player) ) then
		if (player:GetRagdollEntity() == entity) then
			return true;
		end;
	end;
end;

-- A function to set a shared variable for an entity.
function openAura.entity:SetSharedVar(entity, key, value)
	if ( IsValid(entity) ) then
		if ( entity.sharedVars and entity.sharedVars[key] ) then
			local class = openAura:ConvertNetworkedClass( entity.sharedVars[key] );
			
			if (class) then
				if (value == nil) then
					value = openAura:GetDefaultClassValue(class);
				end;
				
				entity["SetNetworked"..class](entity, key, value);
			else
				entity:SetNetworkedVar(key, value);
			end;
		else
			entity:SetNetworkedVar(key, value);
		end;
	end;
end;

-- A function to get an entity's shared variable.
function openAura.entity:GetSharedVar(entity, key)
	if ( IsValid(entity) ) then
		if ( entity.sharedVars and entity.sharedVars[key] ) then
			local class = openAura:ConvertNetworkedClass( entity.sharedVars[key] );
			
			if (class) then
				return entity["GetNetworked"..class](entity, key);
			else
				return entity:GetNetworkedVar(key);
			end;
		else
			return entity:GetNetworkedVar(key);
		end;
	end;
end;

-- A function to get an entity's player.
function openAura.entity:GetPlayer(entity)
	local player = entity:GetNetworkedEntity("player");
	
	if ( IsValid(player) ) then
		return player;
	elseif ( entity:IsPlayer() ) then
		return entity;
	end;
end;

-- A function to get whether an entity is interactable.
function openAura.entity:IsInteractable(entity)
	local class = entity:GetClass();
	
	if ( string.find(class, "prop_") ) then
		if ( entity:HasSpawnFlags(SF_PHYSPROP_MOTIONDISABLED) or entity:HasSpawnFlags(SF_PHYSPROP_PREVENT_PICKUP) ) then
			return false;
		end;
	end;
	
	if ( entity:IsNPC() or entity:IsPlayer() or string.find(class, "prop_dynamic") ) then
		return false;
	end;
	
	if ( class == "func_physbox" and entity:HasSpawnFlags(SF_PHYSBOX_MOTIONDISABLED) ) then
		return false;
	end
	
	if ( class != "func_physbox" and string.find(class, "func_") ) then
		return false;
	end;
	
	if ( self:IsDoor(entity) ) then
		return false;
	end;
	
	return true;
end;

-- A function to get whether an entity is a physics entity.
function openAura.entity:IsPhysicsEntity(entity)
	local class = string.lower( entity:GetClass() );
	
	if (class == "prop_physics_multiplayer" or class == "prop_physics") then
		return true;
	end;
end;

-- A function to get whether an entity is a pod.
function openAura.entity:IsPodEntity(entity)
	local entityModel = string.lower( entity:GetModel() );
	
	if ( string.find(entityModel, "prisoner") ) then
		return true;
	end;
end;

-- A function to get whether an entity is a chair.
function openAura.entity:IsChairEntity(entity)
	if ( entity:GetModel() ) then
		local entityModel = string.lower( entity:GetModel() );
		
		if ( string.find(entityModel, "chair") or string.find(entityModel, "seat") ) then
			return true;
		end;
	end;
end;

if (SERVER) then
	function openAura.entity:OpenDoor(entity, delay, unlock, sound, origin)
		if ( self:IsDoor(entity) ) then
			if (unlock) then
				entity:Fire("Unlock", "", delay);
				
				delay = delay + 0.025;
				
				if (sound) then
					entity:EmitSound("physics/wood/wood_box_impact_hard3.wav");
				end;
			end;
			
			if (entity:GetClass() == "prop_dynamic") then
				entity:Fire("SetAnimation", "open", delay);
				entity:Fire("SetAnimation", "close", delay + 5);
			elseif (origin and string.lower( entity:GetClass() ) == "prop_door_rotating") then
				local target = ents.Create("info_target");
				
				target:SetName( tostring(target) );
				target:SetPos(origin);
				target:Spawn();
				
				entity:Fire("OpenAwayFrom", tostring(target), delay);
				
				timer.Simple(delay + 1, function()
					if ( IsValid(target) ) then
						target:Remove();
					end;
				end);
			else
				entity:Fire("Open", "", delay);
			end;
		end;
	end;
	
	-- A function to make an entity safe.
	function openAura.entity:MakeSafe(entity, physgunProtect, toolProtect, freezeEntity)
		if (physgunProtect) then
			entity.PhysgunDisabled = true;
		end;
		
		if (toolProtect) then
			entity.CanTool = function(entity, player, trace, tool)
				if (type(toolProtect) == "table") then
					return !table.HasValue(toolProtect, tool);
				else
					return false;
				end;
			end;
		end;
		
		if (freezeEntity) then
			if ( IsValid( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():EnableMotion(false);
			end;
		end;
	end;
	
	-- A function to statue a ragdoll.
	function openAura.entity:StatueRagdoll(entity, forceLimit)
		local bones = entity:GetPhysicsObjectCount()
		
		if (!entity.StatueInfo) then
			entity.StatueInfo = {
				Welds = {}
			};
		end;
		
		if (!forceLimit) then
			forceLimit = 0;
		end;
	
		for bone = 1, bones do
			local boneOne = bone - 1;
			local boneTwo = bones - bone;
			
			if ( !entity.StatueInfo.Welds[boneTwo] ) then
				local constraintOne = constraint.Weld(entity, entity, boneOne, boneTwo, forceLimit);
				
				if (constraintOne) then
					entity.StatueInfo.Welds[boneOne] = constraintOne
				end;
			end;
			
			local constraintTwo = constraint.Weld(entity, entity, boneOne, 0, forceLimit);
			
			if (constraintTwo) then
				entity.StatueInfo.Welds[boneOne + bones] = constraintTwo;
			end;
			
			local effectData = EffectData();
				effectData:SetScale(1);
				effectData:SetOrigin( entity:GetPhysicsObjectNum(boneOne):GetPos() );
				effectData:SetMagnitude(1);
			util.Effect("GlassImpact", effectData, true, true);
		end;
	end;
	
	-- A function to drop items and cash.
	function openAura.entity:DropItemsAndCash(inventory, cash, position, entity)
		if (inventory and table.Count(inventory) > 0) then
			for k, v in pairs(inventory) do
				if (v > 0) then
					for i = 1, v do
						local item = self:CreateItem(nil, k, position);
						
						if ( IsValid(item) and IsValid(entity) ) then
							self:CopyOwner(entity, item);
						end;
					end;
				end;
			end;
		end;
			
		if (cash and cash > 0) then
			self:CreateCash(nil, cash, position);
		end;
	end;
	
	-- A function to make an entity into a ragdoll.
	function openAura.entity:MakeIntoRagdoll(entity, force, overrideVelocity, overrideAngles)
		local velocity = entity:GetVelocity() * 1.5;
		local ragdoll = ents.Create("prop_ragdoll");
		
		if (overrideVelocity) then
			velocity = overrideVelocity;
		end;
		
		if (overrideAngles) then
			ragdoll:SetAngles(overrideAngles);
		else
			ragdoll:SetAngles( entity:GetAngles() );
		end;
		
		ragdoll:SetMaterial( entity:GetMaterial() );
		ragdoll:SetAngles( entity:GetAngles() - Angle(0, -45, 0) );
		ragdoll:SetColor( entity:GetColor() );
		ragdoll:SetModel( entity:GetModel() );
		ragdoll:SetSkin( entity:GetSkin() );
		ragdoll:SetPos( entity:GetPos() );
		ragdoll:Spawn();
		
		if ( IsValid(ragdoll) ) then
			local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
			
			for i = 1, ragdoll:GetPhysicsObjectCount() do
				local physicsObject = ragdoll:GetPhysicsObjectNum(i);
				local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
				local position, angle = entity:GetBonePosition(boneIndex);
				
				if ( IsValid(physicsObject) ) then
					physicsObject:SetPos(position);
					physicsObject:SetAngle(angle);
					
					if (boneIndex == headIndex) then
						physicsObject:SetVelocity(velocity * 2);
					else
						physicsObject:SetVelocity(velocity);
					end;
					
					if (force) then
						if (boneIndex == headIndex) then
							physicsObject:ApplyForceCenter(force * 2);
						else
							physicsObject:ApplyForceCenter(force);
						end;
					end;
				end;
			end;
		end;
		
		if ( entity:IsOnFire() ) then
			ragdoll:Ignite(8, 0);
		end;
		
		return ragdoll;
	end;
	
	-- A function to get whether a door is unsellable.
	function openAura.entity:IsDoorUnsellable(door)
		return door.unsellable;
	end;
	
	-- A function to set a door's parent.
	function openAura.entity:SetDoorParent(door, parent)
		if ( self:IsDoor(door) ) then
			for k, v in pairs( self:GetDoorChildren(door) ) do
				if ( IsValid(v) ) then
					self:SetDoorParent(v, false);
				end;
			end;
			
			if ( IsValid(door.doorParent) ) then
				if (door.doorParent.doorChildren) then
					door.doorParent.doorChildren[door] = nil;
				end;
			end;
			
			if ( IsValid(parent) and self:IsDoor(parent) ) then
				if (parent.doorChildren) then
					parent.doorChildren[door] = door;
				else
					parent.doorChildren = { [door] = door };
				end;
				
				door.doorParent = parent;
			else
				door.doorParent = nil;
			end;
			
			door.sharedAccess = nil;
			door.sharedText = nil;
		end;
	end;
	
	-- A function to get whether is a door is a parent.
	function openAura.entity:IsDoorParent(door)
		return table.Count( self:GetDoorChildren(door) ) > 0;
	end;

	-- A function to get a door's parent.
	function openAura.entity:GetDoorParent(door)
		if ( IsValid(door.doorParent) ) then
			return door.doorParent;
		end;
	end;

	-- A function to get a door's children.
	function openAura.entity:GetDoorChildren(door)
		return door.doorChildren or {};
	end;
	
	-- A function to set a door as unownable.
	function openAura.entity:SetDoorUnownable(entity, unownable)
		if ( self:IsDoor(entity) ) then
			if (unownable) then
				entity:SetNetworkedBool("unownable", true);
				
				if ( self:GetOwner(entity) ) then
					openAura.player:TakeDoor(self:GetOwner(entity), entity, true);
				elseif ( self:HasOwner(entity) ) then
					self:ClearProperty(entity);
				end;
			else
				entity:SetNetworkedBool("unownable", false);
			end;
		end;
	end;
	
	-- A function to set whether a door is false.
	function openAura.entity:SetDoorFalse(entity, isFalse)
		if ( self:IsDoor(entity) ) then
			if (isFalse) then
				self:SetDoorUnownable(entity, true);
				self:SetDoorName(entity, "false");
			else
				self:SetDoorUnownable(entity, false);
				self:SetDoorName(entity, "");
			end;
		end;
	end;
	
	-- A function to set whether a door is hidden.
	function openAura.entity:SetDoorHidden(entity, hidden)
		if ( self:IsDoor(entity) ) then
			if (hidden) then
				self:SetDoorUnownable(entity, true);
				self:SetDoorName(entity, "hidden");
			else
				self:SetDoorUnownable(entity, false);
				self:SetDoorName(entity, "");
			end;
		end;
	end;
	
	-- A function to set whether a door has shared access.
	function openAura.entity:SetDoorSharedAccess(entity, sharedAccess)
		if ( self:IsDoorParent(entity) ) then
			entity.sharedAccess = sharedAccess;
		end;
	end;
	
	-- A function to set whether a door has shared access.
	function openAura.entity:SetDoorSharedText(entity, sharedText)
		if ( self:IsDoorParent(entity) ) then
			entity.sharedText = sharedText;
			
			if (sharedText) then
				for k, v in pairs( self:GetDoorChildren(entity) ) do
					if ( IsValid(v) ) then
						 self:SetDoorText( v, self:GetDoorText(entity) );
					end;
				end;
			end;
		end;
	end;
	
	-- A function to get whether a door has shared access.
	function openAura.entity:DoorHasSharedAccess(entity)
		return entity.sharedAccess;
	end;
	
	-- A function to get whether a door has shared text.
	function openAura.entity:DoorHasSharedText(entity)
		return entity.sharedText;
	end;
	
	-- A function to set a door's text.
	function openAura.entity:SetDoorText(entity, text)
		if ( self:IsDoor(entity) ) then
			if ( self:IsDoorParent(entity) ) then
				if ( self:DoorHasSharedText(entity) ) then
					for k, v in pairs( self:GetDoorChildren(entity) ) do
						if ( IsValid(v) ) then
							 self:SetDoorText(v, text);
						end;
					end;
				end;
			end;
			
			if (text) then
				if ( !string.find(string.gsub(string.lower(text), "%s", ""), "thisdoorcanbepurchased") ) then
					entity:SetNetworkedString("text", text);
				end;
			else
				entity:SetNetworkedString("text", "");
			end;
		end;
	end;
	
	-- A function to set a door's name.
	function openAura.entity:SetDoorName(entity, name)
		if ( self:IsDoor(entity) ) then
			if (name) then
				entity:SetNetworkedString("name", name);
			else
				entity:SetNetworkedString("name", "");
			end;
		end;
	end;
	
	-- A function to set an entity's chair animations.
	function openAura.entity:SetChairAnimations(entity)
		if (!entity.VehicleTable) then
			local targetFaction = "prop_vehicle_prisoner_pod";
			
			if (entity:GetClass() == targetFaction) then
				local entityModel = string.lower( entity:GetModel() );
				
				if (entityModel == "models/props_c17/furniturechair001a.mdl"
				or entityModel == "models/props_furniture/chair1.mdl") then
					entity:SetModel("models/nova/chair_wood01.mdl");
				elseif (entityModel == "models/props_c17/chair_office01a.mdl") then
					entity:SetModel("models/nova/chair_office01.mdl");
				elseif (entityModel == "models/props_combine/breenchair.mdl") then
					entity:SetModel("models/nova/chair_office02.mdl");
				elseif (entityModel == "models/props_interiors/furniture_chair03a.mdl"
				or entityModel == "models/props_wasteland/controlroom_chair001a.mdl") then
					entity:SetModel("models/nova/chair_plastic01.mdl");
				end;
				
				if ( self:IsChairEntity(entity) ) then
					local entityModel = string.lower( entity:GetModel() );
					local vehicles = list.Get("Vehicles");
					-- local k2, v2;
					
					for k, v in pairs(vehicles) do
						local keyValues = v.KeyValues;
						local members = v.Members;
						local model = v.Model;
						local class = v.Class;
						
						if (string.lower(class) == targetFaction) then
							if (string.lower(model) == entityModel) then
								for k2, v2 in pairs(keyValues) do
									entity:SetKeyValue(k2, v2);
								end;
								
								entity.VehicleTable = v;
								entity.ClassOverride = class;
								
								table.Merge(entity, members);
								
								return true;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to set an entity's start angles.
	function openAura.entity:SetStartAngles(entity, angles)
		entity.startAngles = angles;
	end;
	
	-- A function to get an entity's start angles.
	function openAura.entity:GetStartAngles(entity)
		return entity.startAngles;
	end;
	
	-- A function to set an entity's start position.
	function openAura.entity:SetStartPosition(entity, position)
		entity.startPosition = position;
	end;
	
	-- A function to get an entity's start position.
	function openAura.entity:GetStartPosition(entity)
		return entity.startPosition;
	end;
	
	-- A function to return an entity's collision group.
	function openAura.entity:ReturnCollisionGroup(entity, collisionGroup)
		if ( IsValid(entity) ) then
			local physicsObject = entity:GetPhysicsObject();
			local index = entity:EntIndex();
			
			if ( IsValid(physicsObject) ) then
				if ( !physicsObject:IsPenetrating() ) then
					entity:SetCollisionGroup(collisionGroup);
				else
					openAura:CreateTimer("collision_group_"..index, 1, 1, function()
						self:ReturnCollisionGroup(entity, collisionGroup);
					end);
				end;
			end;
		end;
	end;

	-- A function to set whether an entity is a map entity.
	function openAura.entity:SetMapEntity(entity, isMapEntity)
		if (isMapEntity) then
			openAura.Entities[entity] = entity;
		else
			openAura.Entities[entity] = nil;
		end;
	end;
	
	-- A function to get whether an entity is a map entity.
	function openAura.entity:IsMapEntity(entity)
		if ( openAura.Entities[entity] ) then
			return true;
		end;
	end;
	
	-- A function to make an entity flush with the ground.
	function openAura.entity:MakeFlushToGround(entity, position, normal)
		entity:SetPos( position + ( entity:GetPos() - entity:NearestPoint( position - (normal * 512) ) ) );
	end;
	
	-- A function to make an entity disintegrate.
	function openAura.entity:Disintegrate(entity, delay, velocity, Callback)
		if (velocity) then
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					if ( IsValid(physicsObject) ) then
						physicsObject:AddVelocity(velocity);
					end;
				end;
			elseif ( IsValid( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():AddVelocity(velocity);
			end;
		end;
		
		self:Decay(entity, delay, Callback);
		
		if (velocity) then
			timer.Simple(math.min(1, delay / 2), function()
				if ( IsValid(entity) ) then
					entity:SetNotSolid(true);
					
					if (entity:GetClass() == "prop_ragdoll") then
						for i = 1, entity:GetPhysicsObjectCount() do
							local physicsObject = entity:GetPhysicsObjectNum(i);
							
							if ( IsValid(physicsObject) ) then
								physicsObject:EnableMotion(false);
							end;
						end;
					elseif ( IsValid( entity:GetPhysicsObject() ) ) then
						entity:GetPhysicsObject():EnableMotion(false);
					end;
				end;
			end);
		else
			entity:SetNotSolid(true);
			
			if (entity:GetClass() == "prop_ragdoll") then
				for i = 1, entity:GetPhysicsObjectCount() do
					local physicsObject = entity:GetPhysicsObjectNum(i);
					
					if ( IsValid(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			elseif ( IsValid( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():EnableMotion(false);
			end;
		end;
		
		local effectData = EffectData();
			effectData:SetEntity(entity);
		util.Effect("entity_remove", effectData, true, true);
	end;
	
	-- A function to set an entity's player.
	function openAura.entity:SetPlayer(entity, player)
		entity:SetNetworkedEntity("player", player);
	end;
	
	-- A function to make an entity decay.
	function openAura.entity:Decay(entity, seconds, Callback)
		local r, g, b, a = entity:GetColor();
		local subtract = math.ceil(a / seconds);
		local index = tostring( {} );
		local alpha = a;
		
		if (entity.decaying) then
			index = entity.decaying;
		else
			entity.decaying = index;
		end;
		
		self:SetPlayer(entity, NULL);
		
		openAura:CreateTimer("decay_"..index, 1, 0, function()
			alpha = alpha - subtract;
			
			if ( IsValid(entity) ) then
				local r, g, b, a = entity:GetColor();
				local decayed = math.Clamp(math.ceil(alpha), 0, 255);
				
				if (a <= 0) then
					if (Callback) then
						Callback();
					end;
					
					entity:Remove();
					
					openAura:DestroyTimer("decay_"..index);
				else
					entity:SetColor(r, g, b, decayed);
				end;
			else
				openAura:DestroyTimer("decay_"..index);
			end;
		end);
	end;
	
	-- A function to create cash.
	function openAura.entity:CreateCash(player, cash, position, angles)
		if ( openAura.config:Get("cash_enabled"):Get() ) then
			local entity = ents.Create("aura_cash");
			
			if (type(player) == "table") then
				if (player.key and player.uniqueID) then
					openAura.player:GivePropertyOffline(player.key, player.uniqueID, entity, true);
				end;
			elseif ( IsValid(player) ) then
				openAura.player:GiveProperty(player, entity);
			end;
			
			if (!angles) then
				angles = Angle(0, 0, 0);
			end;
			
			entity:SetPos(position);
			entity:SetAngles(angles);
			entity:Spawn();
			
			if ( IsValid(entity) ) then
				entity:SetAmount( math.Round(cash) );
				
				return entity;
			end;
		end;
	end;
	
	-- A function to create generator.
	function openAura.entity:CreateGenerator(player, class, position, angles)
		local entity = ents.Create(class);
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				openAura.player:GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( IsValid(player) ) then
			openAura.player:GiveProperty(player, entity, true);
		end;
		
		entity:SetAngles(angles);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	-- A function to create a shipment.
	function openAura.entity:CreateShipment(player, item, batch, position, angles)
		local entity = ents.Create("aura_shipment");
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				openAura.player:GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( IsValid(player) ) then
			openAura.player:GiveProperty(player, entity);
		end;
		
		entity:SetAngles(angles);
		entity:SetItem(item, batch);
		entity:SetPos(position);
		entity:Spawn();
		
		return entity;
	end;
	
	-- A function to create an item.
	function openAura.entity:CreateItem(player, class, position, angles)
		local itemTable = openAura.item:Get(class);
		local entity = ents.Create("aura_item");
		
		if (!angles) then
			angles = Angle(0, 0, 0);
		end;
		
		if (type(player) == "table") then
			if (player.key and player.uniqueID) then
				openAura.player:GivePropertyOffline(player.key, player.uniqueID, entity, true);
			end;
		elseif ( IsValid(player) ) then
			openAura.player:GiveProperty(player, entity);
		end;
		
		entity:SetAngles(angles);
		entity:SetItem(class);
		entity:SetPos(position);
		entity:Spawn();
		
		if (itemTable) then
			if (itemTable.OnEntitySpawned) then
				itemTable:OnEntitySpawned(entity);
			end;
			
			if (itemTable.bodyGroup) then
				entity:SetBodygroup(itemTable.bodyGroup, 1);
			end;
		end;
		
		return entity;
	end;
	
	-- A function to copy an entity's owner.
	function openAura.entity:CopyOwner(entity, target)
		local removeDelay = self:QueryProperty(entity, "removeDelay");
		local networked = self:QueryProperty(entity, "networked");
		local uniqueID = self:QueryProperty(entity, "uniqueID");
		local key = self:QueryProperty(entity, "key");
		
		openAura.player:GivePropertyOffline(key, uniqueID, target, networked, removeDelay);
	end;
	
	-- A function to get whether an entity belongs to a player's other character.
	function openAura.entity:BelongsToAnotherCharacter(player, entity)
		local uniqueID = self:QueryProperty(entity, "uniqueID");
		local key = self:QueryProperty(entity, "key");
		
		if (uniqueID and key) then
			if ( uniqueID == player:UniqueID() and key != player:QueryCharacter("key") ) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	-- A function to set a property variable for an entity.
	function openAura.entity:SetPropertyVar(entity, key, value)
		if (entity.property) then entity.property[key] = value; end;
	end;
	
	-- A function to query an entity's property table.
	function openAura.entity:QueryProperty(entity, key, default)
		if (entity.property) then
			return entity.property[key] or default;
		else
			return default;
		end;
	end;
	
	-- A function to clear an entity as property.
	function openAura.entity:ClearProperty(entity)
		local owner = self:GetOwner(entity);

		if (owner) then
			openAura.player:TakeProperty(owner, entity);
		elseif ( self:HasOwner(entity) ) then
			local uniqueID = self:QueryProperty(entity, "uniqueID");
			local key = self:QueryProperty(entity, "key");
			
			openAura.player:TakePropertyOffline(key, uniqueID, entity);
		end;
	end;

	-- A function to get whether an entity has an owner.
	function openAura.entity:HasOwner(entity)
		return self:QueryProperty(entity, "owned");
	end;
	
	-- A function to get an entity's owner.
	function openAura.entity:GetOwner(entity)
		local owner = self:QueryProperty(entity, "owner");
		
		if ( IsValid(owner) ) then
			return owner;
		end;
	end;
else
	function openAura.entity:Decay(entity, seconds, Callback)
		local r, g, b, a = entity:GetColor();
		local subtract = math.ceil(a / seconds);
		local index = tostring( {} );
		local alpha = a;
		
		if (entity.decaying) then
			index = entity.decaying;
		else
			entity.decaying = index;
		end;
		
		openAura:CreateTimer("decay_"..index, 1, 0, function()
			alpha = alpha - subtract;
			
			if ( IsValid(entity) ) then
				local r, g, b, a = entity:GetColor();
				local decayed = math.Clamp(math.ceil(alpha), 0, 255);
				
				if (a <= 0) then
					if (Callback) then
						Callback();
					end;
					
					entity:Remove();
					
					openAura:DestroyTimer("decay_"..index);
				else
					entity:SetColor(r, g, b, decayed);
				end;
			else
				openAura:DestroyTimer("decay_"..index);
			end;
		end);
	end;
	
	--[[
		Description: A function to calculate a door's text position.
		Author: Nori (thanks a lot mate, if you're reading this, check out
		CakeScript G3 - it's epic!).
	]]--
	function openAura.entity:CalculateDoorTextPosition(door, reversed)
		local traceData = {};
		local obbCenter = door:OBBCenter();
		local obbMaxs = door:OBBMaxs();
		local obbMins = door:OBBMins();
		
		traceData.endpos = door:LocalToWorld(obbCenter);
		traceData.filter = ents.FindInSphere(traceData.endpos, 20);
		
		for k, v in pairs(traceData.filter) do
			if (v == door) then
				traceData.filter[k] = nil;
			end;
		end;
		
		local length = 0;
		local width = 0;
		local size = obbMins - obbMaxs;
		
		size.x = math.abs(size.x);
		size.y = math.abs(size.y);
		size.z = math.abs(size.z);
		
		if (size.z < size.x and size.z < size.y) then
			length = size.z;
			width = size.y;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetUp() * length);
			else
				traceData.start = traceData.endpos + (door:GetUp() * length);
			end;
		elseif (size.x < size.y) then
			length = size.x;
			width = size.y;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetForward() * length);
			else
				traceData.start = traceData.endpos + (door:GetForward() * length);
			end;
		elseif (size.y < size.x) then
			length = size.y;
			width = size.x;
			
			if (reverse) then
				traceData.start = traceData.endpos - (door:GetRight() * length);
			else
			
				traceData.start = traceData.endpos + (door:GetRight() * length);
			end;
		end;

		local trace = util.TraceLine(traceData);
		local angles = trace.HitNormal:Angle();
		
		if (trace.HitWorld and !reversed) then
			return self:CalculateDoorTextPosition(door, true);
		end;
		
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 90);
		
		local position = trace.HitPos - ( ( (traceData.endpos - trace.HitPos):Length() * 2) + 2 ) * trace.HitNormal;
		local anglesBack = trace.HitNormal:Angle();
		local positionBack = trace.HitPos + (trace.HitNormal * 2);
		
		anglesBack:RotateAroundAxis(anglesBack:Forward(), 90);
		anglesBack:RotateAroundAxis(anglesBack:Right(), -90);
		
		return {
			positionBack = positionBack,
			anglesBack = anglesBack,
			position = position,
			hitWorld = trace.HitWorld,
			angles = angles,
			width = math.abs(width)
		};
	end;
	
	-- A function to force a menu option.
	function openAura.entity:ForceMenuOption(entity, option, arguments)
		openAura:StartDataStream( "EntityMenuOption", {entity, option, arguments} );
	end;
	
	-- A function to get whether an entity has an owner.
	function openAura.entity:HasOwner(entity)
		return entity:GetNetworkedBool("owned");
	end;
	
	-- A function to get an entity's owner.
	function openAura.entity:GetOwner(entity)
		local owner = entity:GetNetworkedEntity("owner");
		
		if ( IsValid(owner) ) then
			return owner;
		end;
	end;
end;